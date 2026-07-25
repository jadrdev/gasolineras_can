import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:http/http.dart' as http;

class GasStationRepository {
  /// Carga estaciones dentro de un radio en kilómetros desde la ubicación dada.
  /// Por defecto busca en un radio de 16 km (vista cercana). Para favoritos
  /// se puede ampliar el radio para cubrir toda la región.
  Future<List<GasStation>> fetchStations(
    double lat,
    double lng, {
    int radiusKm = 16,
    int limit = 200,
  }) async {
    final url = Uri.parse(
      'https://api.precioil.es/estaciones/radio'
      '?latitud=$lat&longitud=$lng&radio=$radiusKm&limite=$limit&pagina=1',
    );

    debugPrint("🌐 Haciendo petición a: $url");
    
    try {
      final response = await http.get(url);
      
      debugPrint("📡 Status Code: ${response.statusCode}");
      debugPrint("📡 Headers: ${response.headers}");
      
      if (response.statusCode == 200) {
        debugPrint("✅ Respuesta exitosa");
        debugPrint("📄 Primeros 500 caracteres: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");
        
        final data = jsonDecode(response.body) as List;
        debugPrint("✅ JSON parseado correctamente. Total estaciones: ${data.length}");
        
        final estaciones = data.map((e) => GasStation.fromJson(e)).toList();
        debugPrint("✅ Estaciones mapeadas: ${estaciones.length}");
        return estaciones;
      } else {
        debugPrint("❌ Error HTTP ${response.statusCode}");
        debugPrint("❌ Cuerpo de respuesta: ${response.body}");
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Excepción capturada: $e");
      debugPrint("❌ Stack trace: $stackTrace");
      rethrow;
    }
  }
}
