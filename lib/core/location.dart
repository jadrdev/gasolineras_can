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

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw LocationPermissionException("Los servicios de ubicación están desactivados. Por favor, activa el GPS en tu dispositivo.");
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw LocationPermissionException("Permiso de ubicación denegado. Por favor, permite el acceso a la ubicación para continuar.");
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    throw LocationPermissionException(
      "Permiso de ubicación denegado permanentemente. Ve a configuración y permite el acceso a la ubicación para esta aplicación.",
    );
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  } catch (e) {
    throw LocationPermissionException("Error al obtener la ubicación: ${e.toString()}");
  }
}
