// Cada 15 minutos junta en public.charging_stations los puntos de recarga de
// Canarias de mapaREVE (Red Eléctrica: estado en tiempo real y precios de los
// operadores) y, para los que no estén en REVE, los de Open Charge Map que
// charging-sync deja una vez al día en charging_points. La lee la app desde
// la 1.0.10; las anteriores siguen leyendo charging_points.
//
// Secretos (supabase secrets set):
//   REVE_API_KEY  clave de la API pública de mapaREVE (de Joshua, personal,
//                 válida hasta 16/11/2027; nunca en el repositorio)
//   CRON_SECRET   el mismo que charging-sync y price-alerts
//
// Condiciones de REE: sin uso comercial, citar a Red Eléctrica como fuente,
// no alterar los datos y mostrar la fecha de su última actualización.
//
// Se despliega con --no-verify-jwt: la protege la cabecera x-cron-secret.
// Con ?dry=1 descarga y resume, pero no toca la tabla.

import { createClient } from "npm:@supabase/supabase-js@2.49.4";
import { canaryTime, metres, parseLocation, type ReveStation } from "./reve.ts";

const REVE = "https://www.mapareve.es/api/public/v1";
// Rectángulo que cubre las siete islas. La API da como mucho 25 por página.
const CANARIAS = {
  latitude_ne: 29.5,
  longitude_ne: -13.3,
  latitude_sw: 27.5,
  longitude_sw: -18.3,
  zoom: 15,
};
const PER_PAGE = 25;
// Un punto de Open Charge Map a menos de esto de uno de REVE es el mismo.
const MISMO_SITIO_M = 150;

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
    const message = e instanceof Error ? e.message : JSON.stringify(e);
    return json({ error: message }, 500);
  }
});

async function run(dry: boolean) {
  const key = Deno.env.get("REVE_API_KEY");
  if (!key) throw new Error("Falta el secreto REVE_API_KEY");
  const db = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  const locations = await fetchReve(key);
  const now = new Date();
  const local = canaryTime(now);
  const reve = locations
    .map((l) => parseLocation(l, local))
    .filter((s): s is ReveStation => s != null);

  const { data: ocm, error: ocmError } = await db
    .from("charging_points")
    .select("id, name, operator, address, town, postcode, latitude, longitude, connectors, max_kw, points, status, price_kwh, free, usage_cost, ocm_updated")
    .limit(5000);
  if (ocmError) throw ocmError;

  // Cada punto de OCM: o es uno de REVE (y le presta nombre y municipio) o va aparte.
  const prestado = new Map<string, any>();
  const soloOcm: any[] = [];
  for (const p of ocm ?? []) {
    let best: ReveStation | null = null, bestD = MISMO_SITIO_M;
    for (const s of reve) {
      if (Math.abs(s.latitude - p.latitude) > 0.002) continue;
      const d = metres(s.latitude, s.longitude, p.latitude, p.longitude);
      if (d < bestD) [best, bestD] = [s, d];
    }
    if (!best) soloOcm.push(p);
    else if (!prestado.has(best.reve_id)) prestado.set(best.reve_id, p);
  }

  const synced = now.toISOString();
  const rows = [
    ...reve.map((s) => {
      const p = prestado.get(s.reve_id);
      // Sin precio en REVE: el de la comunidad, si lo hay, marcado como tal.
      const deOcm = s.price_kwh == null && !s.free && (p?.price_kwh != null || p?.free);
      return {
        id: `reve:${s.reve_id}`,
        source: "reve",
        name: s.name ?? p?.name ?? s.operator ?? "Punto de recarga",
        operator: s.operator,
        address: s.address ?? p?.address ?? null,
        town: p?.town ?? null,
        postcode: s.postcode ?? p?.postcode ?? null,
        latitude: s.latitude,
        longitude: s.longitude,
        connectors: s.connectors,
        max_kw: s.max_kw,
        points: s.points,
        available: s.available,
        occupied: s.occupied,
        out_of_order: s.out_of_order,
        status: s.status,
        price_kwh: deOcm ? p.price_kwh : s.price_kwh,
        free: deOcm ? p.free : s.free,
        price_source: deOcm ? "ocm" : s.price_kwh != null || s.free ? "reve" : null,
        extra_fees: s.extra_fees,
        usage_cost: deOcm ? p.usage_cost : s.usage_cost,
        source_updated: s.source_updated,
        synced_at: synced,
      };
    }),
    ...soloOcm.map((p) => ({
      id: `ocm:${p.id}`,
      source: "ocm",
      name: p.name,
      operator: p.operator,
      address: p.address,
      town: p.town,
      postcode: p.postcode,
      latitude: p.latitude,
      longitude: p.longitude,
      connectors: p.connectors,
      max_kw: p.max_kw,
      points: p.points,
      available: null,
      occupied: null,
      out_of_order: null,
      status: p.status,
      price_kwh: p.price_kwh,
      free: p.free,
      price_source: p.price_kwh != null || p.free ? "ocm" : null,
      extra_fees: false,
      usage_cost: p.usage_cost,
      source_updated: p.ocm_updated,
      synced_at: synced,
    })),
  ];

  const summary = {
    dry,
    reve: reve.length,
    reveWithPrice: reve.filter((s) => s.price_kwh != null || s.free).length,
    priceFromOcm: rows.filter((r) => r.source === "reve" && r.price_source === "ocm").length,
    reveOutOfService: reve.filter((s) => s.status === "not_operational").length,
    ocmMatched: (ocm?.length ?? 0) - soloOcm.length,
    ocmOnly: soloOcm.length,
    total: rows.length,
    removed: 0,
  };
  if (dry) return summary;

  for (let i = 0; i < rows.length; i += 500) {
    const { error } = await db.from("charging_stations").upsert(rows.slice(i, i + 500));
    if (error) throw error;
  }
  // Lo que ya no viene (dado de baja, o ahora coincide con REVE) se borra.
  const { count, error } = await db
    .from("charging_stations")
    .delete({ count: "exact" })
    .lt("synced_at", synced);
  if (error) throw error;
  summary.removed = count ?? 0;
  return summary;
}

/** Todas las páginas de Canarias, de cuatro en cuatro (~25 s). Cada 15 min
 *  son 4 peticiones por consulta y hora: la API documentada permite 5. */
async function fetchReve(key: string): Promise<any[]> {
  const page = async (n: number) => {
    const res = await fetch(`${REVE}/locations?page=${n}&per_page=${PER_PAGE}`, {
      method: "POST",
      headers: {
        "x-api-key": key,
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "GasoCan/1.0 (charging-stations)",
      },
      body: JSON.stringify(CANARIAS),
    });
    if (!res.ok) throw new Error(`mapaREVE ${res.status} en la página ${n}`);
    return await res.json();
  };
  const first = await page(1);
  const pages: number = first?.pagination?.total_pages ?? 1;
  const out: any[] = [...(first?.data ?? [])];
  for (let n = 2; n <= pages; n += 4) {
    const batch = await Promise.all(
      [n, n + 1, n + 2, n + 3].filter((k) => k <= pages).map(page),
    );
    for (const b of batch) out.push(...(b?.data ?? []));
  }
  // Sin nada de REVE no se toca la tabla: mejor datos de hace una hora que vacía.
  if (!out.length) throw new Error("mapaREVE no ha devuelto ninguna ubicación");
  return out;
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
