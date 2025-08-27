import 'package:geolocator/geolocator.dart';

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Servicio de ubicación deshabilitado.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Permiso de ubicación denegado permanentemente.');
  }

  return await Geolocator.getCurrentPosition();
}
