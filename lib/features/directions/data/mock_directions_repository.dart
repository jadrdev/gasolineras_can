import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/directions_repository.dart';

/// Mock que genera una ruta "zigzag" entre dos puntos.
/// Útil para pruebas sin API de Google Directions.
class MockDirectionsRepository implements DirectionsRepository {
  @override
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    // simulamos red
    await Future.delayed(const Duration(seconds: 1));

    final points = <LatLng>[];
    const steps = 10;
    final latStep = (destination.latitude - origin.latitude) / steps;
    final lngStep = (destination.longitude - origin.longitude) / steps;

    final random = Random();

    for (int i = 0; i <= steps; i++) {
      final lat = origin.latitude + latStep * i;
      final lng = origin.longitude + lngStep * i;

      // añadimos un pequeño zigzag para simular carretera
      final offsetLat = (random.nextDouble() - 0.5) / 1000;
      final offsetLng = (random.nextDouble() - 0.5) / 1000;

      points.add(LatLng(lat + offsetLat, lng + offsetLng));
    }

    return points;
  }
}
