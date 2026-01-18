import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:gasolineras_can/core/background/price_check_task.dart';

/// Servicio para configurar y gestionar tareas en background
class BackgroundTaskService {
  static const String _priceCheckTaskName = 'price_check_task';
  static const String _uniqueTaskId = 'price_check_periodic';

  /// Inicializa el WorkManager
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      debugPrint('✅ WorkManager inicializado');
    } catch (e) {
      debugPrint('❌ Error inicializando WorkManager: $e');
    }
  }

  /// Registra la tarea periódica de verificación de precios
  /// Se ejecutará cada 30 minutos
  static Future<void> registerPriceCheckTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        _uniqueTaskId,
        _priceCheckTaskName,
        frequency: const Duration(minutes: 30),
        constraints: Constraints(
          networkType: NetworkType.connected, // Requiere conexión a internet
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      debugPrint('✅ Tarea periódica de verificación de precios registrada');
    } catch (e) {
      debugPrint('❌ Error registrando tarea periódica: $e');
    }
  }

  /// Cancela la tarea periódica de verificación de precios
  static Future<void> cancelPriceCheckTask() async {
    try {
      await Workmanager().cancelByUniqueName(_uniqueTaskId);
      debugPrint('✅ Tarea periódica cancelada');
    } catch (e) {
      debugPrint('❌ Error cancelando tarea: $e');
    }
  }

  /// Ejecuta una verificación inmediata (útil para testing)
  static Future<void> runPriceCheckNow() async {
    try {
      await Workmanager().registerOneOffTask(
        'price_check_immediate',
        _priceCheckTaskName,
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      debugPrint('✅ Verificación inmediata programada');
    } catch (e) {
      debugPrint('❌ Error programando verificación inmediata: $e');
    }
  }
}

/// Dispatcher que ejecuta las tareas en background
/// IMPORTANTE: Esta función debe ser top-level (no puede estar dentro de una clase)
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🚀 [Background] Ejecutando tarea: $task');
    
    try {
      switch (task) {
        case BackgroundTaskService._priceCheckTaskName:
          await PriceCheckTask.execute();
          break;
        default:
          debugPrint('⚠️ [Background] Tarea desconocida: $task');
      }
      
      return Future.value(true);
    } catch (e) {
      debugPrint('❌ [Background] Error en tarea $task: $e');
      return Future.value(false);
    }
  });
}
