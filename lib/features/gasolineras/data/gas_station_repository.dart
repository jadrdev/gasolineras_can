import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:http/http.dart' as http;

class GasStationRepository {
  Future<List<GasStation>> fetchStations(double lat, double lng) async {
    final url = Uri.parse(
      'https://api.precioil.es/estaciones/radio'
      '?latitud=$lat&longitud=$lng&radio=16&limite=200&pagina=1',
    );

    final response = await http.get(url);
   

    if (response.statusCode == 200) {
      debugPrint("👉 Respuesta cruda: ${response.body}");
      final data = jsonDecode(response.body) as List;
       debugPrint("👉 Data parseada: $data");
      final estaciones = data.map((e) => GasStation.fromJson(e)).toList();
      return estaciones;
    } else {
      throw Exception('Error cargando estaciones: ${response.statusCode}');
    }
  }
}
