
import 'package:flutter/material.dart';
import 'package:gasolineras_can/core/directions_service.dart';
import 'package:gasolineras_can/features/directions/domain/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gasolineras_can/core/location.dart';

import 'package:gasolineras_can/features/favoritos/presentacion.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:map_launcher/map_launcher.dart';

class GasStationDetailPage extends StatefulWidget {
  final GasStation station;
  final FavoriteRepository favoriteRepository;
  final DirectionsRepository directionsRepository; // 👈 nuevo

  const GasStationDetailPage({
    super.key,
    required this.station,
    required this.favoriteRepository,
    required this.directionsRepository,
  });

  @override
  State<GasStationDetailPage> createState() => _GasStationDetailPageState();
}

class _GasStationDetailPageState extends State<GasStationDetailPage> {
  late LatLng _userPosition;
  bool _loadingLocation = true;
  late DirectionsService directionsService;

  // 🔹 Aquí guardaremos los puntos de la ruta
  List<LatLng> _routePoints = [];
  double _fabScale = 1.0;

  @override
  void initState() {
    super.initState();
    _initPositions();
  }

  Future<void> _initPositions() async {
    try {
      final pos = await determinePosition();
      final origin = LatLng(pos.latitude, pos.longitude);
      final destination = LatLng(
        widget.station.latitud,
        widget.station.longitud,
      );
      setState(() {
        _userPosition = LatLng(pos.latitude, pos.longitude);
      });

       // Pedir la ruta usando el servicio
      // final route = await directionsService.getRoute(
      //   origin: _userPosition,
      //   destination: LatLng(widget.station.latitud, widget.station.longitud),
      // );

      final route = await widget.directionsRepository.getRoute(
        origin,
        destination,
      );

      

   

      setState(() {
        _routePoints = route;
        _loadingLocation = false;
      });
    } on LocationPermissionException catch (e) {
      setState(() => _loadingLocation = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Configuración',
              onPressed: () {
                // Abrir configuración de la app
                Geolocator.openAppSettings();
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _loadingLocation = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado al obtener la ubicación: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _launchMaps() async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      
      // Debug: ver cuántas apps se detectaron
      print('🗺️ Apps de mapas detectadas: ${availableMaps.length}');
      for (var map in availableMaps) {
        print('  - ${map.mapName}');
      }
      
      if (availableMaps.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay aplicaciones de mapas instaladas')),
          );
        }
        return;
      }

      // Siempre mostrar el selector para que el usuario pueda elegir
      if (context.mounted) {
        await _showMapOptions(availableMaps);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el mapa: $e')),
        );
      }
    }
  }

  Future<void> _showMapOptions(List<AvailableMap> availableMaps) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Selecciona una app de mapas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...availableMaps.map((map) {
                return ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      map.icon,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.map, size: 40);
                      },
                    ),
                  ),
                  title: Text(map.mapName),
                  onTap: () async {
                    Navigator.pop(context);
                    await map.showDirections(
                      destination: Coords(widget.station.latitud, widget.station.longitud),
                      origin: Coords(_userPosition.latitude, _userPosition.longitude),
                      destinationTitle: widget.station.nombre,
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onFabPressed() async {
    setState(() => _fabScale = 0.92);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _fabScale = 1.0);
    await _launchMaps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 6,
        title: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top > 0 ? 4.0 : 0.0,
          ),
          child: Text(widget.station.nombre),
        ),
        actions: [
          FavoriteWidget(
            station: widget.station,
            repository: widget.favoriteRepository,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.hardEdge,
                child: _loadingLocation
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                widget.station.latitud,
                                widget.station.longitud,
                              ),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('station'),
                                position: LatLng(
                                  widget.station.latitud,
                                  widget.station.longitud,
                                ),
                                infoWindow: InfoWindow(title: widget.station.nombre),
                              ),
                              Marker(
                                markerId: const MarkerId('user'),
                                position: _userPosition,
                                infoWindow: const InfoWindow(title: "Tu ubicación"),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueBlue,
                                ),
                              ),
                            },
                            polylines: {
                              if (_routePoints.isNotEmpty)
                                Polyline(
                                  polylineId: const PolylineId('route'),
                                  points: _routePoints,
                                  color: Colors.blue,
                                  width: 5,
                                ),
                            },
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: GestureDetector(
                              onTap: _onFabPressed,
                              child: AnimatedScale(
                                scale: _fabScale,
                                duration: const Duration(milliseconds: 120),
                                child: FloatingActionButton.small(
                                  onPressed: _onFabPressed,
                                  backgroundColor: Colors.white,
                                  child: const Icon(Icons.directions, color: Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView(
                children: [
                  Text(
                    widget.station.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Dirección: ${widget.station.direccion}"),
                  Text("Marca: ${widget.station.marca}"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (widget.station.gasolina95 != null)
                        Tooltip(
                          message: 'Gasolina 95',
                          child: Chip(
                            backgroundColor: Colors.green,
                            visualDensity: VisualDensity.compact,
                            shape: const StadiumBorder(),
                            avatar: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white24,
                              child: Text('95', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                            label: Text('${widget.station.gasolina95!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      if (widget.station.gasolina98 != null)
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
                            label: Text('${widget.station.gasolina98!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      if (widget.station.diesel != null)
                        Tooltip(
                          message: 'Diésel',
                          child: Chip(
                            backgroundColor: Colors.grey[800] ?? Colors.black,
                            visualDensity: VisualDensity.compact,
                            shape: const StadiumBorder(),
                            avatar: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white24,
                              child: Text('D', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                            label: Text('${widget.station.diesel!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      if (widget.station.dieselPremium != null)
                        Tooltip(
                          message: 'Diésel Premium',
                          child: Chip(
                            backgroundColor: Colors.grey[800] ?? Colors.black,
                            visualDensity: VisualDensity.compact,
                            shape: const StadiumBorder(),
                            avatar: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white24,
                              child: Text('DP', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                            label: Text('${widget.station.dieselPremium!.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _launchMaps,
                          icon: const Icon(Icons.directions),
                          label: const Text('Cómo llegar'),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
