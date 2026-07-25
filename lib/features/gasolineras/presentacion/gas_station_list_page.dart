import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/core/directions_service.dart';
import 'package:gasolineras_can/features/ads/banner_ad_widget.dart';
import 'package:gasolineras_can/features/directions/data/mock_directions_repository.dart';
import 'package:gasolineras_can/features/gasolineras/BLoC/gas_station_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/core/location.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:gasolineras_can/features/auth/user_profile_repository.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/details/gas_station_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gasolineras_can/core/config.dart';


enum SortBy { precio, distancia }

  // 🔹 Cambia este flag para alternar entre MOCK y API real
  const useMock = false;

const _prefSortBy = 'sortBy';
const _prefFuelType = 'fuelType';

class GasStationListPage extends StatefulWidget {
  const GasStationListPage({super.key});

  @override
  State<GasStationListPage> createState() => _GasStationListPageState();

}

class _GasStationListPageState extends State<GasStationListPage> {
late GasStationBloc bloc;
late FavoriteRepository favoriteRepository;
SortBy _sortBy = SortBy.precio;
FuelType _activeFuel = FuelType.g95;
double _tankLiters = 50;
String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    bloc = GasStationBloc(GasStationRepository());
    favoriteRepository = FavoriteRepository();
    _loadPreferences(); // 🔹 Cargamos preferencias
    _loadStations(); // cargar al inicio
  }

