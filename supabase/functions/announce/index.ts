// Anuncio por push a todos los dispositivos registrados (novedades de la app).
//
// No la lanza ningún cron: se llama a mano, una vez por anuncio.
//   POST /functions/v1/announce?dry=1   cuenta destinatarios, no envía nada
//   POST /functions/v1/announce         envía
// Cabecera x-cron-secret (el mismo CRON_SECRET que price-alerts) y cuerpo JSON
// con el texto en cada idioma de la app; el de "es" es obligatorio y sirve
// para los dispositivos sin idioma o con otro:
//   { "texts": { "es": { "title": "…", "body": "…" }, "en": {…}, "de": {…} } }
// Los anuncios enviados se guardan en store/anuncios/.
//
// Secretos: CRON_SECRET y FIREBASE_SERVICE_ACCOUNT (los mismos que price-alerts).
// Se despliega con --no-verify-jwt: la protege la cabecera x-cron-secret.

import { createClient } from "npm:@supabase/supabase-js@2.49.4";

type Text = { title: string; body: string };
type Texts = Record<string, Text>;

Deno.serve(async (req) => {
  const secret = Deno.env.get("CRON_SECRET");
  if (!secret || req.headers.get("x-cron-secret") !== secret) {
    return json({ error: "unauthorized" }, 401);
  }
  if (req.method !== "POST") return json({ error: "POST" }, 405);
  const dry = new URL(req.url).searchParams.get("dry") === "1";
  try {
    const { texts } = await req.json() as { texts?: Texts };
    if (!texts?.es?.title || !texts.es.body) {
      return json({ error: "Falta texts.es.title / texts.es.body" }, 400);
    }
    return json(await run(texts, dry));
  } catch (e) {
    console.error(e);
    const message = e instanceof Error ? e.message : JSON.stringify(e);
    return json({ error: message }, 500);
  }
});

async function run(texts: Texts, dry: boolean) {
  const db = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );
  const { data, error } = await db.from("push_tokens").select("token, platform, locale");
  if (error) throw error;
  const tokens = (data ?? []) as { token: string; platform: string; locale: string | null }[];

  const byLocale: Record<string, number> = {};
  const byPlatform: Record<string, number> = {};
  for (const t of tokens) {
    const l = textFor(texts, t.locale).locale;
    byLocale[l] = (byLocale[l] ?? 0) + 1;
    byPlatform[t.platform] = (byPlatform[t.platform] ?? 0) + 1;
  }

  let sent = 0;
  let removed = 0;
  const errors: string[] = [];
  if (!dry && tokens.length) {
    const fcm = await FcmClient.fromEnv();
    for (const t of tokens) {
      const { text } = textFor(texts, t.locale);
      const result = await fcm.send(t.token, text.title, text.body);
      if (result === "sent") sent++;
      else if (result === "invalid") {
        await db.from("push_tokens").delete().eq("token", t.token);
        removed++;
      } else if (errors.length < 3) errors.push(result);
    }
  }

  const summary = { dry, devices: tokens.length, byLocale, byPlatform, sent, removedTokens: removed, errors };
  console.log(JSON.stringify(summary));
  return summary;
}

// "de_DE" -> "de"; sin texto en ese idioma, español.
function textFor(texts: Texts, locale: string | null) {
  const l = (locale ?? "es").slice(0, 2).toLowerCase();
  return texts[l]?.title && texts[l]?.body
    ? { locale: l, text: texts[l] }
    : { locale: "es", text: texts.es };
}

// --- FCM HTTP v1 (igual que en price-alerts) ---------------------------------

class FcmClient {
  private constructor(private projectId: string, private accessToken: string) {}

  static async fromEnv(): Promise<FcmClient> {
    const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!raw) throw new Error("Falta el secreto FIREBASE_SERVICE_ACCOUNT");
    const sa = JSON.parse(raw);
    return new FcmClient(sa.project_id, await googleAccessToken(sa));
  }

  async send(token: string, title: string, body: string): Promise<"sent" | "invalid" | string> {
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
            data: { kind: "announcement" },
            android: { priority: "high", notification: { channel_id: "price_alerts" } },
            apns: { payload: { aps: { sound: "default" } } },
          },
        }),
      },
    );
    if (res.ok) return "sent";
    const text = await res.text();
    console.error(`FCM ${res.status}: ${text}`);
    if (res.status === 404 || text.includes("UNREGISTERED") || text.includes("INVALID_ARGUMENT")) {
      return "invalid";
    }
    return `FCM ${res.status}: ${text.slice(0, 300)}`;
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
