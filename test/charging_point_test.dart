import 'package:flutter_test/flutter_test.dart';
import 'package:gasolineras_can/features/recarga/charging_point.dart';

void main() {
  Map<String, dynamic> fila({
    int id = 1,
    num? price,
    bool free = false,
    num? maxKw,
    String status = 'operational',
  }) => {
    'id': id,
    'name': 'IBERDROLA LA LAGUNA',
    'operator': 'Iberdrola',
    'address': 'Calle Real, 1',
    'town': 'La Laguna',
    'latitude': 28.48,
    'longitude': -16.31,
    'connectors': [
      {'type': 'ccs', 'label': 'CCS (Type 2)', 'kw': 50, 'quantity': 2},
      {
        'type': 'type2',
        'label': 'Type 2 (Socket Only)',
        'kw': 22,
        'quantity': 1,
      },
    ],
    'max_kw': maxKw,
    'points': 3,
    'status': status,
    'price_kwh': price,
    'free': free,
    'usage_cost': '0,39€/kWh',
    'ocm_updated': '2025-10-01T10:00:00Z',
  };

  test('lee una fila de charging_points', () {
    final p = ChargingPoint.fromJson(fila(price: 0.39, maxKw: 50));
    expect(p.name, 'Iberdrola La Laguna');
    expect(p.priceKwh, 0.39);
    expect(p.fast, isTrue);
    expect(p.has(ConnectorKind.ccs), isTrue);
    expect(p.has(ConnectorKind.chademo), isFalse);
    expect(p.connectors.first.quantity, 2);
    expect(p.status, ChargingStatus.operational);
  });

  test('gratis primero y sin precio al final', () {
    final caro = ChargingPoint.fromJson(fila(id: 1, price: 0.55));
    final gratis = ChargingPoint.fromJson(fila(id: 2, free: true));
    final sinPrecio = ChargingPoint.fromJson(fila(id: 3));
    final lista = [sinPrecio, caro, gratis]
      ..sort((a, b) => a.sortPrice.compareTo(b.sortPrice));
    expect(lista.map((p) => p.id), [2, 1, 3]);
  });

  test('distancia en línea recta', () {
    final p = ChargingPoint.fromJson(fila());
    p.calcDistance(28.4636, -16.2518); // Santa Cruz
    expect(p.distance, closeTo(6.1, 0.5));
  });
}
