import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/features/auth/auth_bloc.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/details/gas_station_details.dart';
import 'package:gasolineras_can/core/directions_service.dart';
import 'package:gasolineras_can/core/config.dart';
import 'package:gasolineras_can/core/location.dart';

class FavoritesPage extends StatefulWidget {
  final FavoriteRepository repository;
  const FavoritesPage({super.key, required this.repository});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _gasStationRepo = GasStationRepository();
  List<GasStation> _allStations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      setState(() => _isLoading = true);
      // Obtener posición actual para cargar estaciones cercanas
      final pos = await determinePosition();
      final stations = await _gasStationRepo.fetchStations(pos.latitude, pos.longitude);
      setState(() {
        _allStations = stations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.star,
              size: 20,
              color: Colors.black,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Mis Favoritos"),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<int>>(
              stream: widget.repository.favoritesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final favoriteIds = snapshot.data ?? [];

                if (favoriteIds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.star_border, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tienes favoritos',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Agrega gasolineras a favoritos desde la lista principal',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar solo las estaciones que están en favoritos
                final favoriteStations = _allStations
                    .where((station) => favoriteIds.contains(station.id))
                    .toList();

                if (favoriteStations.isEmpty && _allStations.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.warning_amber, size: 64, color: Colors.orange),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron las gasolineras favoritas',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadStations,
                  child: ListView.builder(
                    itemCount: favoriteStations.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final e = favoriteStations[index];

                      Color priceColor(double? price, {String? type}) {
                        // Si se especifica el tipo, preferimos el color de manguera
                        if (type == '95') return Colors.green;
                        if (type == 'D') return Colors.grey[900] ?? Colors.black;
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
                          color: Colors.yellow[50], // Siempre amarillo porque son favoritos
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GasStationDetailPage(
                                    station: e,
                                    favoriteRepository: widget.repository,
                                    directionsRepository: DirectionsService(AppConfig.googleMapsApiKey),
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
                  ),
                );
              },
            ),
    );
  }
}
