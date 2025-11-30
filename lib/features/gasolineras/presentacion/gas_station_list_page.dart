import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/core/directions_service.dart';
import 'package:gasolineras_can/features/auth/auth_bloc.dart';
import 'package:gasolineras_can/features/directions/data/mock_directions_repository.dart';
import 'package:gasolineras_can/features/gasolineras/BLoC/gas_station_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/core/location.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:gasolineras_can/features/favoritos/presentacion.dart';
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

Future<void> _loadStations() async {
    try {
      final pos = await determinePosition();

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
                color: Colors.black,
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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                // Solo mostrar el botón de logout si el usuario está autenticado
                if (authState is Authenticated) {
                  return IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => context.read<AuthBloc>().logout(),
                  );
                }
                return const SizedBox.shrink(); // No mostrar nada si no está autenticado
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadStations,
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
                              children: const [
                                Icon(Icons.local_gas_station, size: 64, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('No se han encontrado gasolineras', style: TextStyle(fontSize: 18)),
                                SizedBox(height: 8),
                                Text('Prueba a actualizar o cambiar los filtros.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
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

                              Color priceColor(double? price, {String? type}) {
                                // Si se especifica el tipo, preferimos el color de manguera
                                if (type == '95') return Colors.green;
                                if (type == 'D') return Colors.grey[900] ?? Colors.black;
                                if (type == 'DP') return Colors.grey[900] ?? Colors.black;
                                if (price == null) return Colors.grey;
                                if (price < 1.4) return Colors.green;
                                if (price < 1.7) return Colors.orange;
                                return Colors.red;
                              }

                              String formatDistance(double? km) {
                                if (km == null) return '-';
                                if (km >= 1) return '${km.toStringAsFixed(1)} km';
                                return '${(km * 1000).toStringAsFixed(0)} m';
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                child: Card(
                                  color: isFavorite ? Colors.yellow[50] : null,
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
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(e.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 4),
                                                    Text(e.direccion, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.navigation, size: 14, color: Colors.grey[700]),
                                                  const SizedBox(width: 4),
                                                  Text(formatDistance(e.distancia), style: const TextStyle(color: Colors.grey)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                           Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              if (e.gasolina95 != null)
                                                Tooltip(
                                                  message: 'Gasolina 95',
                                                  child: Chip(
                                                    backgroundColor: priceColor(e.gasolina95, type: '95'),
                                                    visualDensity: VisualDensity.compact,
                                                    shape: const StadiumBorder(),
                                                    avatar: const CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor: Colors.white24,
                                                      child: Text('95', style: TextStyle(fontSize: 10, color: Colors.white)),
                                                    ),
                                                    label: Text('${e.gasolina95!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                  ),
                                                ),
                                              if (e.gasolina98 != null)
                                                Tooltip(
                                                  message: 'Gasolina 98',
                                                  child: Chip(
                                                    backgroundColor: Colors.blue,
                                                    visualDensity: VisualDensity.compact,
                                                    shape: const StadiumBorder(),
                                                    avatar: const CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor: Colors.white24,
                                                      child: Text('98', style: TextStyle(fontSize: 10, color: Colors.white)),
                                                    ),
                                                    label: Text('${e.gasolina98!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                  ),
                                                ),
                                              if (e.diesel != null)
                                                Tooltip(
                                                  message: 'Diésel',
                                                  child: Chip(
                                                    backgroundColor: priceColor(e.diesel, type: 'D'),
                                                    visualDensity: VisualDensity.compact,
                                                    shape: const StadiumBorder(),
                                                    avatar: const CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor: Colors.white24,
                                                      child: Text('D', style: TextStyle(fontSize: 10, color: Colors.white)),
                                                    ),
                                                    label: Text('${e.diesel!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                  ),
                                                ),
                                              if (e.dieselPremium != null)
                                                Tooltip(
                                                  message: 'Diésel Premium',
                                                  child: Chip(
                                                    backgroundColor: priceColor(e.dieselPremium, type: 'DP'),
                                                    visualDensity: VisualDensity.compact,
                                                    shape: const StadiumBorder(),
                                                    avatar: const CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor: Colors.white24,
                                                      child: Text('DP', style: TextStyle(fontSize: 10, color: Colors.white)),
                                                    ),
                                                    label: Text('${e.dieselPremium!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                            childCount: filtered.length,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: const SizedBox(height: 12),
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

