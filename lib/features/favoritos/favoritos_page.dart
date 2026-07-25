import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
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
            const Icon(
              Icons.star,
              size: 20,
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
                  final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_border, size: 64, color: mutedColor),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes favoritos',
                          style: TextStyle(fontSize: 18, color: mutedColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega gasolineras a favoritos desde la lista principal',
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

                      String formatDistance(double? km) {
                        if (km == null) return '-';
                        if (km >= 1) return '${km.toStringAsFixed(1)} km';
                        return '${(km * 1000).toStringAsFixed(0)} m';
                      }

                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final favoriteColor = isDark
                          ? Colors.amber.withValues(alpha: 0.15)
                          : Colors.amber.shade50;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        child: Card(
                          color: favoriteColor, // Siempre resaltado porque son favoritos
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
                                      Column(
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
                                            backgroundColor: FuelColors.of(FuelType.g95),
                                            visualDensity: VisualDensity.compact,
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
                                            avatar: const CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.white24,
                                              child: Text('DP', style: TextStyle(fontSize: 11, color: Colors.white)),
                                            ),
                                            label: Text('${e.dieselPremium!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 13)),
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
