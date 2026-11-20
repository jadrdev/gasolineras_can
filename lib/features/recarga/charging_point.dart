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
    this.priceKwh,
  });

  final ConnectorKind kind;
  final String label;
  final double? kw;
  final int quantity;

  /// €/kWh con IVA de este conector ahora (solo en los de Red Eléctrica).
  final double? priceKwh;

  factory ChargingConnector.fromJson(Map<String, dynamic> json) =>
      ChargingConnector(
        kind: ConnectorKind.values.firstWhere(
          (k) => k.name == json['type'],
          orElse: () => ConnectorKind.other,
        ),
        label: (json['label'] as String?)?.trim() ?? '',
        kw: (json['kw'] as num?)?.toDouble(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        priceKwh: (json['price_kwh'] as num?)?.toDouble(),
      );
}

enum ChargingStatus { operational, notOperational, unknown }

/// De dónde salen los datos de un punto (y de su precio).
/// reve: mapaREVE de Red Eléctrica, precio publicado por el operador.
/// ocm: Open Charge Map (CC BY 4.0), precio aportado por la comunidad.
enum ChargingSource { reve, ocm }

ChargingSource? _source(Object? value) => switch (value) {
  'reve' => ChargingSource.reve,
  'ocm' => ChargingSource.ocm,
  _ => null,
};

/// Punto de recarga de coches eléctricos e híbridos enchufables, de la tabla
/// charging_stations: Red Eléctrica (mapaREVE) y, donde no llega, Open
/// Charge Map. La junta cada hora la función charging-stations.
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
    this.source = ChargingSource.ocm,
    this.priceSource,
    this.available,
    this.occupied,
    this.outOfOrder,
    this.extraFees = false,
    this.syncedAt,
  });

  final String id;
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

  /// €/kWh con IVA (el conector más barato). De quién es: [priceSource].
  final double? priceKwh;
  final bool free;

  /// Texto original del precio, por si no se pudo leer como €/kWh.
  final String? usageCost;

  /// Última actualización en la fuente (REVE u Open Charge Map).
  final DateTime? updated;

  final ChargingSource source;
  final ChargingSource? priceSource;

  /// Cargadores libres ahora mismo (solo Red Eléctrica).
  final int? available;

  /// Cargadores cargando, bloqueados o reservados ahora (solo Red Eléctrica).
  final int? occupied;

  /// Cargadores averiados ahora (solo Red Eléctrica).
  final int? outOfOrder;

  /// El operador cobra también por tiempo, por conexión o por aparcar.
  final bool extraFees;

  /// Cuándo los bajó GasoCan de la fuente.
  final DateTime? syncedAt;

  /// Distancia en km desde la posición del usuario (en línea recta).
  double? distance;

  /// Carga rápida: 50 kW o más.
  bool get fast => (maxKw ?? 0) >= 50;

  /// Precio para ordenar: gratis primero y sin precio al final.
  double get sortPrice => free ? 0 : (priceKwh ?? double.infinity);

  bool has(ConnectorKind kind) => connectors.any((c) => c.kind == kind);

  factory ChargingPoint.fromJson(Map<String, dynamic> json) => ChargingPoint(
    id: json['id'].toString(),
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
    updated: DateTime.tryParse(
      (json['source_updated'] ?? json['ocm_updated']) as String? ?? '',
    ),
    source: _source(json['source']) ?? ChargingSource.ocm,
    priceSource: _source(json['price_source']),
    available: (json['available'] as num?)?.toInt(),
    occupied: (json['occupied'] as num?)?.toInt(),
    outOfOrder: (json['out_of_order'] as num?)?.toInt(),
    extraFees: json['extra_fees'] == true,
    syncedAt: DateTime.tryParse(json['synced_at'] as String? ?? ''),
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

/// Lee los puntos de recarga de Supabase. Son ~1.000 en Canarias y se
/// actualizan cada 15 minutos, así que se guardan en memoria 5 minutos.
class ChargingRepository {
  ChargingRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  static List<ChargingPoint>? _cache;
  static DateTime? _cachedAt;

  Future<List<ChargingPoint>> all({bool forceRefresh = false}) async {
    final fresh =
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < const Duration(minutes: 5);
    if (!forceRefresh && fresh && _cache != null) return _cache!;
    final client = _client ?? Supabase.instance.client;
    // Supabase da como mucho 1.000 filas por petición: se piden por páginas.
    const page = 1000;
    final rows = <Map<String, dynamic>>[];
    while (true) {
      final batch = await client
          .from('charging_stations')
          .select(
            'id, source, name, operator, address, town, latitude, longitude, '
            'connectors, max_kw, points, available, occupied, out_of_order, '
            'status, price_kwh, free, price_source, extra_fees, usage_cost, '
            'source_updated, synced_at',
          )
          .order('id')
          .range(rows.length, rows.length + page - 1);
      rows.addAll(batch);
      if (batch.length < page || rows.length >= 10000) break;
    }
    _cache = rows.map(ChargingPoint.fromJson).toList();
    _cachedAt = DateTime.now();
    lastReveSync = _cache!
        .where((p) => p.source == ChargingSource.reve)
        .map((p) => p.syncedAt)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
    return _cache!;
  }

  /// Última vez que se bajaron los datos de Red Eléctrica (para citarla).
  static DateTime? lastReveSync;
}
