import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gasolineras_can/core/directions_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gasolineras_can/core/location.dart';
import 'package:gasolineras_can/core/config.dart';
import 'package:gasolineras_can/features/favoritos/presentacion.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class GasStationDetailPage extends StatefulWidget {
  final GasStation station;
  final FavoriteRepository favoriteRepository;

  const GasStationDetailPage({
    super.key,
    required this.station,
    required this.favoriteRepository,
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

  @override
  void initState() {
    super.initState();
    directionsService = DirectionsService(AppConfig.googleMapsApiKey);
    _initPositions();
  }

  Future<void> _initPositions() async {
    try {
      final pos = await determinePosition();
      setState(() {
        _userPosition = LatLng(pos.latitude, pos.longitude);
      });

       // Pedir la ruta usando el servicio
      final route = await directionsService.getRoute(
        origin: _userPosition,
        destination: LatLng(widget.station.latitud, widget.station.longitud),
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
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${_userPosition.latitude},${_userPosition.longitude}&destination=${widget.station.latitud},${widget.station.longitud}&travelmode=driving';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el mapa')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.nombre),
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
            child: _loadingLocation
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
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
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    widget.station.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Dirección: ${widget.station.direccion}"),
                  Text("Marca: ${widget.station.marca}"),
                  const SizedBox(height: 8),
                  Text(
                    "Gasolina 95: ${widget.station.gasolina95?.toStringAsFixed(2) ?? "-"} €",
                  ),
                  Text(
                    "Diésel: ${widget.station.diesel?.toStringAsFixed(2) ?? "-"} €",
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _launchMaps,
                    icon: const Icon(Icons.directions),
                    label: const Text("Cómo llegar"),
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
