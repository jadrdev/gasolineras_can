import 'package:gasolineras_can/core/format.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gasolineras_can/core/config.dart';
import 'package:gasolineras_can/core/directions_service.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/details/gas_station_details.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';

class GasStationMapPage extends StatefulWidget {
  final List<GasStation> stations;
  final FuelType preferredFuel;
  final double tankLiters;

  const GasStationMapPage({
    super.key,
    required this.stations,
    this.preferredFuel = FuelType.g95,
    this.tankLiters = 50,
  });

  @override
  State<GasStationMapPage> createState() => _GasStationMapPageState();
}

class _GasStationMapPageState extends State<GasStationMapPage> {
  GoogleMapController? _mapController;
  late final Future<Set<Marker>> _markers = _buildMarkers(widget.stations);
  final Map<String, Future<BitmapDescriptor>> _icons = {};

  // Los marcadores se agrupan cuando se solapan: de lejos se ve una burbuja
  // con el número de gasolineras y, al acercar, se separan en precios.
  static const _cluster = ClusterManagerId('gasolineras');

  /// Ancho del marcador en puntos de pantalla. El dibujo se hace a 3x para
  /// que se vea nítido; antes se mostraba a 90 puntos y se tapaban unos a otros.
  static const _markerWidth = 56.0;
  static const _drawScale = 3 * _markerWidth / 90;

  Future<BitmapDescriptor> _buildPriceMarker(String text, Color color) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder)..scale(_drawScale);
    const size = 90.0;
    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Bubble body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size, size * 0.65),
        const Radius.circular(12),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size, size * 0.65),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Pointer
    final path = Path()
      ..moveTo(size * 0.35, size * 0.63)
      ..lineTo(size * 0.5, size)
      ..lineTo(size * 0.65, size * 0.63)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint..style = PaintingStyle.stroke);

    // Text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.text = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size * 0.65 - textPainter.height) / 2 - 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final pixels = (size * _drawScale).round();
    final image = await picture.toImage(pixels, pixels);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final png = bytes!.buffer.asUint8List();
    image.dispose();
    picture.dispose();
    return BitmapDescriptor.bytes(
      png,
      width: _markerWidth,
      height: _markerWidth,
    );
  }

  Future<Set<Marker>> _buildMarkers(List<GasStation> stations) async {
    final favoriteRepository = FavoriteRepository();
    final markers = <Marker>{};

    for (final station in stations) {
      final price = station.priceFor(widget.preferredFuel);

      final label = price == null ? '—' : decimal(price, 3);
      final icon = await (_icons[label] ??= _buildPriceMarker(
        label,
        FuelColors.of(widget.preferredFuel),
      ));

      markers.add(
        Marker(
          markerId: MarkerId('station-${station.id}'),
          clusterManagerId: _cluster,
          position: LatLng(station.latitud, station.longitud),
          icon: icon,
          infoWindow: InfoWindow(
            title: station.nombre,
            snippet:
                '${widget.preferredFuel.displayName}: ${price == null ? 'sin precio' : '${decimal(price, 3)} €/L'}',
          ),
          onTap: () => _showStationBottomSheet(station, favoriteRepository),
        ),
      );
    }

    return markers;
  }

  void _showStationBottomSheet(
    GasStation station,
    FavoriteRepository favoriteRepository,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final price = station.priceFor(widget.preferredFuel);
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
                  station.direccion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (price != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: FuelColors.of(widget.preferredFuel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.preferredFuel.displayName}: ${decimal(price, 3)} €/L',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _openStationDetail(station, favoriteRepository),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Ver detalle'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _launchDirections(station),
                        icon: const Icon(Icons.directions),
                        label: const Text('Cómo llegar'),
                      ),
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

  void _openStationDetail(
    GasStation station,
    FavoriteRepository favoriteRepository,
  ) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GasStationDetailPage(
          station: station,
          favoriteRepository: favoriteRepository,
          directionsRepository: DirectionsService(AppConfig.googleMapsApiKey),
          preferredFuel: widget.preferredFuel,
          tankLiters: widget.tankLiters,
        ),
      ),
    );
  }

  Future<void> _launchDirections(GasStation station) async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      if (availableMaps.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay aplicaciones de mapas instaladas'),
          ),
        );
        return;
      }

      if (availableMaps.length == 1) {
        await availableMaps.first.showDirections(
          destination: Coords(station.latitud, station.longitud),
          destinationTitle: station.nombre,
        );
        return;
      }

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecciona una app de mapas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...availableMaps.map(
                (map) => ListTile(
                  leading: Image.asset(
                    map.icon,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, error, stack) => const Icon(Icons.map),
                  ),
                  title: Text(map.mapName),
                  onTap: () async {
                    Navigator.pop(context);
                    await map.showDirections(
                      destination: Coords(station.latitud, station.longitud),
                      destinationTitle: station.nombre,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al abrir el mapa: $e')));
    }
  }

  Future<void> _fitResults() async {
    final stations = widget.stations;
    if (stations.isEmpty) return;
    if (stations.length == 1) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(stations.first.latitud, stations.first.longitud),
          14,
        ),
      );
      return;
    }
    final latitudes = stations.map((s) => s.latitud).toList()..sort();
    final longitudes = stations.map((s) => s.longitud).toList()..sort();
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(latitudes.first - 0.001, longitudes.first - 0.001),
          northeast: LatLng(latitudes.last + 0.001, longitudes.last + 0.001),
        ),
        48,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Mapa · ${widget.stations.length} gasolineras'),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.view_list_outlined),
          label: const Text('Lista'),
        ),
      ],
    ),
    body: widget.stations.isEmpty
        ? const Center(child: Text('No hay gasolineras para mostrar.'))
        : FutureBuilder<Set<Marker>>(
            future: _markers,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'No se pudo cargar el mapa. Vuelve a la lista e inténtalo de nuevo.',
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          widget.stations.first.latitud,
                          widget.stations.first.longitud,
                        ),
                        zoom: 12,
                      ),
                      markers: snapshot.data!,
                      clusterManagers: {
                        ClusterManager(
                          clusterManagerId: _cluster,
                          // Tocar un grupo acerca el mapa hasta separarlo.
                          onClusterTap: (cluster) =>
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngBounds(
                                  cluster.bounds,
                                  80,
                                ),
                              ),
                        ),
                      },
                      mapToolbarEnabled: false,
                      // Sube los botones de Google por encima del de
                      // «Ver todos los resultados», que antes los tapaba.
                      padding: EdgeInsets.only(
                        bottom: 72 + MediaQuery.paddingOf(context).bottom,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _fitResults();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
    floatingActionButton: widget.stations.isEmpty
        ? null
        : FloatingActionButton.small(
            tooltip: 'Ver todos los resultados',
            onPressed: _fitResults,
            child: const Icon(Icons.zoom_out_map),
          ),
  );
}
