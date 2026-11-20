import { assertEquals } from "jsr:@std/assert@1";
import { canaryTime, parseLocation, readableName, splitAddress, tariffNow } from "./reve.ts";

const tarifa = [{
  human: [],
  tariff: {
    elements: [
      {
        price_components: [{ type: "ENERGY", price: 0.38, vat: 21, step_size: 1 }],
        restrictions: { start_time: "07:00", end_time: "22:59", max_power: 100 },
      },
      {
        price_components: [{ type: "ENERGY", price: 0.33, vat: 21, step_size: 1 }],
        restrictions: { start_time: "00:00", end_time: "06:59", max_power: 100 },
      },
      {
        price_components: [{ type: "ENERGY", price: 0.48, vat: 21, step_size: 1 }],
        restrictions: { start_time: "07:00", end_time: "22:59", max_power: 450 },
      },
      {
        price_components: [{ type: "PARKING_TIME", price: 0.1, vat: 21, step_size: 60 }],
        restrictions: { min_duration: 3600 },
      },
    ],
  },
}];
const mediodia = { weekday: "MONDAY", minutes: 12 * 60 };
const madrugada = { weekday: "MONDAY", minutes: 3 * 60 };

Deno.test("precio con IVA según la hora y la potencia", () => {
  assertEquals(tariffNow(tarifa, 50, mediodia), { price: 0.46, extras: true });
  assertEquals(tariffNow(tarifa, 50, madrugada).price, 0.399);
  assertEquals(tariffNow(tarifa, 150, mediodia).price, 0.581);
  assertEquals(tariffNow([], 50, mediodia), { price: null, extras: false });
});

Deno.test("hora de Canarias", () => {
  // 20/11/2026 es viernes; en invierno Canarias va con UTC.
  assertEquals(canaryTime(new Date("2026-11-20T13:05:00Z")), { weekday: "FRIDAY", minutes: 13 * 60 + 5 });
  assertEquals(canaryTime(new Date("2026-07-01T13:05:00Z")).minutes, 14 * 60 + 5);
});

Deno.test("nombres y direcciones", () => {
  assertEquals(readableName("61945052640002"), null);
  assertEquals(readableName("ES*IBD*E12345"), null);
  assertEquals(readableName("C6E15BCC22GCAWPRRZ"), null);
  assertEquals(readableName("E-GC-CasasDeVeneguera-001"), "Casas De Veneguera");
  assertEquals(readableName("Hiperdino La Laguna"), "Hiperdino La Laguna");
  assertEquals(splitAddress("PCAN Los Realejos - Calle los Barros, 30A,"), {
    head: "PCAN Los Realejos",
    street: "Calle los Barros, 30A",
  });
  assertEquals(splitAddress("Calle Real, 1"), { head: null, street: "Calle Real, 1" });
});

Deno.test("una ubicación: estado, conectores y precio", () => {
  const loc = {
    id: "abc",
    name: "61945052640002",
    address: "PCAN Los Realejos - Calle los Barros, 30A,",
    postal_code: "38419",
    owner: { name: "ENDESA X WAY, S.L." },
    coordinates: { latitude: "28.390254", longitude: "-16.58176" },
    evses: [
      {
        status: "AVAILABLE",
        status_updated_at: "2026-11-19T11:42:04.712Z",
        connectors: [
          { standard: "IEC_62196_T2_COMBO", max_electric_power: 50000, tariffs: tarifa },
          { standard: "CHADEMO", max_electric_power: 50000, tariffs: tarifa },
        ],
      },
      {
        status: "OUTOFORDER",
        status_updated_at: "2026-11-20T08:00:00Z",
        connectors: [{ standard: "IEC_62196_T2_COMBO", max_electric_power: 50000, tariffs: tarifa }],
      },
      { status: "PLANNED", connectors: [{ standard: "IEC_62196_T2", max_electric_power: 22000 }] },
    ],
  };
  const s = parseLocation(loc, mediodia)!;
  assertEquals(s.name, "PCAN Los Realejos");
  assertEquals(s.operator, "ENDESA X WAY");
  assertEquals(s.address, "Calle los Barros, 30A");
  assertEquals(s.points, 2);
  assertEquals(s.available, 1);
  assertEquals(s.occupied, 0);
  assertEquals(s.out_of_order, 1);
  assertEquals(s.status, "operational");
  assertEquals(s.connectors.map((c) => [c.type, c.kw, c.quantity]), [["ccs", 50, 2], ["chademo", 50, 1]]);
  assertEquals(s.price_kwh, 0.46);
  assertEquals(s.extra_fees, true);
  assertEquals(s.source_updated, "2026-11-20T08:00:00Z");

  const averiada = parseLocation({ ...loc, evses: [loc.evses[1]] }, mediodia)!;
  assertEquals(averiada.status, "not_operational");
  assertEquals(parseLocation({ ...loc, evses: [loc.evses[2]] }, mediodia), null);
});
