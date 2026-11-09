// Retira el permiso de «Iniciar sesión con Apple» al eliminar una cuenta,
// como pide Apple (guía 5.1.1(v)).
//
// La app, justo antes de borrar la cuenta, pide a Apple un authorizationCode
// nuevo y lo manda aquí. Esta función lo canjea por un token y lo revoca.
// La llama el propio usuario con su sesión (verify_jwt activo).
//
// Secreto (supabase secrets set): APPLE_SIGNIN_KEY = contenido del .p8 con
// «Sign in with Apple» (Key ID abajo). Se configura con
// supabase/configurar_apple.sh.

import { createClient } from "npm:@supabase/supabase-js@2.49.4";

const TEAM_ID = "26W4G92PSS";
const KEY_ID = "722AK4C752";
const CLIENT_ID = "com.jadrdev.gasolineracanarias";

Deno.serve(async (req) => {
  try {
    const auth = req.headers.get("Authorization") ?? "";
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: auth } }, auth: { persistSession: false } },
    );
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return json({ error: "unauthorized" }, 401);
    const providers = (user.app_metadata?.providers as string[] | undefined) ?? [];
    if (!providers.includes("apple")) return json({ revoked: false, reason: "not_apple" });

    const { authorizationCode } = await req.json().catch(() => ({}));
    if (typeof authorizationCode !== "string" || !authorizationCode) {
      return json({ error: "missing authorizationCode" }, 400);
    }

    const clientSecret = await appleClientSecret();
    const tokenRes = await fetch("https://appleid.apple.com/auth/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        client_id: CLIENT_ID,
        client_secret: clientSecret,
        code: authorizationCode,
        grant_type: "authorization_code",
      }),
    });
    const tokens = await tokenRes.json().catch(() => ({}));
    if (!tokenRes.ok) {
      return json({ error: `Apple token ${tokenRes.status}: ${tokens.error ?? ""}` }, 502);
    }
    const token = tokens.refresh_token ?? tokens.access_token;
    const hint = tokens.refresh_token ? "refresh_token" : "access_token";

    const revokeRes = await fetch("https://appleid.apple.com/auth/revoke", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        client_id: CLIENT_ID,
        client_secret: clientSecret,
        token,
        token_type_hint: hint,
      }),
    });
    if (!revokeRes.ok) {
      return json({ error: `Apple revoke ${revokeRes.status}: ${await revokeRes.text()}` }, 502);
    }
    return json({ revoked: true });
  } catch (e) {
    console.error(e);
    return json({ error: e instanceof Error ? e.message : String(e) }, 500);
  }
});

// JWT ES256 que Apple usa como client_secret (válido 5 minutos).
async function appleClientSecret() {
  const pem = Deno.env.get("APPLE_SIGNIN_KEY");
  if (!pem) throw new Error("Falta el secreto APPLE_SIGNIN_KEY");
  const der = Uint8Array.from(
    atob(pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "")),
    (c) => c.charCodeAt(0),
  );
  const key = await crypto.subtle.importKey(
    "pkcs8",
    der,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  );
  const now = Math.floor(Date.now() / 1000);
  const enc = (o: unknown) => base64url(new TextEncoder().encode(JSON.stringify(o)));
  const unsigned = `${enc({ alg: "ES256", kid: KEY_ID })}.${enc({
    iss: TEAM_ID,
    iat: now,
    exp: now + 300,
    aud: "https://appleid.apple.com",
    sub: CLIENT_ID,
  })}`;
  // WebCrypto devuelve la firma ECDSA ya en formato r||s, que es el de JWS.
  const sig = new Uint8Array(
    await crypto.subtle.sign(
      { name: "ECDSA", hash: "SHA-256" },
      key,
      new TextEncoder().encode(unsigned),
    ),
  );
  return `${unsigned}.${base64url(sig)}`;
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
