import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';


class StationsTestPage extends StatelessWidget {
  const StationsTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = GasStationRepository();

    return Scaffold(
      appBar: AppBar(title: const Text("Prueba estaciones")),
      body: FutureBuilder<List<GasStation>>(
  future: repo.fetchStations(28.463629, -16.251846),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay estaciones"));
          }

          final estaciones = snapshot.data!;

          return ListView.builder(
            itemCount: estaciones.length,
            itemBuilder: (context, index) {
              final e = estaciones[index];
              return ListTile(
                title: Text(e.nombre),
                subtitle: Text(e.direccion),
                trailing: Text(e.gasolina95?.toStringAsFixed(2) ?? "-"),
              );
            },
          );
        },
      )
    );
  }
}
