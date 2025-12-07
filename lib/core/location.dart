import 'package:geolocator/geolocator.dart';

class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);

  @override
  String toString() => message;
}

// Cache para la última ubicación conocida
class _LocationCache {
  Position? position;
  DateTime? timestamp;
  
  bool isValid() {
    if (position == null || timestamp == null) return false;
    
    // Cache válido solo si tiene menos de 2 minutos
    final age = DateTime.now().difference(timestamp!);
    return age.inMinutes < 2;
  }
  
  void update(Position pos) {
    position = pos;
    timestamp = DateTime.now();
  }
  
  void clear() {
    position = null;
    timestamp = null;
  }
}

final _locationCache = _LocationCache();

/// Obtiene la posición actual, usando caché si está disponible y es reciente
/// [forceRefresh] fuerza una actualización ignorando el caché
Future<Position> determinePosition({bool forceRefresh = false}) async {
  // Si no se fuerza refresh y tenemos caché válido, usarlo
  if (!forceRefresh && _locationCache.isValid()) {
    // Intentar obtener posición actual en background para actualizar caché
    _updateCacheInBackground();
    return _locationCache.position!;
  }

  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Si hay caché, devolverlo aunque esté expirado
    if (_locationCache.position != null) {
      return _locationCache.position!;
    }
    throw LocationPermissionException("Los servicios de ubicación están desactivados. Por favor, activa el GPS en tu dispositivo.");
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Si hay caché, devolverlo aunque esté expirado
      if (_locationCache.position != null) {
        return _locationCache.position!;
      }
      throw LocationPermissionException("Permiso de ubicación denegado. Por favor, permite el acceso a la ubicación para continuar.");
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Si hay caché, devolverlo aunque esté expirado
    if (_locationCache.position != null) {
      return _locationCache.position!;
    }
    throw LocationPermissionException(
      "Permiso de ubicación denegado permanentemente. Ve a configuración y permite el acceso a la ubicación para esta aplicación.",
    );
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    
    // Actualizar caché con la nueva posición
    _locationCache.update(position);
    return position;
  } catch (e) {
    // Si hay caché, devolverlo aunque esté expirado
    if (_locationCache.position != null) {
      return _locationCache.position!;
    }
    throw LocationPermissionException("Error al obtener la ubicación: ${e.toString()}");
  }
}

/// Actualiza el caché en background sin bloquear
void _updateCacheInBackground() async {
  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
    
    // Solo actualizar si el usuario se ha movido significativamente (>500m)
    if (_locationCache.position != null) {
      final distance = Geolocator.distanceBetween(
        _locationCache.position!.latitude,
        _locationCache.position!.longitude,
        position.latitude,
        position.longitude,
      );
      
      // Si se movió más de 500m, actualizar caché
      if (distance > 500) {
        _locationCache.update(position);
      }
    } else {
      _locationCache.update(position);
    }
  } catch (e) {
    // Ignorar errores en actualización background
  }
}
