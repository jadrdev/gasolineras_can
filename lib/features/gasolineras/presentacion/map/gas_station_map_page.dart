import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/core/config.dart';
import 'package:gasolineras_can/core/directions_service.dart';
import 'package:gasolineras_can/core/location.dart';
import 'package:gasolineras_can/features/ads/banner_ad_widget.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/BLoC/gas_station_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/details/gas_station_details.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';

class GasStationMapPage extends StatefulWidget {
  final FuelType preferredFuel;
  final double tankLiters;

  const GasStationMapPage({
    super.key,
    this.preferredFuel = FuelType.g95,
    this.tankLiters = 50,
  });

  @override
  State<GasStationMapPage> createState() => _GasStationMapPageState();
}

class _GasStationMapPageState extends State<GasStationMapPage> {
  late GasStationBloc _bloc;
  GoogleMapController? _mapController;
  LatLng? _userPosition;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _bloc = GasStationBloc(GasStationRepository());
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final pos = await determinePosition();
      _userPosition = LatLng(pos.latitude, pos.longitude);
      setState(() => _loadingLocation = false);
      _bloc.add(LoadStations(lat: pos.latitude, lng: pos.longitude));
    } catch (e) {
      setState(() => _loadingLocation = false);
      _bloc.add(GasStationLoadError(e.toString()));
    }
  }

  Future<BitmapDescriptor> _buildPriceMarker(String text, Color color) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = 90.0;
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
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final png = bytes!.buffer.asUint8List();
    return BitmapDescriptor.bytes(png);
  }

  Future<Set<Marker>> _buildMarkers(List<GasStation> stations) async {
    final favoriteRepository = FavoriteRepository();
    final markers = <Marker>{};

    for (final station in stations) {
      final price = station.priceFor(widget.preferredFuel);
      if (price == null) continue;

      final icon = await _buildPriceMarker(
        price.toStringAsFixed(2),
        FuelColors.of(widget.preferredFuel),
      );

      markers.add(
        Marker(
          markerId: MarkerId('station-${station.id}'),
          position: LatLng(station.latitud, station.longitud),
          icon: icon,
          infoWindow: InfoWindow(
            title: station.nombre,
            snippet: '${widget.preferredFuel.displayName}: ${price.toStringAsFixed(2)} €/L',
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
                      '${widget.preferredFuel.displayName}: ${price.toStringAsFixed(2)} €/L',
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
                        onPressed: () => _openStationDetail(station, favoriteRepository),
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

  void _openStationDetail(GasStation station, FavoriteRepository favoriteRepository) {
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
          const SnackBar(content: Text('No hay aplicaciones de mapas instaladas')),
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
              ...availableMaps.map((map) => ListTile(
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
                  )),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el mapa: $e')),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: BlocBuilder<GasStationBloc, GasStationState>(
          builder: (context, state) {
            if (_loadingLocation || state is GasStationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GasStationError) {
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
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is GasStationLoaded) {
              final stations = state.stations;
              final cameraPosition = _userPosition != null
                  ? CameraPosition(target: _userPosition!, zoom: 13)
                  : CameraPosition(
                      target: LatLng(stations.first.latitud, stations.first.longitud),
                      zoom: 13,
                    );

              return FutureBuilder<Set<Marker>>(
                future: _buildMarkers(stations),
                builder: (context, snapshot) {
                  final markers = snapshot.data ?? {};

                  return Column(
                    children: [
                      Expanded(
                        child: GoogleMap(
                          initialCameraPosition: cameraPosition,
                          markers: markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          onMapCreated: (controller) => _mapController = controller,
                        ),
                      ),
                      const SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: BannerAdWidget(),
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
        floatingActionButton: FloatingActionButton.small(
          onPressed: () async {
            if (_userPosition == null) return;
            await _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_userPosition!, 14),
            );
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}
