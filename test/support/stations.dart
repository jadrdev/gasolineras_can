import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';

Map<String, dynamic> stationJson({int id = 1, String name = 'DISA SAN JOSÉ'}) =>
    {
      'idEstacion': id,
      'nombreEstacion': name,
      'direccion': 'AVENIDA DE LOS ÁLAMOS, 10',
      'latitud': 28.48,
      'longitud': -16.31,
      'marca': 'DISA',
      'nombreMunicipio': 'San Cristóbal de La Laguna',
      'localidad': 'LA CUESTA',
      'provincia': 'SANTA CRUZ DE TENERIFE',
      'Gasolina95': '1,459',
      'Diesel': 1.399,
      'lastUpdate': '2026-09-16 00:00:00',
    };

List<GasStation> sampleStations() => [
  GasStation.fromJson(stationJson()),
  GasStation.fromJson({
    ...stationJson(id: 2, name: 'REPSOL ARRECIFE'),
    'marca': 'REPSOL',
    'nombreMunicipio': 'Arrecife',
    'localidad': 'ARRECIFE',
    'latitud': 28.96,
    'longitud': -13.55,
    'provincia': 'PALMAS (LAS)',
    'Gasolina95': 1.509,
  }),
];
