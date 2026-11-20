// Lectura de los datos de mapaREVE (Red Eléctrica) para charging_stations.
// Aparte de index.ts para poder probarla (reve_test.ts).
//
// La API pública de mapaREVE no tiene documentación propia; los datos siguen
// OCPI 2.2: ubicación → EVSE (cargador, con estado en tiempo real) →
// conector (potencia en W y tarifas por franja horaria, precios sin IVA).

export type Connector = {
  type: string;
  label: string;
  kw: number | null;
  quantity: number;
  /** €/kWh con IVA a la hora de la sincronización; null si no se publica. */
  price_kwh: number | null;
};

/** Hora local de Canarias para elegir la franja de la tarifa. */
export type LocalTime = { weekday: string; minutes: number };

const DIAS = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"];

export function canaryTime(date: Date): LocalTime {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: "Atlantic/Canary",
    weekday: "long",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);
  const get = (t: string) => parts.find((p) => p.type === t)?.value ?? "";
  return {
    weekday: get("weekday").toUpperCase(),
    minutes: Number(get("hour")) * 60 + Number(get("minute")),
  };
}

/** Tipo de conector de la app a partir del estándar OCPI. */
export function connectorKind(standard: string): { type: string; label: string } {
  switch (standard) {
    case "IEC_62196_T2":
      return { type: "type2", label: "Type 2" };
    case "IEC_62196_T2_COMBO":
      return { type: "ccs", label: "CCS (Type 2)" };
    case "IEC_62196_T1_COMBO":
      return { type: "ccs", label: "CCS (Type 1)" };
    case "CHADEMO":
      return { type: "chademo", label: "CHAdeMO" };
    case "IEC_62196_T1":
      return { type: "type1", label: "Type 1" };
    case "TESLA_R":
    case "TESLA_S":
      return { type: "tesla", label: "Tesla" };
    case "DOMESTIC_F":
    case "DOMESTIC_E":
      return { type: "schuko", label: "Schuko" };
    default:
      return { type: "other", label: standard || "" };
  }
}

function minutes(hhmm: string | null | undefined): number | null {
  if (!hhmm) return null;
  const m = /^(\d{1,2}):(\d{2})/.exec(hhmm);
  return m ? Number(m[1]) * 60 + Number(m[2]) : null;
}

function num(v: unknown): number | null {
  const n = typeof v === "string" ? Number(v) : v;
  return typeof n === "number" && Number.isFinite(n) ? n : null;
}

/**
 * Precio de la energía (€/kWh con IVA) que aplica ahora a un conector de
 * `kw` kW, y si además cobra por tiempo, por conexión o por estar aparcado.
 * Como en OCPI, vale el primer elemento de la tarifa que cumple las
 * restricciones (día, hora y potencia). Las de kWh, duración o corriente no
 * se pueden saber de antemano y no se tienen en cuenta.
 */
export function tariffNow(
  tariffs: any[] | null | undefined,
  kw: number | null,
  now: LocalTime,
): { price: number | null; extras: boolean } {
  let extras = false;
  for (const t of tariffs ?? []) {
    const elements: any[] = t?.tariff?.elements ?? t?.elements ?? [];
    let price: number | null = null;
    for (const el of elements) {
      const r = el?.restrictions ?? {};
      if (r.reservation) continue;
      const comps: any[] = el?.price_components ?? [];
      if (comps.some((c) => c.type !== "ENERGY" && (num(c.price) ?? 0) > 0)) extras = true;
      if (price != null) continue;
      if (Array.isArray(r.day_of_week) && r.day_of_week.length && !r.day_of_week.includes(now.weekday)) continue;
      const start = minutes(r.start_time), end = minutes(r.end_time);
      if (start != null && end != null) {
        // «22:00»-«06:59» cruza la medianoche; el fin se cuenta incluido.
        const dentro = start <= end
          ? now.minutes >= start && now.minutes <= end
          : now.minutes >= start || now.minutes <= end;
        if (!dentro) continue;
      }
      const minP = num(r.min_power), maxP = num(r.max_power);
      if (kw != null && minP != null && kw < minP) continue;
      if (kw != null && maxP != null && kw > maxP) continue;
      const energy = comps.find((c) => c.type === "ENERGY");
      if (!energy) continue;
      const base = num(energy.price);
      if (base == null) continue;
      const vat = num(energy.vat) ?? 0;
      price = Math.round(base * (1 + vat / 100) * 1000) / 1000;
    }
    if (price != null) return { price, extras };
  }
  return { price: null, extras };
}

/** Un nombre que se pueda leer: muchas ubicaciones se llaman con un código. */
export function readableName(name: unknown): string | null {
  if (typeof name !== "string") return null;
  let t = name.trim().replace(/\s{2,}/g, " ");
  // «E-GC-CasasDeVeneguera-001» → «Casas De Veneguera».
  const codigo = /^[A-Z]-[A-Z]{2}-([A-Za-zÀ-ÿ]+)-\d+$/.exec(t);
  if (codigo) t = codigo[1].replace(/([a-zà-ÿ])([A-ZÀ-Ý])/g, "$1 $2");
  if (!t || !/[a-záéíóúñ]{3}/i.test(t)) return null;
  // «C6E15BCC22GCAWPRRZ»: una sola palabra con cifras es un código.
  if (!/\s/.test(t) && /\d/.test(t)) return null;
  // «ES*IBD*E123», «TF-0012-A1»: más dígitos y símbolos que letras.
  const letras = (t.match(/[a-záéíóúñ]/gi) ?? []).length;
  if (letras < t.replace(/\s/g, "").length / 2) return null;
  return t;
}

