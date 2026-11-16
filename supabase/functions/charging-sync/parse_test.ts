import { assertEquals } from "jsr:@std/assert@1";
import { connectorType, parseCost } from "./parse.ts";

Deno.test("precios en €/kWh", () => {
  assertEquals(parseCost("0,38€/kWh"), { priceKwh: 0.38, free: false });
  assertEquals(parseCost(" 0,47€/kWh"), { priceKwh: 0.47, free: false });
  assertEquals(parseCost("0.60€/kWh "), { priceKwh: 0.6, free: false });
  assertEquals(parseCost("0,54€/kWh DC "), { priceKwh: 0.54, free: false });
  assertEquals(parseCost("0,38"), { priceKwh: 0.38, free: false });
  assertEquals(parseCost("0,38 Euro"), { priceKwh: 0.38, free: false });
});

Deno.test("gratis y lo que no se entiende", () => {
  assertEquals(parseCost("Gratuito"), { priceKwh: null, free: true });
  assertEquals(parseCost("Free"), { priceKwh: null, free: true });
  assertEquals(parseCost("€0/kWh"), { priceKwh: null, free: true });
  assertEquals(parseCost("0"), { priceKwh: null, free: true });
  assertEquals(parseCost("2€/hora"), { priceKwh: null, free: false });
  assertEquals(parseCost("parking fee"), { priceKwh: null, free: false });
  assertEquals(parseCost(null), { priceKwh: null, free: false });
});

Deno.test("tipos de conector", () => {
  assertEquals(connectorType("CCS (Type 2)"), "ccs");
  assertEquals(connectorType("Type 2 (Socket Only)"), "type2");
  assertEquals(connectorType("Type 2 (Tethered Connector) "), "type2");
  assertEquals(connectorType("CHAdeMO"), "chademo");
  assertEquals(connectorType("CEE 7/4 - Schuko - Type F"), "schuko");
  assertEquals(connectorType("Type 1 (J1772)"), "type1");
});
