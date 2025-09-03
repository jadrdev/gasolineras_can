import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:gasolineras_can/features/directions/domain/directions_repository.dart';

class DirectionsService implements DirectionsRepository {
  final String apiKey;

  DirectionsService(this.apiKey);

  /// Obtiene la ruta en coche entre dos puntos (origen/destino)
  @override
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception('Error al obtener la ruta: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);

    if (data['routes'] == null || data['routes'].isEmpty) {
      throw Exception('No se encontr\u00f3 ruta disponible');
    }

    final points = data['routes'][0]['overview_polyline']['points'];
    return _decodePolyline(points);
  }

  /// Decodifica el polyline de Google Directions API
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}
