// Alertas de bajada de precio por push (FCM).
//
// La lanza el cron "price-alerts" cada hora (supabase/push_notifications.sql).
// 1. Descarga de precioil.es (la misma fuente que la app) los precios de las
//    gasolineras que alguien tiene en favoritos. La API del Ministerio corta
//    la conexión desde los servidores de Supabase, por eso no se usa.
// 2. Los compara con station_price_snapshots.
// 3. A cada usuario con esa gasolinera en favoritos y ese combustible como
//    preferido le manda una push a todos sus dispositivos.
// 4. Guarda los precios nuevos como referencia para la siguiente vuelta.
//
// Secretos (supabase secrets set):
//   CRON_SECRET                el mismo valor que price_alerts_cron_secret del Vault
//   FIREBASE_SERVICE_ACCOUNT   JSON de la cuenta de servicio de Firebase
// SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY los pone Supabase.
//
// Se despliega con --no-verify-jwt: la protege la cabecera x-cron-secret.
// Con ?dry=1 calcula las bajadas pero no envía nada ni guarda precios.

import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2.49.4";

const PRECIOIL_DETALLES = "https://api.precioil.es/estaciones/detalles/";
const CONCURRENCY = 5;

// Combustible de la app (users.preferred_fuel) -> campo de precioil.es.
const FUELS: Record<string, { field: string; label: string }> = {
  g95: { field: "Gasolina95", label: "Gasolina 95" },
  g98: { field: "Gasolina98", label: "Gasolina 98" },
  diesel: { field: "Diesel", label: "Diésel" },
  dieselPremium: { field: "DieselPremium", label: "Diésel Premium" },
};

// Por debajo de esto no se avisa (0,1 céntimos: redondeos).
const MIN_DROP = 0.001;

type Station = { id: number; name: string; town: string; prices: Map<string, number> };
type Drop = { station: Station; fuel: string; before: number; now: number };

Deno.serve(async (req) => {
  const secret = Deno.env.get("CRON_SECRET");
  if (!secret || req.headers.get("x-cron-secret") !== secret) {
    return json({ error: "unauthorized" }, 401);
  }
  const dry = new URL(req.url).searchParams.get("dry") === "1";
  try {
    return json(await run(dry));
  } catch (e) {
    console.error(e);
    return json({ error: e instanceof Error ? e.message : String(e) }, 500);
  }
});

async function run(dry: boolean) {

  const db = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  const { data: favs, error: favsError } = await db.from("favorites").select("station_id");
  if (favsError) throw favsError;
  const ids = [...new Set((favs ?? []).map((f) => Number(f.station_id)))];
  const stations = await fetchStations(ids);
  const previous = await loadSnapshots(db);

  const drops: Drop[] = [];
  const rows: { station_id: number; fuel: string; price: number; updated_at: string }[] = [];
  const now = new Date().toISOString();
  for (const station of stations.values()) {
    for (const [fuel, price] of station.prices) {
      rows.push({ station_id: station.id, fuel, price, updated_at: now });
      const before = previous.get(`${station.id}:${fuel}`);
      if (before !== undefined && before - price >= MIN_DROP) {
        drops.push({ station, fuel, before, now: price });
      }
    }
  }

  const notifications = drops.length ? await buildNotifications(db, drops) : [];

  let sent = 0;
  let removed = 0;
  if (!dry) {
    if (notifications.length) {
      const fcm = await FcmClient.fromEnv();
      for (const n of notifications) {
        const result = await fcm.send(n.token, n.title, n.body, {
          station_id: String(n.stationId),
        });
        if (result === "sent") sent++;
        if (result === "invalid") {
          await db.from("push_tokens").delete().eq("token", n.token);
          removed++;
        }
      }
    }
    // Guardar al final: si algo falla antes, la próxima vuelta lo reintenta.
    for (let i = 0; i < rows.length; i += 1000) {
      const { error } = await db
        .from("station_price_snapshots")
        .upsert(rows.slice(i, i + 1000));
      if (error) throw error;
    }
  }

  const summary = {
    dry,
    stations: stations.size,
    failed: ids.length - stations.size,
    firstRun: previous.size === 0,
    drops: drops.length,
    notifications: notifications.length,
    sent,
    removedTokens: removed,
  };
  console.log(JSON.stringify(summary));
  return summary;
}

async function fetchStations(ids: number[]): Promise<Map<number, Station>> {
  const stations = new Map<number, Station>();
  const queue = [...ids];
  const worker = async () => {
    for (let id = queue.shift(); id !== undefined; id = queue.shift()) {
      try {
        const res = await fetch(PRECIOIL_DETALLES + id, {
          headers: { Accept: "application/json" },
          signal: AbortSignal.timeout(15000),
        });
        if (!res.ok) continue; // 404: la gasolinera ya no existe.
        const e = await res.json();
        const prices = new Map<string, number>();
        for (const [fuel, { field }] of Object.entries(FUELS)) {
          const value = parsePrice(e[field]);
          if (value !== null) prices.set(fuel, value);
        }
        stations.set(id, {
          id,
          name: String(e.nombreEstacion ?? e.marca ?? "").trim() || "Tu gasolinera",
          town: titleCase(String(e.localidad ?? "").trim()),
          prices,
        });
      } catch (err) {
        // Sin precio esta vuelta: no se compara ni se pisa el anterior.
        console.error(`precioil ${id}: ${err}`);
      }
    }
  };
  await Promise.all(Array.from({ length: CONCURRENCY }, worker));
  return stations;
}