/** «PCAN Los Realejos - Calle los Barros, 30A,» → nombre y dirección. */
export function splitAddress(address: unknown): { head: string | null; street: string | null } {
  if (typeof address !== "string" || !address.trim()) return { head: null, street: null };
  const clean = (s: string) => s.trim().replace(/[,\s]+$/, "") || null;
  const parts = address.split(" - ");
  if (parts.length >= 2 && parts[0].trim().length <= 40) {
    return { head: clean(parts[0]), street: clean(parts.slice(1).join(" - ")) };
  }
  return { head: null, street: clean(address) };
}

export function cleanOperator(name: unknown): string | null {
  if (typeof name !== "string" || !name.trim()) return null;
  return name.trim().replace(/,?\s+S\.?\s?[LA]\.?(\s?U\.?)?$/i, "").trim();
}

const NO_INSTALADO = new Set(["PLANNED", "REMOVED"]);
const AVERIADO = new Set(["OUTOFORDER", "INOPERATIVE"]);
const FUNCIONA = new Set(["AVAILABLE", "CHARGING", "BLOCKED", "RESERVED"]);

export type ReveStation = {
  reve_id: string;
  name: string | null;
  operator: string | null;
  address: string | null;
  postcode: string | null;
  latitude: number;
  longitude: number;
  connectors: Connector[];
  max_kw: number | null;
  points: number;
  available: number;
  /** Cargando, bloqueados o reservados: ocupados ahora. */
  occupied: number;
  out_of_order: number;
  status: "operational" | "not_operational" | "unknown";
  price_kwh: number | null;
  free: boolean;
  extra_fees: boolean;
  usage_cost: string | null;
  source_updated: string | null;
};

/** Una ubicación de REVE para la tabla, o null si no hay nada instalado. */
export function parseLocation(loc: any, now: LocalTime): ReveStation | null {
  const lat = num(loc?.coordinates?.latitude), lon = num(loc?.coordinates?.longitude);
  if (lat == null || lon == null) return null;
  const evses: any[] = (loc.evses ?? []).filter((e: any) => !NO_INSTALADO.has(e?.status));
  if (!evses.length) return null;

  const groups = new Map<string, Connector>();
  let extras = false;
  let human: string | null = null;
  let updated: string | null = null;
  for (const e of evses) {
    for (const stamp of [e.status_updated_at, e.last_updated]) {
      if (typeof stamp === "string" && (!updated || stamp > updated)) updated = stamp;
    }
    // Un cargador con dos mangueras solo carga por una a la vez: cuenta una.
    const seen = new Set<string>();
    for (const c of e.connectors ?? []) {
      const { type, label } = connectorKind(c.standard);
      const watts = num(c.max_electric_power);
      const kw = watts && watts > 0 ? Math.round(watts / 100) / 10 : null;
      const tariff = tariffNow(c.tariffs, kw, now);
      if (tariff.extras) extras = true;
      for (const t of c.tariffs ?? []) {
        if (!human && Array.isArray(t?.human) && t.human.length) human = t.human.join(" · ");
      }
      const key = `${type}|${label}|${kw}`;
      const g = groups.get(key);
      if (!g) {
        groups.set(key, { type, label, kw, quantity: seen.has(key) ? 0 : 1, price_kwh: tariff.price });
      } else {
        if (!seen.has(key)) g.quantity += 1;
        if (tariff.price != null && (g.price_kwh == null || tariff.price < g.price_kwh)) {
          g.price_kwh = tariff.price;
        }
      }
      seen.add(key);
    }
  }
  const connectors = [...groups.values()];
  const kws = connectors.map((c) => c.kw ?? 0);
  const prices = connectors.map((c) => c.price_kwh).filter((p): p is number => p != null);
  const minPrice = prices.length ? Math.min(...prices) : null;
  const statuses = evses.map((e) => e.status);
  const status = statuses.some((s) => FUNCIONA.has(s))
    ? "operational"
    : statuses.every((s) => AVERIADO.has(s))
    ? "not_operational"
    : "unknown";
  const { head, street } = splitAddress(loc.address);
  return {
    reve_id: String(loc.id),
    name: readableName(loc.name) ?? readableName(head),
    operator: cleanOperator(loc.owner?.name),
    address: street,
    postcode: typeof loc.postal_code === "string" ? loc.postal_code : null,
    latitude: lat,
    longitude: lon,
    connectors,
    max_kw: kws.length ? Math.max(...kws) || null : null,
    points: evses.length,
    available: statuses.filter((s) => s === "AVAILABLE").length,
    occupied: statuses.filter((s) => FUNCIONA.has(s) && s !== "AVAILABLE").length,
    out_of_order: statuses.filter((s) => AVERIADO.has(s)).length,
    status,
    price_kwh: minPrice && minPrice > 0 ? minPrice : null,
    free: minPrice === 0 && !extras,
    extra_fees: extras,
    usage_cost: human,
    source_updated: updated,
  };
}

/** Distancia en metros (suficiente a esta escala). */
export function metres(aLat: number, aLon: number, bLat: number, bLon: number): number {
  const rad = Math.PI / 180;
  const x = (bLon - aLon) * rad * Math.cos(((aLat + bLat) / 2) * rad);
  const y = (bLat - aLat) * rad;
  return Math.sqrt(x * x + y * y) * 6371000;
}
