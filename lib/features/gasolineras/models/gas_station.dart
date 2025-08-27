class GasStation {
  final int id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String marca;
  final double? gasolina95;
  final double? diesel;

  GasStation({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.marca,
    this.gasolina95,
    this.diesel,
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
}