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
  const useMock = true;

class GasStationListPage extends StatefulWidget {
  const GasStationListPage({super.key});

  @override
  State<GasStationListPage> createState() => _GasStationListPageState();
  
}

class _GasStationListPageState extends State<GasStationListPage> {
late GasStationBloc bloc;
late FavoriteRepository favoriteRepository;
SortBy _sortBy = SortBy.precio;

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
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Gasolineras de Canarias"),
                  Text(
                    _sortBy == SortBy.precio
                        ? "Ordenado por precio"
                        : "Ordenado por distancia",
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
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
              icon: const Icon(Icons.sort),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().logout(),
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

                return StreamBuilder<List<String>>(
                  stream: favoriteRepository.favoritesStream(),
                  builder: (context, snapshot) {
                    final favorites = snapshot.data ?? [];

                    // Ordenar por precio o distancia como antes
                    if (_sortBy == SortBy.precio) {
                      estaciones.sort((a, b) {
                        final aPrice = a.gasolina95 ?? double.infinity;
                        final bPrice = b.gasolina95 ?? double.infinity;
                        return aPrice.compareTo(bPrice);
                      });
                    } else {
                      estaciones.sort((a, b) {
                        final aDist = a.distancia ?? double.infinity;
                        final bDist = b.distancia ?? double.infinity;
                        return aDist.compareTo(bDist);
                      });
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: estaciones.length,
                      itemBuilder: (context, index) {
                        final e = estaciones[index];
                        final isFavorite = favorites.contains(e.id.toString());

                        return InkWell(
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
                          child: Card(
                            color: isFavorite
                                ? Colors.yellow[50]
                                : null, // 🔹 fondo distinto si es favorito
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          e.nombre,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      FavoriteWidget(
                                        station: e,
                                        repository: favoriteRepository,
                                      ),
                                    ],
                                  ),
                                  Text(e.direccion),
                                  Text("Marca: ${e.marca}"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "Gasolina 95: ${e.gasolina95?.toStringAsFixed(2) ?? "-"} €",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          "Diésel: ${e.diesel?.toStringAsFixed(2) ?? "-"} €",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

