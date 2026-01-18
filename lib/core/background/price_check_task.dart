import 'package:flutter/foundation.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/core/storage/price_storage_service.dart';
import 'package:gasolineras_can/core/notifications/notification_service.dart';

/// Tarea ejecutada en background para verificar cambios de precios
class PriceCheckTask {
  static Future<void> execute() async {
    try {
      debugPrint('🔄 [Background] Iniciando verificación de precios...');
      
      final priceStorage = PriceStorageService();
      
      // Obtener última ubicación conocida
      final location = await priceStorage.getLastLocation();
      
      if (location == null) {
        debugPrint('⚠️ [Background] No hay ubicación guardada. Cancelando verificación.');
        return;
      }
      
      final double lat = location['lat']!;
      final double lng = location['lng']!;
      
      debugPrint('📍 [Background] Usando ubicación: $lat, $lng');
      
      // Obtener precios actuales de la API
      final repository = GasStationRepository();
      final currentStations = await repository.fetchStations(lat, lng);
      
      debugPrint('✅ [Background] Obtenidas ${currentStations.length} estaciones');
      
      // Detectar cambios comparando con precios previos
      final changes = await priceStorage.detectChanges(currentStations);
      
      debugPrint('🔍 [Background] Detectados ${changes.length} cambios de precio');
      
      if (changes.isNotEmpty) {
        // Contar cuántos cambios son bajadas de precio
        final decreaseCount = changes.where((c) => c.isPriceDecrease).length;
        
        // Crear mensaje de notificación
        String details;
        if (changes.length <= 3) {
          // Si hay pocos cambios, mostrarlos todos
          details = changes.map((change) {
            final symbol = change.isPriceDecrease ? '📉' : '📈';
            return '$symbol ${change.stationName}: ${change.fuelType} ${change.newPrice.toStringAsFixed(3)}€';
          }).join('\n');
        } else {
          // Si hay muchos cambios, resumir
          final decreases = changes.where((c) => c.isPriceDecrease).toList();
          if (decreases.isNotEmpty) {
            final bestDecrease = decreases.reduce((a, b) => 
              a.priceChange < b.priceChange ? a : b
            );
            details = '📉 ${bestDecrease.stationName}: ${bestDecrease.fuelType} '
                     '${bestDecrease.newPrice.toStringAsFixed(3)}€ '
                     '(${(bestDecrease.priceChange * -1000).toStringAsFixed(0)}¢ menos)';
            if (changes.length > 1) {
              details += '\n... y ${changes.length - 1} cambios más';
            }
          } else {
            details = 'Se detectaron ${changes.length} cambios de precio';
          }
        }
        
        // Enviar notificación
        await NotificationService.showPriceChangeNotification(
          changesCount: changes.length,
          decreaseCount: decreaseCount,
          details: details,
        );
        
        debugPrint('📱 [Background] Notificación enviada');
      }
      
      // Guardar los nuevos precios para la próxima comparación
      await priceStorage.savePrices(currentStations);
      
      debugPrint('✅ [Background] Verificación completada');
      
    } catch (e, stackTrace) {
      debugPrint('❌ [Background] Error en verificación de precios: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}
