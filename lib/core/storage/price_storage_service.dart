import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';

class PriceChange {
  final int stationId;
  final String stationName;
  final String fuelType;
  final double oldPrice;
  final double newPrice;
  final bool isPriceDecrease;

  PriceChange({
    required this.stationId,
    required this.stationName,
    required this.fuelType,
    required this.oldPrice,
    required this.newPrice,
    required this.isPriceDecrease,
  });

  double get priceChange => newPrice - oldPrice;
}

class PriceStorageService {
  static const String _pricesKey = 'gas_station_prices';
  static const String _lastLocationLatKey = 'last_location_lat';
  static const String _lastLocationLngKey = 'last_location_lng';
  static const String _lastUpdateKey = 'last_price_update';

  /// Guarda los precios actuales de las gasolineras
  Future<void> savePrices(List<GasStation> stations) async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, dynamic> pricesMap = {};
    for (var station in stations) {
      pricesMap[station.id.toString()] = {
        'nombre': station.nombre,
        'gasolina95': station.gasolina95,
        'gasolina98': station.gasolina98,
        'diesel': station.diesel,
        'dieselPremium': station.dieselPremium,
      };
    }
    
    await prefs.setString(_pricesKey, jsonEncode(pricesMap));
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  /// Recupera los precios guardados previamente
  Future<Map<int, Map<String, dynamic>>> getPreviousPrices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pricesJson = prefs.getString(_pricesKey);
    
    if (pricesJson == null) {
      return {};
    }
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(pricesJson);
      final Map<int, Map<String, dynamic>> result = {};
      
      decoded.forEach((key, value) {
        result[int.parse(key)] = Map<String, dynamic>.from(value);
      });
      
      return result;
    } catch (e) {
      return {};
    }
  }

  /// Detecta cambios entre precios actuales y previos
  Future<List<PriceChange>> detectChanges(
    List<GasStation> currentStations,
  ) async {
    final previousPrices = await getPreviousPrices();
    final List<PriceChange> changes = [];

    for (var station in currentStations) {
      final previousData = previousPrices[station.id];
      if (previousData == null) continue;

      final String stationName = previousData['nombre'] ?? station.nombre;

      // Verificar Gasolina 95
      if (station.gasolina95 != null && previousData['gasolina95'] != null) {
        final double prev = previousData['gasolina95'];
        final double curr = station.gasolina95!;
        if ((prev - curr).abs() > 0.001) {
          changes.add(PriceChange(
            stationId: station.id,
            stationName: stationName,
            fuelType: 'Gasolina 95',
            oldPrice: prev,
            newPrice: curr,
            isPriceDecrease: curr < prev,
          ));
        }
      }

      // Verificar Gasolina 98
      if (station.gasolina98 != null && previousData['gasolina98'] != null) {
        final double prev = previousData['gasolina98'];
        final double curr = station.gasolina98!;
        if ((prev - curr).abs() > 0.001) {
          changes.add(PriceChange(
            stationId: station.id,
            stationName: stationName,
            fuelType: 'Gasolina 98',
            oldPrice: prev,
            newPrice: curr,
            isPriceDecrease: curr < prev,
          ));
        }
      }

      // Verificar Diesel
      if (station.diesel != null && previousData['diesel'] != null) {
        final double prev = previousData['diesel'];
        final double curr = station.diesel!;
        if ((prev - curr).abs() > 0.001) {
          changes.add(PriceChange(
            stationId: station.id,
            stationName: stationName,
            fuelType: 'Diesel',
            oldPrice: prev,
            newPrice: curr,
            isPriceDecrease: curr < prev,
          ));
        }
      }

      // Verificar Diesel Premium
      if (station.dieselPremium != null && previousData['dieselPremium'] != null) {
        final double prev = previousData['dieselPremium'];
        final double curr = station.dieselPremium!;
        if ((prev - curr).abs() > 0.001) {
          changes.add(PriceChange(
            stationId: station.id,
            stationName: stationName,
            fuelType: 'Diesel Premium',
            oldPrice: prev,
            newPrice: curr,
            isPriceDecrease: curr < prev,
          ));
        }
      }
    }

    return changes;
  }

  /// Guarda la última ubicación conocida
  Future<void> saveLastLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastLocationLatKey, lat);
    await prefs.setDouble(_lastLocationLngKey, lng);
  }

  /// Obtiene la última ubicación conocida
  Future<Map<String, double>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final double? lat = prefs.getDouble(_lastLocationLatKey);
    final double? lng = prefs.getDouble(_lastLocationLngKey);
    
    if (lat == null || lng == null) {
      return null;
    }
    
    return {'lat': lat, 'lng': lng};
  }

  /// Obtiene la fecha de la última actualización de precios
  Future<DateTime?> getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dateStr = prefs.getString(_lastUpdateKey);
    
    if (dateStr == null) {
      return null;
    }
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// Limpia todos los datos guardados
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pricesKey);
    await prefs.remove(_lastLocationLatKey);
    await prefs.remove(_lastLocationLngKey);
    await prefs.remove(_lastUpdateKey);
  }
}
