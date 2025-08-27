import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/BLoC/gas_station_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/core/location.dart';

class GasStationListPage extends StatefulWidget {
  final double lat;
  final double lng;
  
  

  const GasStationListPage({super.key, required this.lat, required this.lng});

  @override
  State<GasStationListPage> createState() => _GasStationListPageState();
}

class _GasStationListPageState extends State<GasStationListPage> {
late GasStationBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = GasStationBloc(GasStationRepository());
    _loadStations(); // cargar al inicio
  }

  Future<void> _loadStations() async {
    try {
      final pos = await determinePosition();
      bloc.add(LoadStations(lat: pos.latitude, lng: pos.longitude));
    } catch (e) {
      // ignore: invalid_use_of_protected_member
      bloc.addError(e.toString());
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
        appBar: AppBar(title: const Text("Gasolineras")),
        body: RefreshIndicator(
          onRefresh: _loadStations,
          child: BlocBuilder<GasStationBloc, GasStationState>(
            builder: (context, state) {
              if (state is GasStationLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is GasStationError) {
                return Center(child: Text("❌ ${state.message}"));
              } else if (state is GasStationLoaded) {
                final estaciones = state.stations;
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

