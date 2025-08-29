import 'package:geolocator/geolocator.dart';

class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);

  @override
  String toString() => message;
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw LocationPermissionException("El GPS está desactivado");
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw LocationPermissionException("Permiso de ubicación denegado");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw LocationPermissionException(
      "Permiso de ubicación denegado permanentemente",
    );
  }

  return await Geolocator.getCurrentPosition();
}
