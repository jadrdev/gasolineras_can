import 'package:gasolineras_can/core/format.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gasolineras_can/core/notifications/notification_service.dart';
import 'package:gasolineras_can/features/auth/user_profile_repository.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que comprueba periódicamente si las gasolineras favoritas han
/// bajado de precio y lanza notificaciones locales cuando eso ocurre.
///
/// También guarda el último precio conocido en `SharedPreferences` para poder
/// comparar en la siguiente ejecución.
class PriceAlertService {
  static const _prefsKey = 'priceAlertSnapshots';

  final FavoriteRepository _favoriteRepository;
  final GasStationRepository _stationRepository;

  Timer? _timer;
  bool _checking = false;

  PriceAlertService({
    FavoriteRepository? favoriteRepository,
    GasStationRepository? stationRepository,
  }) : _favoriteRepository = favoriteRepository ?? FavoriteRepository(),
       _stationRepository = stationRepository ?? GasStationRepository();

  /// Inicia comprobaciones periódicas cada [interval]. El primer check se hace
  /// tras el primer intervalo para no ralentizar el arranque de la app.
  void start({Duration interval = const Duration(minutes: 30)}) {
    stop();
    _timer = Timer.periodic(interval, (_) => checkPriceDrops());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Ejecuta una única comprobación de bajadas de precio. Es pública para
  /// poder probarla o llamarla manualmente (pull-to-refresh, botón, etc.).
  ///
  /// Si [simulateDrop] es `true`, fuerza una bajada ficticia de 0,10 €/L
  /// sobre cada favorito para poder comprobar que la notificación funciona.
  Future<void> checkPriceDrops({bool simulateDrop = false}) async {
    if (_checking) return;
    _checking = true;
    try {
      final repo = UserProfileRepository();
      final user = repo.currentUser;
      if (user == null) {
        debugPrint('🔕 PriceAlert: no hay usuario autenticado');
        return;
      }

      final profile = await UserProfileRepository().getProfile();
      final preferredFuel = profile?.preferredFuel ?? FuelType.g95;

      final favoriteIds = await _favoriteRepository.getFavorites();
      debugPrint('⭐ PriceAlert: favoritos=$favoriteIds');
      if (favoriteIds.isEmpty) {
        debugPrint('🔕 PriceAlert: no hay favoritos');
        return;
      }

      final catalog = await _stationRepository.fetchCatalog(forceRefresh: true);
      // Cached prices must never trigger a new-price alert.
      if (catalog.offline) return;
      final stations = catalog.stations;
      final snapshots = await _loadSnapshots(user.id);
      final newSnapshots = Map<int, Map<String, double>>.from(snapshots)
        ..removeWhere((id, _) => !favoriteIds.contains(id));

      for (final station in stations) {
        if (repo.currentUser?.id != user.id) return;
        if (!favoriteIds.contains(station.id)) continue;

        final price = station.priceFor(preferredFuel);
        if (price == null) continue;

        final previousPrice = simulateDrop
            ? price + 0.10
            : snapshots[station.id]?[preferredFuel.name];

        debugPrint(
          '💰 PriceAlert: ${station.nombre} ${preferredFuel.name} '
          'antes=${previousPrice?.toStringAsFixed(3)} ahora=${price.toStringAsFixed(3)}',
        );

        newSnapshots[station.id] = {
          ...?snapshots[station.id],
          preferredFuel.name: price,
        };

        if (previousPrice != null && price < previousPrice) {
          final drop = previousPrice - price;
          await NotificationService.showNotification(
            id: station.id,
            title: '⛽ ¡Bajó el precio!',
            body:
                '${station.nombre}: ${preferredFuel.displayName} ahora a ${decimal(price, 3)} €/L '
                '(bajó ${decimal(drop, 3)} €)',
          );
          debugPrint(
            '🔔 PriceAlert: notificación enviada para ${station.nombre}',
          );
        }
      }

      if (repo.currentUser?.id == user.id) {
        await _saveSnapshots(user.id, newSnapshots);
      }
    } catch (e, stack) {
      debugPrint('❌ PriceAlert: error en checkPriceDrops: $e');
      debugPrint(stack.toString());
    } finally {
      _checking = false;
    }
  }

  Future<Map<int, Map<String, double>>> _loadSnapshots(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefsKey:$userId');
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) {
        final id = int.parse(key);
        final fuelMap = (value as Map<String, dynamic>).map(
          (fuelName, price) => MapEntry(fuelName, (price as num).toDouble()),
        );
        return MapEntry(id, fuelMap);
      });
    } catch (e) {
      debugPrint('⚠️ PriceAlert: error leyendo snapshots: $e');
      return {};
    }
  }

  Future<void> _saveSnapshots(
    String userId,
    Map<int, Map<String, double>> snapshots,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = snapshots.map(
      (id, fuelMap) => MapEntry(
        id.toString(),
        fuelMap.map((fuelName, price) => MapEntry(fuelName, price)),
      ),
    );
    await prefs.setString('$_prefsKey:$userId', jsonEncode(encoded));
  }
}
