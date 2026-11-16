import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/format.dart';

/// Tipo de conector simplificado (lo calcula charging-sync en el servidor).
enum ConnectorKind { type2, ccs, chademo, tesla, type1, schuko, other }

class ChargingConnector {
  const ChargingConnector({
    required this.kind,
    required this.label,
    this.kw,
    this.quantity = 1,
  });

  final ConnectorKind kind;
  final String label;
  final double? kw;
  final int quantity;

  factory ChargingConnector.fromJson(Map<String, dynamic> json) =>
      ChargingConnector(
        kind: ConnectorKind.values.firstWhere(
          (k) => k.name == json['type'],
          orElse: () => ConnectorKind.other,
        ),
        label: (json['label'] as String?)?.trim() ?? '',
        kw: (json['kw'] as num?)?.toDouble(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
}

enum ChargingStatus { operational, notOperational, unknown }

/// Punto de recarga de coches eléctricos e híbridos enchufables, de Open
/// Charge Map (CC BY 4.0) a través de la tabla charging_points.
class ChargingPoint {
  ChargingPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.operator,
    this.address,
    this.town,
    this.connectors = const [],
    this.maxKw,
    this.points,
    this.status = ChargingStatus.unknown,
    this.priceKwh,
    this.free = false,
    this.usageCost,
    this.updated,
  });

  final int id;
  final String name;
  final String? operator;
  final String? address;
  final String? town;
  final double latitude;
  final double longitude;
  final List<ChargingConnector> connectors;
  final double? maxKw;
  final int? points;
  final ChargingStatus status;

  /// Precio orientativo en €/kWh, aportado por la comunidad.
  final double? priceKwh;
  final bool free;

  /// Texto original del precio, por si no se pudo leer como €/kWh.
  final String? usageCost;
  final DateTime? updated;

  /// Distancia en km desde la posición del usuario (en línea recta).
  double? distance;

  /// Carga rápida: 50 kW o más.
  bool get fast => (maxKw ?? 0) >= 50;

  /// Precio para ordenar: gratis primero y sin precio al final.
  double get sortPrice => free ? 0 : (priceKwh ?? double.infinity);

  bool has(ConnectorKind kind) => connectors.any((c) => c.kind == kind);

  factory ChargingPoint.fromJson(Map<String, dynamic> json) => ChargingPoint(
    id: (json['id'] as num).toInt(),
    name: nombrePropio((json['name'] as String?)?.trim() ?? ''),
    operator: json['operator'] as String?,
    address: (json['address'] as String?)?.trim(),
    town: (json['town'] as String?)?.trim(),
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    connectors: ((json['connectors'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ChargingConnector.fromJson)
        .toList(),
    maxKw: (json['max_kw'] as num?)?.toDouble(),
    points: (json['points'] as num?)?.toInt(),
    status: switch (json['status']) {
      'operational' => ChargingStatus.operational,
      'not_operational' => ChargingStatus.notOperational,
      _ => ChargingStatus.unknown,
    },
    priceKwh: (json['price_kwh'] as num?)?.toDouble(),
    free: json['free'] == true,
    usageCost: (json['usage_cost'] as String?)?.trim(),
    updated: DateTime.tryParse(json['ocm_updated'] as String? ?? ''),
  );

  void calcDistance(double lat, double lon) {
    const r = 6371.0;
    double rad(double d) => d * pi / 180;
    final dLat = rad(latitude - lat);
    final dLon = rad(longitude - lon);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(rad(lat)) * cos(rad(latitude)) * sin(dLon / 2) * sin(dLon / 2);
    distance = r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}

/// Lee los puntos de recarga de Supabase. Son ~900 en Canarias y cambian una
/// vez al día, así que se guardan en memoria una hora.
class ChargingRepository {
  ChargingRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  static List<ChargingPoint>? _cache;
  static DateTime? _cachedAt;

  Future<List<ChargingPoint>> all({bool forceRefresh = false}) async {
    final fresh =
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < const Duration(hours: 1);
    if (!forceRefresh && fresh && _cache != null) return _cache!;
    final client = _client ?? Supabase.instance.client;
    final rows = await client
        .from('charging_points')
        .select(
          'id, name, operator, address, town, latitude, longitude, connectors, '
          'max_kw, points, status, price_kwh, free, usage_cost, ocm_updated',
        )
        .limit(5000);
    _cache = rows.map(ChargingPoint.fromJson).toList();
    _cachedAt = DateTime.now();
    return _cache!;
  }
}
