// Descarga una vez al día los puntos de recarga de Canarias de Open Charge Map
// y los guarda en public.charging_points (supabase/puntos_recarga.sql).
//
// Secretos (supabase secrets set):
//   OCM_API_KEY   clave de Open Charge Map
//   CRON_SECRET   el mismo valor que price_alerts_cron_secret del Vault
// SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY los pone Supabase.
//
// Se despliega con --no-verify-jwt: la protege la cabecera x-cron-secret.
// Con ?dry=1 descarga y resume, pero no toca la tabla.
//
// Los datos son de Open Charge Map (CC BY 4.0): la app tiene que citarlo.

import { createClient } from "npm:@supabase/supabase-js@2.49.4";
import { connectorType, parseCost } from "./parse.ts";

const OCM = "https://api.openchargemap.io/v3";
// Rectángulo que cubre las siete islas.
const CANARIAS = "(27.5,-18.3),(29.5,-13.3)";

type Ref = { ID: number; Title: string; IsOperational?: boolean | null };
type Connector = { type: string; label: string; kw: number | null; quantity: number };

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
    // Los errores de Supabase no son Error: se devuelven enteros.
    const message = e instanceof Error ? e.message : JSON.stringify(e);
    return json({ error: message }, 500);
  }
});

async function run(dry: boolean) {
  const key = Deno.env.get("OCM_API_KEY");
  if (!key) throw new Error("Falta el secreto OCM_API_KEY");
  const headers = { "X-API-Key": key, "User-Agent": "GasoCan/1.0 (charging-sync)" };

  const [ref, pois] = await Promise.all([
    get(`${OCM}/referencedata/?output=json`, headers),
    get(
      `${OCM}/poi/?output=json&boundingbox=${CANARIAS}&maxresults=5000&compact=true&verbose=false`,
      headers,
    ),
  ]);
  const byId = (list: Ref[] = []) => new Map(list.map((r) => [r.ID, r]));
  const connectionTypes = byId(ref.ConnectionTypes);
  const operators = byId(ref.Operators);
  const statusTypes = byId(ref.StatusTypes);

  const now = new Date().toISOString();
  const rows = (pois as any[]).map((p) => {
    const a = p.AddressInfo ?? {};
    const connectors: Connector[] = (p.Connections ?? []).map((c: any) => {
      const label = connectionTypes.get(c.ConnectionTypeID)?.Title ?? "";
      return {
        type: connectorType(label),
        label,
        kw: typeof c.PowerKW === "number" && c.PowerKW > 0 ? c.PowerKW : null,
        quantity: c.Quantity ?? 1,
      };
    });
    const kws = connectors.map((c) => c.kw ?? 0);
    const operator = operators.get(p.OperatorID)?.Title;
    const cost = parseCost(p.UsageCost);
    return {
      id: p.ID,
      name: (a.Title ?? "").trim() || operator || "Punto de recarga",
      operator: operator && !/unknown|desconocido|\(business owner/i.test(operator) ? operator : null,
      address: [a.AddressLine1, a.AddressLine2].filter(Boolean).join(", ") || null,
      town: a.Town ?? null,
      postcode: a.Postcode ?? null,
      latitude: a.Latitude,
      longitude: a.Longitude,
      connectors,
      max_kw: kws.length ? Math.max(...kws) || null : null,
      points: p.NumberOfPoints ?? (connectors.reduce((n, c) => n + c.quantity, 0) || null),
      status: status(statusTypes.get(p.StatusTypeID)),
      price_kwh: cost.priceKwh,
      free: cost.free,
      usage_cost: typeof p.UsageCost === "string" ? p.UsageCost.trim() || null : null,
      ocm_updated: p.DateLastStatusUpdate ?? p.DateLastVerified ?? p.DateCreated ?? null,
      synced_at: now,
    };
  }).filter((r) => typeof r.latitude === "number" && typeof r.longitude === "number");

  const summary = {
    dry,
    points: rows.length,
    withPrice: rows.filter((r) => r.price_kwh != null).length,
    free: rows.filter((r) => r.free).length,
    fast: rows.filter((r) => (r.max_kw ?? 0) >= 50).length,
    removed: 0,
  };
  if (dry) return summary;

  const db = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );
  for (let i = 0; i < rows.length; i += 500) {
    const { error } = await db.from("charging_points").upsert(rows.slice(i, i + 500));
    if (error) throw error;
  }
  // Los que ya no vienen en Open Charge Map (dados de baja) se borran.
  const { count, error } = await db
    .from("charging_points")
    .delete({ count: "exact" })
    .lt("synced_at", now);
  if (error) throw error;
  summary.removed = count ?? 0;
  return summary;
}

async function get(url: string, headers: Record<string, string>) {
  const res = await fetch(url, { headers });
  if (!res.ok) throw new Error(`Open Charge Map ${res.status}: ${url.split("?")[0]}`);
  return await res.json();
}

function status(s?: Ref) {
  if (!s) return "unknown";
  if (s.IsOperational === true) return "operational";
  if (s.IsOperational === false) return "not_operational";
  return "unknown";
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
