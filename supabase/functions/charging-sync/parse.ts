// Lectura de los datos de Open Charge Map para la tabla charging_points.
// Aparte de index.ts para poder probarla (parse_test.ts).

/// Tipo de conector simplificado para los filtros de la app.
export function connectorType(label: string): string {
  const t = label.toLowerCase();
  if (t.includes("ccs") || t.includes("combo")) return "ccs";
  if (t.includes("chademo")) return "chademo";
  if (t.includes("tesla") || t.includes("nacs")) return "tesla";
  if (t.includes("type 2") || t.includes("mennekes") || t.includes("iec 62196")) return "type2";
  if (t.includes("type 1") || t.includes("j1772")) return "type1";
  if (t.includes("schuko") || t.includes("cee 7") || t.includes("domestic")) return "schuko";
  return "other";
}

/// Lee el precio del texto libre de la comunidad: «0,38€/kWh», «0.60 €/kWh»,
/// «Gratuito», «Free»... Si no se entiende (p. ej. «2€/hora»), sin precio.
export function parseCost(raw: unknown): { priceKwh: number | null; free: boolean } {
  if (typeof raw !== "string" || !raw.trim()) return { priceKwh: null, free: false };
  const text = raw.trim().toLowerCase();
  const kwh = text.match(/(\d+(?:[.,]\d+)?)\s*(?:€|eur|euros?)?\s*\/?\s*kwh/);
  if (kwh) {
    const value = Number(kwh[1].replace(",", "."));
    if (value === 0) return { priceKwh: null, free: true };
    if (value > 0.05 && value < 1.5) return { priceKwh: value, free: false };
    return { priceKwh: null, free: false };
  }
  if (/gratu|free|gratis|kostenlos|^0\s*(€|eur)?$/.test(text)) {
    return { priceKwh: null, free: true };
  }
  // Solo un número con euros y sin «hora/min»: se entiende por kWh.
  const bare = text.match(/^(\d+[.,]\d+)\s*(?:€|eur|euros?)?$/);
  if (bare) {
    const value = Number(bare[1].replace(",", "."));
    if (value > 0.05 && value < 1.5) return { priceKwh: value, free: false };
  }
  return { priceKwh: null, free: false };
}