Future<void> _loadStations({bool forceRefresh = false}) async {
    // Si ya tenemos datos cargados y no se fuerza refresh, no hacer nada
    if (!forceRefresh && bloc.state is GasStationLoaded) {
      return;
    }

    try {
      final pos = await determinePosition(forceRefresh: forceRefresh);

      // Despachamos la petición al BLoC para que se encargue de
      // obtener las estaciones y calcular distancias.
      bloc.add(LoadStations(lat: pos.latitude, lng: pos.longitude));
    } catch (e) {
      // Si falla la obtención de la posición, notificamos al BLoC
      bloc.add(GasStationLoadError(e.toString()));
    }
  }

  /// 🔹 Guardar preferencias en local
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSortBy, _sortBy.name);
    await prefs.setString(_prefFuelType, _activeFuel.name);
  }

  /// 🔹 Cargar preferencias en local
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSort = prefs.getString(_prefSortBy);
    final savedFuel = prefs.getString(_prefFuelType);

    FuelType? profileFuel;
    if (Supabase.instance.client.auth.currentUser != null) {
      final profile = await UserProfileRepository().getProfile();
      profileFuel = profile?.preferredFuel;
    }

    if (Supabase.instance.client.auth.currentUser != null) {
      final profile = await UserProfileRepository().getProfile();
      if (profile != null) {
        _tankLiters = profile.tankLiters;
      }
    }

    if (savedSort != null || savedFuel != null || profileFuel != null) {
      setState(() {
        if (savedSort != null) {
          _sortBy = SortBy.values.firstWhere(
            (e) => e.name == savedSort,
            orElse: () => SortBy.precio,
          );
        }
        _activeFuel = profileFuel ??
            (savedFuel != null
                ? FuelType.values.firstWhere(
                    (e) => e.name == savedFuel,
                    orElse: () => FuelType.g95,
                  )
                : FuelType.g95);
      });
    }
  }

    void _onSortChanged(SortBy value) {
    setState(() {
      _sortBy = value;
    });
    _savePreferences();
  }

  void _onFuelTypeChanged(FuelType value) {
    setState(() {
      _activeFuel = value;
    });
    _savePreferences();
  }

  Widget _buildFuelChips(BuildContext context, GasStation station) {
    final availableFuels = FuelType.values
        .where((f) => station.priceFor(f) != null)
        .toList();

    if (availableFuels.isEmpty) {
      return const SizedBox.shrink();
    }

    // Si el combustible activo no está disponible, mostrar el primero que sí.
    final displayFuel = availableFuels.contains(_activeFuel)
        ? _activeFuel
        : availableFuels.first;
    final displayPrice = station.priceFor(displayFuel)!;

    final otherCount = availableFuels.length - 1;

    Widget buildActiveChip() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: FuelColors.of(displayFuel),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white24,
              child: Text(
                '⛽',
                style: TextStyle(fontSize: 11),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${displayPrice.toStringAsFixed(2)} €',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        buildActiveChip(),
        if (otherCount > 0)
          ActionChip(
            visualDensity: VisualDensity.compact,
            avatar: const Icon(Icons.expand_more, size: 18),
            label: Text('+${otherCount.toString()}'),
            onPressed: () => _showAllFuelsBottomSheet(context, station),
          ),
      ],
    );
  }

  void _showAllFuelsBottomSheet(BuildContext context, GasStation station) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final fuels = FuelType.values
            .where((f) => station.priceFor(f) != null)
            .toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Precios disponibles',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ...fuels.map((fuel) {
                  final price = station.priceFor(fuel)!;
                  final isActive = fuel == _activeFuel;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: FuelColors.of(fuel),
                      child: Text(
                        fuel.shortLabel,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(fuel.displayName),
                    trailing: Text(
                      '${price.toStringAsFixed(2)} €/L',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? FuelColors.of(fuel) : null,
                      ),
                    ),
                    onTap: () {
                      _onFuelTypeChanged(fuel);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
     final directionsRepository = useMock
        ? MockDirectionsRepository()
        : DirectionsService(AppConfig.googleMapsApiKey);

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                _sortBy == SortBy.precio
                    ? Icons.local_gas_station
                    : Icons.location_on,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Gasolineras",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            // Selector de tipo de combustible
            PopupMenuButton<FuelType>(
              initialValue: _activeFuel,
              onSelected: _onFuelTypeChanged,
              tooltip: 'Tipo de combustible',
              itemBuilder: (context) => FuelType.values.map((fuel) {
                final isSelected = fuel == _activeFuel;
                return PopupMenuItem(
                  value: fuel,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: FuelColors.of(fuel),
                        child: Text(
                          fuel.shortLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(fuel.displayName)),
                      if (isSelected)
                        const Icon(Icons.check, size: 18, color: Colors.blue),
                    ],
                  ),
                );
              }).toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: FuelColors.of(_activeFuel),
                  child: Text(
                    _activeFuel.shortLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            PopupMenuButton<SortBy>(
              initialValue: _sortBy,
              onSelected: _onSortChanged,
              tooltip: 'Ordenar por',
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: SortBy.precio,
                  child: Row(
                    children: [
                      const Icon(Icons.local_gas_station, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text("Por precio (${_activeFuel.shortLabel})"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: SortBy.distancia,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Por distancia"),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.filter_alt),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _loadStations(forceRefresh: true),
          child: BlocBuilder<GasStationBloc, GasStationState>(
            builder: (context, state) {
              if (state is GasStationLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is GasStationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadStations,
                      child: const Text("Reintentar"),
                    ),
                  ],
                ),
                );

              } else if (state is GasStationLoaded) {
                final estaciones = List<GasStation>.from(state.stations);

                return StreamBuilder<List<int>>(
                  stream: favoriteRepository.favoritesStream(),
                  builder: (context, snapshot) {
                    final favorites = snapshot.data ?? [];

                    // Filtrar por búsqueda
                    final filtered = estaciones.where((s) {
                      final q = _searchQuery.toLowerCase();
                      if (q.isEmpty) return true;
                      return (s.nombre.toLowerCase().contains(q) ||
                          s.direccion.toLowerCase().contains(q) ||
                          s.marca.toLowerCase().contains(q));
                    }).toList();

                    // Ordenar por precio (del combustible activo) o distancia
                    if (_sortBy == SortBy.precio) {
                      filtered.sort((a, b) {
                        final aPrice = a.priceFor(_activeFuel) ?? double.infinity;
                        final bPrice = b.priceFor(_activeFuel) ?? double.infinity;
                        return aPrice.compareTo(bPrice);
                      });
                    } else {
                      filtered.sort((a, b) {
                        final aDist = a.distancia ?? double.infinity;
                        final bDist = b.distancia ?? double.infinity;
                        return aDist.compareTo(bDist);
                      });
                    }

                    if (filtered.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_gas_station,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                const Text('No se han encontrado gasolineras', style: TextStyle(fontSize: 18)),
                                const SizedBox(height: 8),
                                Text(
                                  'Prueba a actualizar o cambiar los filtros.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    }

                    return CustomScrollView(
                      slivers: [
                        // Leyenda eliminada por preferencia del usuario
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Buscar por nombre, dirección o marca',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.blue),
                                      ),
                                    ),
                                    onChanged: (v) => setState(() {
                                      _searchQuery = v;
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final e = filtered[index];
                              final isFavorite = favorites.contains(e.id);
                              final isDark =
                                  Theme.of(context).brightness == Brightness.dark;
                              final favoriteColor = isDark
                                  ? Colors.amber.withValues(alpha: 0.15)
                                  : Colors.amber.shade50;

                              String formatDistance(double? km) {
                                if (km == null) return '-';
                                if (km >= 1) return '${km.toStringAsFixed(1)} km';
                                return '${(km * 1000).toStringAsFixed(0)} m';
                              }

                              String formatLastUpdate(DateTime? lastUpdate) {
                                if (lastUpdate == null) return 'Sin actualizar';
                                final now = DateTime.now();
                                final difference = now.difference(lastUpdate);
                                
                                if (difference.inMinutes < 60) {
                                  return 'Actualizado hace ${difference.inMinutes} min';
                                } else if (difference.inHours < 24) {
                                  return 'Actualizado hace ${difference.inHours} h';
                                } else if (difference.inDays < 7) {
                                  return 'Actualizado hace ${difference.inDays} días';
                                } else {
                                  return 'Actualizado el ${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}';
                                }
                              }

                              // Destaca el dato por el que se está ordenando (precio
                              // del combustible activo o distancia).
                              Widget buildHeadline() {
                                final activePrice = e.priceFor(_activeFuel);
                                if (_sortBy == SortBy.precio && activePrice != null) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _activeFuel.displayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${activePrice.toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: FuelColors.of(_activeFuel),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Distancia',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      formatDistance(e.distancia),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                child: Card(
                                  color: isFavorite ? favoriteColor : null,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GasStationDetailPage(
                                            station: e,
                                            favoriteRepository: favoriteRepository,
                                            directionsRepository: directionsRepository,
                                            preferredFuel: _activeFuel,
                                            tankLiters: _tankLiters,
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.nombre,
                                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      e.direccion,
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              buildHeadline(),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              if (_sortBy != SortBy.distancia) ...[
                                                Icon(
                                                  Icons.navigation,
                                                  size: 12,
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  formatDistance(e.distancia),
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                              Icon(
                                                Icons.access_time,
                                                size: 12,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  formatLastUpdate(e.lastUpdate),
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          _buildFuelChips(context, e),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: const [
                              SizedBox(height: 16),
                              BannerAdWidget(),
                              SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

