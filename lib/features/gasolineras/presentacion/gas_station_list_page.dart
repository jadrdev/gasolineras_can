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
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/details/gas_station_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gasolineras_can/core/config.dart';


enum SortBy { precio, distancia }

  // 🔹 Cambia este flag para alternar entre MOCK y API real
  const useMock = false;

class GasStationListPage extends StatefulWidget {
  const GasStationListPage({super.key});

  @override
  State<GasStationListPage> createState() => _GasStationListPageState();
  
}

class _GasStationListPageState extends State<GasStationListPage> {
late GasStationBloc bloc;
late FavoriteRepository favoriteRepository;
SortBy _sortBy = SortBy.precio;
String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    bloc = GasStationBloc(GasStationRepository());
    favoriteRepository = FavoriteRepository();
    _loadSortPreference(); // 🔹 Cargamos la preferencia
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

  /// 🔹 Guardar preferencia en local
  Future<void> _saveSortPreference(SortBy value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("sortBy", value.name); // Guardamos como string
  }

  /// 🔹 Cargar preferencia en local
  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("sortBy");
    if (saved != null) {
      setState(() {
        _sortBy = SortBy.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => SortBy.precio,
        );
      });
    }
  }

    void _onSortChanged(SortBy value) {
    setState(() {
      _sortBy = value;
    });
    _saveSortPreference(value); // 🔹 Guardamos al cambiar
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
                    ? Icons
                      .local_gas_station // precio → surtidor
                    : Icons.location_on, // distancia → pin
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Gasolineras de Canarias"),
                ],
              ),
            ],
          ),
            actions: [
            PopupMenuButton<SortBy>(
              initialValue: _sortBy,
              onSelected: _onSortChanged, // 🔹 Llamamos al método que guarda
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: SortBy.precio,
                  child: Row(
                    children: [
                      Icon(Icons.local_gas_station, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Ordenar por precio"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: SortBy.distancia,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Ordenar por distancia"),
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

                    // Ordenar por precio o distancia
                    if (_sortBy == SortBy.precio) {
                      filtered.sort((a, b) {
                        final aPrice = a.gasolina95 ?? double.infinity;
                        final bPrice = b.gasolina95 ?? double.infinity;
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

                              // Destaca el dato por el que se está ordenando (precio de
                              // gasolina 95 o distancia), ya que es lo que hace que esta
                              // gasolinera esté en esta posición de la lista.
                              Widget buildHeadline() {
                                if (_sortBy == SortBy.precio && e.gasolina95 != null) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Gasolina 95',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${e.gasolina95!.toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: FuelColors.of(FuelType.g95),
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
                                          Builder(
                                            builder: (context) {
                                              // Contar cuántos tipos de combustible hay
                                              final fuelTypes = [
                                                if (e.gasolina95 != null) 'g95',
                                                if (e.gasolina98 != null) 'g98',
                                                if (e.diesel != null) 'd',
                                                if (e.dieselPremium != null) 'dp',
                                              ];

                                              // Función para crear chip ancho (para grid 2x2)
                                              Widget buildWideChip({
                                                required String label,
                                                required String price,
                                                required Color backgroundColor,
                                              }) {
                                                return Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color: backgroundColor,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 10,
                                                        backgroundColor: Colors.white24,
                                                        child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(price, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                );
                                              }

                                              // Si hay 4 tipos, mostrar en grid 2x2 con chips anchos
                                              if (fuelTypes.length == 4) {
                                                return Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        if (e.gasolina95 != null)
                                                          Expanded(
                                                            child: Tooltip(
                                                              message: 'Gasolina 95',
                                                              child: buildWideChip(
                                                                label: '95',
                                                                price: '${e.gasolina95!.toStringAsFixed(2)} €',
                                                                backgroundColor: FuelColors.of(FuelType.g95),
                                                              ),
                                                            ),
                                                          ),
                                                        const SizedBox(width: 6),
                                                        if (e.gasolina98 != null)
                                                          Expanded(
                                                            child: Tooltip(
                                                              message: 'Gasolina 98',
                                                              child: buildWideChip(
                                                                label: '98',
                                                                price: '${e.gasolina98!.toStringAsFixed(2)} €',
                                                                backgroundColor: FuelColors.of(FuelType.g98),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        if (e.diesel != null)
                                                          Expanded(
                                                            child: Tooltip(
                                                              message: 'Diésel',
                                                              child: buildWideChip(
                                                                label: 'D',
                                                                price: '${e.diesel!.toStringAsFixed(2)} €',
                                                                backgroundColor: FuelColors.of(FuelType.diesel),
                                                              ),
                                                            ),
                                                          ),
                                                        const SizedBox(width: 6),
                                                        if (e.dieselPremium != null)
                                                          Expanded(
                                                            child: Tooltip(
                                                              message: 'Diésel Premium',
                                                              child: buildWideChip(
                                                                label: 'DP',
                                                                price: '${e.dieselPremium!.toStringAsFixed(2)} €',
                                                                backgroundColor: FuelColors.of(FuelType.dieselPremium),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }

                                              // Si no hay 4 tipos, usar chips compactos en una línea
                                              final chips = [
                                                if (e.gasolina95 != null)
                                                  Tooltip(
                                                    message: 'Gasolina 95',
                                                    child: Chip(
                                                      backgroundColor: FuelColors.of(FuelType.g95),
                                                      visualDensity: VisualDensity.compact,
                                                      shape: const StadiumBorder(),
                                                      avatar: const CircleAvatar(
                                                        radius: 10,
                                                        backgroundColor: Colors.white24,
                                                        child: Text('95', style: TextStyle(fontSize: 11, color: Colors.white)),
                                                      ),
                                                      label: Text('${e.gasolina95!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                                    ),
                                                  ),
                                                if (e.gasolina98 != null)
                                                  Tooltip(
                                                    message: 'Gasolina 98',
                                                    child: Chip(
                                                      backgroundColor: FuelColors.of(FuelType.g98),
                                                      visualDensity: VisualDensity.compact,
                                                      shape: const StadiumBorder(),
                                                      avatar: const CircleAvatar(
                                                        radius: 10,
                                                        backgroundColor: Colors.white24,
                                                        child: Text('98', style: TextStyle(fontSize: 11, color: Colors.white)),
                                                      ),
                                                      label: Text('${e.gasolina98!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                                    ),
                                                  ),
                                                if (e.diesel != null)
                                                  Tooltip(
                                                    message: 'Diésel',
                                                    child: Chip(
                                                      backgroundColor: FuelColors.of(FuelType.diesel),
                                                      visualDensity: VisualDensity.compact,
                                                      shape: const StadiumBorder(),
                                                      avatar: const CircleAvatar(
                                                        radius: 10,
                                                        backgroundColor: Colors.white24,
                                                        child: Text('D', style: TextStyle(fontSize: 11, color: Colors.white)),
                                                      ),
                                                      label: Text('${e.diesel!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                                    ),
                                                  ),
                                                if (e.dieselPremium != null)
                                                  Tooltip(
                                                    message: 'Diésel Premium',
                                                    child: Chip(
                                                      backgroundColor: FuelColors.of(FuelType.dieselPremium),
                                                      visualDensity: VisualDensity.compact,
                                                      shape: const StadiumBorder(),
                                                      avatar: const CircleAvatar(
                                                        radius: 10,
                                                        backgroundColor: Colors.white24,
                                                        child: Text('DP', style: TextStyle(fontSize: 11, color: Colors.white)),
                                                      ),
                                                      label: Text('${e.dieselPremium!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                                    ),
                                                  ),
                                              ];

                                              // Mostrar en una sola línea con Wrap
                                              return Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                children: chips,
                                              );
                                            },
                                          ),
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

