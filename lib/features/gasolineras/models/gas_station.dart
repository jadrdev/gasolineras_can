import 'dart:math';

class GasStation {
  final int id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String marca;
  final double? gasolina95;
  final double? diesel;
  double? distancia; // ✅ Nuevo campo

  GasStation({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.marca,
    this.gasolina95,
    this.diesel,
    this.distancia,
  });

  factory GasStation.fromJson(Map<String, dynamic> json) {
    return GasStation(
      id: int.parse(json["idEstacion"].toString()),
      nombre: json["nombreEstacion"] ?? "",
      direccion: json["direccion"] ?? "",
      latitud: double.tryParse(json["latitud"].toString()) ?? 0.0,
      longitud: double.tryParse(json["longitud"].toString()) ?? 0.0,
      marca: json["marca"] ?? "",
      gasolina95: json["Gasolina95"] != null
          ? double.tryParse(json["Gasolina95"].toString())
          : null,
      diesel: json["Diesel"] != null
          ? double.tryParse(json["Diesel"].toString())
          : null,
    );
  }

  void calcularDistancia(double userLat, double userLng) {
    const R = 6371; // km
    final dLat = _deg2rad(latitud - userLat);
    final dLng = _deg2rad(longitud - userLng);
    final a = (sin(dLat/2) * sin(dLat/2)) +
              cos(_deg2rad(userLat)) * cos(_deg2rad(latitud)) *
              (sin(dLng/2) * sin(dLng/2));
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    distancia = R * c;
  }

  double _deg2rad(double deg) => deg * pi / 180;
}

