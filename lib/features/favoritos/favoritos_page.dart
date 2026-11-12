import 'package:gasolineras_can/core/format.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../auth/user_profile_repository.dart';
import 'presentacion.dart';
import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/details/gas_station_details.dart';
import 'package:gasolineras_can/core/directions_service.dart';
import 'package:gasolineras_can/core/config.dart';
import 'package:gasolineras_can/core/location.dart';
import 'package:gasolineras_can/l10n/l10n.dart';

class FavoritesPage extends StatefulWidget {
  final FavoriteRepository repository;
  const FavoritesPage({super.key, required this.repository});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _gasStationRepo = GasStationRepository();
  List<GasStation> _allStations = [];
  List<int> _favoriteIds = [];
  bool _isLoading = true;
  bool _offline = false;
  String? _error;
  FuelType _fuel = FuelType.g95;
  double _tankLiters = 50;
  StreamSubscription<List<int>>? _favoritesSubscription;
  StreamSubscription<void>? _profileSubscription;
  int _generation = 0;
  int _favoritesRevision = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _favoritesSubscription = widget.repository.favoritesStream().listen(
      (ids) {
        if (!mounted) return;
        _favoritesRevision++;
        setState(() => _favoriteIds = ids);
        if (ids.any((id) => !_allStations.any((station) => station.id == id))) {
          _loadData(favoriteIds: ids);
        }
      },
      onError: (Object error) {
        if (mounted) {
          setState(() => _error = context.l10n.favUpdateError);
        }
      },
    );
    _profileSubscription = UserProfileRepository.changes.listen(
      (_) => _loadData(),
    );
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData({
    bool forceRefresh = false,
    List<int>? favoriteIds,
  }) async {
    final generation = ++_generation;
    final favoritesRevision = _favoritesRevision;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ids = favoriteIds ?? await widget.repository.getFavorites();
      final catalog = ids.isEmpty
          ? null
          : await _gasStationRepo.fetchCatalog(forceRefresh: forceRefresh);
      UserProfile? profile;
      try {
        profile = await UserProfileRepository().getProfile();
      } catch (_) {
        /* Keep preferences when offline. */
      }
      if (!mounted || generation != _generation) return;
      setState(() {
        // A newer realtime event (for example a deletion) wins over this request.
        if (favoritesRevision == _favoritesRevision) _favoriteIds = ids;
        _allStations = catalog?.stations ?? [];
        _offline = catalog?.offline ?? false;
        _fuel = profile?.preferredFuel ?? _fuel;
        _tankLiters = profile?.tankLiters ?? _tankLiters;
        _isLoading = false;
      });
      // GPS enriches distances but never blocks favorite retrieval.
      if (ids.isEmpty) return;
      try {
        final permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          return;
        }
        final position = await determinePosition();
        if (!mounted || generation != _generation) return;
        setState(() {
          for (final station in _allStations) {
            station.calcularDistancia(position.latitude, position.longitude);
          }
        });
      } catch (_) {
        /* Distances are optional. */
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() {
          _isLoading = false;
          _error = context.l10n.favLoadError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.star, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(context.l10n.favTitle)],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(forceRefresh: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                if (_error != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        TextButton(
                          onPressed: () => _loadData(forceRefresh: true),
                          child: Text(context.l10n.favRetry),
                        ),
                      ],
                    ),
                  );
                }
                final favoriteIds = _favoriteIds;

                if (favoriteIds.isEmpty) {
                  final mutedColor = Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_border, size: 64, color: mutedColor),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.favEmptyTitle,
                          style: TextStyle(fontSize: 18, color: mutedColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.favEmptyHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: mutedColor),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar solo las estaciones que están en favoritos
                final favoriteStations = _allStations
                    .where((station) => favoriteIds.contains(station.id))
                    .toList();

                debugPrint(
                  '⭐ Favoritos UI: ${favoriteIds.length} IDs, '
                  '${_allStations.length} estaciones cargadas, '
                  '${favoriteStations.length} coincidencias',
                );

                if (favoriteStations.isEmpty && _allStations.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          size: 64,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.favNotFound,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                debugPrint(
                  '🎨 Renderizando ${favoriteStations.length} favoritos',
                );
                return RefreshIndicator(
                  onRefresh: () => _loadData(forceRefresh: true),
                  child: ListView.builder(
                    itemCount: favoriteStations.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final e = favoriteStations[index];

                      String formatDistance(double? km) {
                        if (km == null) return '-';
                        if (km >= 1) return '${decimal(km, 1)} km';
                        return '${(km * 1000).toStringAsFixed(0)} m';
                      }

                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final favoriteColor = isDark
                          ? Colors.amber.withValues(alpha: 0.15)
                          : Colors.amber.shade50;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        child: Card(
                          color:
                              favoriteColor, // Siempre resaltado porque son favoritos
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GasStationDetailPage(
                                    station: e,
                                    preferredFuel: _fuel,
                                    tankLiters: _tankLiters,
                                    favoriteRepository: widget.repository,
                                    directionsRepository: DirectionsService(
                                      AppConfig.googleMapsApiKey,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.nombre,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              e.direccion,
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      FavoriteWidget(
                                        station: e,
                                        repository: widget.repository,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            context.l10n.favStraightLine,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            formatDistance(e.distancia),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (_offline)
                                    Text(context.l10n.favOfflinePrices),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (e.gasolina95 != null)
                                        Tooltip(
                                          message: context.l10n.fuelGasoline95,
                                          child: Chip(
                                            backgroundColor: FuelColors.of(
                                              FuelType.g95,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            avatar: const CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.white24,
                                              child: Text(
                                                '95',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            label: Text(
                                              euros(e.gasolina95!, 3),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (e.gasolina98 != null)
                                        Tooltip(
                                          message: context.l10n.fuelGasoline98,
                                          child: Chip(
                                            backgroundColor: FuelColors.of(
                                              FuelType.g98,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            avatar: const CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.white24,
                                              child: Text(
                                                '98',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            label: Text(
                                              euros(e.gasolina98!, 3),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (e.diesel != null)
                                        Tooltip(
                                          message: context.l10n.fuelDiesel,
                                          child: Chip(
                                            backgroundColor: FuelColors.of(
                                              FuelType.diesel,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            avatar: const CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.white24,
                                              child: Text(
                                                'D',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            label: Text(
                                              euros(e.diesel!, 3),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (e.dieselPremium != null)
                                        Tooltip(
                                          message:
                                              context.l10n.fuelDieselPremium,
                                          child: Chip(
                                            backgroundColor: FuelColors.of(
                                              FuelType.dieselPremium,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            avatar: const CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.white24,
                                              child: Text(
                                                'DP',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            label: Text(
                                              euros(e.dieselPremium!, 3),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
