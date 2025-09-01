import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/features/auth/auth_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/BLoC/gas_station_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/core/location.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';

enum SortBy { precio, distancia }

class GasStationListPage extends StatefulWidget {
  const GasStationListPage({super.key});

  @override
  State<GasStationListPage> createState() => _GasStationListPageState();
  
}

class _GasStationListPageState extends State<GasStationListPage> {
late GasStationBloc bloc;
SortBy _sortBy = SortBy.precio;

  @override
  void initState() {
    super.initState();
    bloc = GasStationBloc(GasStationRepository());
    _loadStations(); // cargar al inicio
  }

Future<void> _loadStations() async {
    try {
      final pos = await determinePosition();
      final estaciones = await GasStationRepository().fetchStations(
        pos.latitude,
        pos.longitude,
      );

      // Calculamos distancia
      for (var e in estaciones) {
        e.calcularDistancia(pos.latitude, pos.longitude);
      }

      // Mandamos al BLoC las estaciones ya con distancia
      bloc.add(LoadStationsWithDistance(estaciones));
    } catch (e) {
      bloc.add(GasStationLoadError(e.toString()));
    }
  }
  
  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
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
          actions: [
            PopupMenuButton<SortBy>(
              icon: const Icon(Icons.sort),
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                });
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: SortBy.precio,
                      child: Text('Ordenar por precio'),
                    ),
                    const PopupMenuItem(
                      value: SortBy.distancia,
                      child: Text('Ordenar por distancia'),
                    ),
                  ],
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
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(e.direccion),
                            Text("Marca: ${e.marca}"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Gasolina 95: ${e.gasolina95?.toStringAsFixed(2) ?? "-"} €",
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Diésel: ${e.diesel?.toStringAsFixed(2) ?? "-"} €",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