async function loadSnapshots(db: SupabaseClient) {
  const map = new Map<string, number>();
  const pageSize = 1000;
  for (let from = 0; ; from += pageSize) {
    const { data, error } = await db
      .from("station_price_snapshots")
      .select("station_id, fuel, price")
      .range(from, from + pageSize - 1);
    if (error) throw error;
    for (const r of data ?? []) map.set(`${r.station_id}:${r.fuel}`, Number(r.price));
    if (!data || data.length < pageSize) break;
  }
  return map;
}

type Notification = { token: string; stationId: number; title: string; body: string };

async function buildNotifications(
  db: SupabaseClient,
  drops: Drop[],
): Promise<Notification[]> {
  const stationIds = [...new Set(drops.map((d) => d.station.id))];

  const { data: favorites, error: favError } = await db
    .from("favorites")
    .select("user_id, station_id")
    .in("station_id", stationIds);
  if (favError) throw favError;
  if (!favorites?.length) return [];

  const userIds = [...new Set(favorites.map((f) => f.user_id as string))];
  const [{ data: users, error: usersError }, { data: tokens, error: tokensError }] =
    await Promise.all([
      db.from("users").select("id, preferred_fuel").in("id", userIds),
      db.from("push_tokens").select("token, user_id").in("user_id", userIds),
    ]);
  if (usersError) throw usersError;
  if (tokensError) throw tokensError;

  const fuelOf = new Map((users ?? []).map((u) => [u.id as string, (u.preferred_fuel as string) ?? "g95"]));
  const tokensOf = new Map<string, string[]>();
  for (const t of tokens ?? []) {
    tokensOf.set(t.user_id as string, [...(tokensOf.get(t.user_id as string) ?? []), t.token as string]);
  }
  const dropOf = new Map(drops.map((d) => [`${d.station.id}:${d.fuel}`, d]));

  const out: Notification[] = [];
  for (const f of favorites) {
    const userId = f.user_id as string;
    const preferred = fuelOf.get(userId) ?? "g95";
    const fuel = preferred in FUELS ? preferred : "g95";
    const drop = dropOf.get(`${f.station_id}:${fuel}`);
    if (!drop) continue;
    const where = drop.station.town ? `${drop.station.name} (${drop.station.town})` : drop.station.name;
    const body =
      `${where}: ${FUELS[fuel].label} a ${euros(drop.now)} €/L ` +
      `(bajó ${euros(drop.before - drop.now)} €)`;
    for (const token of tokensOf.get(userId) ?? []) {
      out.push({ token, stationId: drop.station.id, title: "⛽ ¡Bajó el precio!", body });
    }
  }
  return out;
}

// --- FCM HTTP v1 --------------------------------------------------------------

class FcmClient {
  private constructor(private projectId: string, private accessToken: string) {}

  static async fromEnv(): Promise<FcmClient> {
    const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!raw) throw new Error("Falta el secreto FIREBASE_SERVICE_ACCOUNT");
    const sa = JSON.parse(raw);
    return new FcmClient(sa.project_id, await googleAccessToken(sa));
  }

  async send(
    token: string,
    title: string,
    body: string,
    data: Record<string, string>,
  ): Promise<"sent" | "invalid" | "error"> {
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body },
            data,
            android: { priority: "high", notification: { channel_id: "price_alerts" } },
            apns: { payload: { aps: { sound: "default" } } },
          },
        }),
      },
    );
    if (res.ok) return "sent";
    const text = await res.text();
    console.error(`FCM ${res.status}: ${text}`);
    // Token caducado o de otra app: se borra para no reintentarlo.
    if (res.status === 404 || text.includes("UNREGISTERED") || text.includes("INVALID_ARGUMENT")) {
      return "invalid";
    }
    return "error";
  }
}

async function googleAccessToken(sa: { client_email: string; private_key: string }) {
  const now = Math.floor(Date.now() / 1000);
  const enc = (o: unknown) => base64url(new TextEncoder().encode(JSON.stringify(o)));
  const unsigned =
    `${enc({ alg: "RS256", typ: "JWT" })}.` +
    enc({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    });
  const pem = sa.private_key.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned)),
  );
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${base64url(signature)}`,
    }),
  });
  if (!res.ok) throw new Error(`Google OAuth respondió ${res.status}: ${await res.text()}`);
  return (await res.json()).access_token as string;
}

// --- utilidades ---------------------------------------------------------------

function parsePrice(value: unknown): number | null {
  if (typeof value === "number") return value > 0 ? value : null;
  if (typeof value !== "string" || !value.trim()) return null;
  const n = Number(value.replace(",", "."));
  return Number.isFinite(n) && n > 0 ? n : null;
}

function euros(n: number) {
  return n.toFixed(3).replace(".", ",");
}

function titleCase(s: string) {
  return s.toLowerCase().replace(/(^|[\s(-])(\p{L})/gu, (_, a, b) => a + b.toUpperCase());
}

function base64url(bytes: Uint8Array) {
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
