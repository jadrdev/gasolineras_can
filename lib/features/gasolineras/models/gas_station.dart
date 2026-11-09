import 'package:gasolineras_can/core/format.dart';
import 'dart:math';

import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';

class GasStation {
  final int id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String marca;
  final String municipio;
  final String localidad;
  final String provincia;
  final double? gasolina95;
  final double? gasolina98;
  final double? diesel;
  final double? dieselPremium;
  final DateTime? lastUpdate;
  double? distancia; // ✅ Nuevo campo

  GasStation({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.marca,
    this.municipio = '',
    this.localidad = '',
    this.provincia = '',
    this.gasolina95,
    this.gasolina98,
    this.diesel,
    this.dieselPremium,
    this.lastUpdate,
    this.distancia,
  });

  static double? _number(Object? value) =>
      double.tryParse(value.toString().replaceAll(',', '.'));

  static double? _price(Object? value) {
    final price = _number(value);
    return price != null && price.isFinite && price > 0 ? price : null;
  }

  factory GasStation.fromJson(Map<String, dynamic> json) {
    final lat = _number(json['latitud']);
    final lng = _number(json['longitud']);
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat.abs() > 90 ||
        lng.abs() > 180) {
      throw const FormatException('Coordenadas de estación inválidas');
    }
    return GasStation(
      id: int.parse(json['idEstacion'].toString()),
      nombre: nombrePropio(json['nombreEstacion']?.toString() ?? ''),
      direccion: nombrePropio(json['direccion']?.toString() ?? ''),
      latitud: lat,
      longitud: lng,
      marca: nombrePropio(json['marca']?.toString() ?? ''),
      municipio: nombrePropio(
        (json['nombreMunicipio'] ?? json['municipio'])?.toString() ?? '',
      ),
      localidad: nombrePropio(json['localidad']?.toString() ?? ''),
      provincia:
          (json['provincia'] ?? json['provinciaDistrito'])?.toString() ?? '',
      gasolina95: _price(json['Gasolina95']),
      gasolina98: _price(json['Gasolina98']),
      diesel: _price(json['Diesel']),
      dieselPremium: _price(json['DieselPremium']),
      lastUpdate: DateTime.tryParse(
        (json['lastUpdate'] ?? json['updatedAt'] ?? '').toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'idEstacion': id,
    'nombreEstacion': nombre,
    'direccion': direccion,
    'latitud': latitud,
    'longitud': longitud,
    'marca': marca,
    'nombreMunicipio': municipio,
    'localidad': localidad,
    'provincia': provincia,
    'Gasolina95': gasolina95,
    'Gasolina98': gasolina98,
    'Diesel': diesel,
    'DieselPremium': dieselPremium,
    'lastUpdate': lastUpdate?.toIso8601String(),
  };

  /// Precio del combustible identificado por [type], o `null` si no disponible.
  double? priceFor(FuelType type) {
    switch (type) {
      case FuelType.g95:
        return gasolina95;
      case FuelType.g98:
        return gasolina98;
      case FuelType.diesel:
        return diesel;
      case FuelType.dieselPremium:
        return dieselPremium;
    }
  }

  void calcularDistancia(double userLat, double userLng) {
    const R = 6371; // km
    final dLat = _deg2rad(latitud - userLat);
    final dLng = _deg2rad(longitud - userLng);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(userLat)) *
            cos(_deg2rad(latitud)) *
            (sin(dLng / 2) * sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    distancia = R * c;
  }

  double _deg2rad(double deg) => deg * pi / 180;
}
