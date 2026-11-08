import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gas_station.dart';

class StationCatalog {
  final List<GasStation> stations;
  final DateTime fetchedAt;
  final bool offline;
  const StationCatalog(this.stations, this.fetchedAt, {this.offline = false});
}

class GasStationRepository {
  static final http.Client _sharedClient = http.Client();
  final http.Client _client;
  GasStationRepository({http.Client? client})
    : _client = client ?? _sharedClient;
  static const _cacheKey = 'canaryStationCatalog.v1';
  static const _cacheLifetime = Duration(minutes: 10);

  /// This fixed center and 300 km radius cover the Canary Islands even when
  /// the user is elsewhere or has not granted location access.
  Future<StationCatalog> fetchCatalog({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    StationCatalog? cached;
    try {
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        cached = StationCatalog(
          _parseStations(json['stations']),
          DateTime.parse(json['fetchedAt'] as String),
        );
      }
    } catch (_) {
      // An old or damaged cache must not prevent a fresh request.
    }
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _cacheLifetime) {
      return cached;
    }
    try {
      final stations = await fetchStations(
        28.5,
        -15.8,
        radiusKm: 300,
        limit: 2000,
      );
      // The current API treats pagina as compatibility-only. Never silently
      // advertise a complete catalog when the response reaches its limit.
      if (stations.length >= 2000) {
        throw const FormatException(
          'El catálogo supera el límite de la consulta',
        );
      }
      if (stations.isEmpty) {
        throw const FormatException('El servicio no ha devuelto estaciones');
      }
      final catalog = StationCatalog(stations, DateTime.now());
      try {
        await prefs.setString(
          _cacheKey,
          jsonEncode({
            'fetchedAt': catalog.fetchedAt.toIso8601String(),
            'stations': stations.map((s) => s.toJson()).toList(),
          }),
        );
      } catch (_) {
        // A cache write failure should not discard usable network data.
      }
      return catalog;
    } catch (_) {
      if (cached != null && cached.stations.isNotEmpty) {
        return StationCatalog(cached.stations, cached.fetchedAt, offline: true);
      }
      rethrow;
    }
  }

  Future<List<GasStation>> fetchStations(
    double lat,
    double lng, {
    int radiusKm = 16,
    int limit = 2000,
  }) async {
    final url = Uri.https('api.precioil.es', '/estaciones/radio', {
      'latitud': '$lat',
      'longitud': '$lng',
      'radio': '$radiusKm',
      'limite': '$limit',
      'pagina': '1',
      'fields': 'current',
    });
    final response = await _client
        .get(url)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 404) return [];
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron cargar los precios (${response.statusCode}). Inténtalo de nuevo.',
      );
    }
    return _parseStations(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  List<GasStation> _parseStations(dynamic data) {
    if (data is! List) {
      throw const FormatException('Respuesta de estaciones inválida');
    }
    final stations = <int, GasStation>{};
    for (final row in data) {
      final station = GasStation.fromJson(
        Map<String, dynamic>.from(row as Map),
      );
      stations[station.id] = station;
    }
    return stations.values.toList();
  }
}
