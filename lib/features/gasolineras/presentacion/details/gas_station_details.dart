import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gasolineras_can/features/ads/banner_ad_widget.dart';
import 'package:gasolineras_can/features/auth/user_profile_repository.dart';
import 'package:gasolineras_can/features/directions/domain/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gasolineras_can/core/location.dart';

import 'package:gasolineras_can/features/favoritos/presentacion.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:geolocator/geolocator.dart';

class GasStationDetailPage extends StatefulWidget {
  final GasStation station;
  final FavoriteRepository favoriteRepository;
  final DirectionsRepository directionsRepository;
  final FuelType preferredFuel;
  final double tankLiters;

  const GasStationDetailPage({
    super.key,
    required this.station,
    required this.favoriteRepository,
    required this.directionsRepository,
    this.preferredFuel = FuelType.g95,
    this.tankLiters = 50,
  });

  @override
  State<GasStationDetailPage> createState() => _GasStationDetailPageState();
}

class _GasStationDetailPageState extends State<GasStationDetailPage> {
  final _litersController = TextEditingController();
  List<GasStation> _nearbyStations = [];
  bool _loadingSavings = true;

  // Mapa individual
  LatLng? _userPosition;
  List<LatLng> _routePoints = [];
  bool _loadingMap = true;
  double _fabScale = 1.0;

  @override
  void initState() {
    super.initState();
    _litersController.text = widget.tankLiters.toStringAsFixed(0);
    _loadProfileTankLiters();
    _loadNearbyStations();
    _initMap();
  }

  Future<void> _loadProfileTankLiters() async {
    try {
      final profile = await UserProfileRepository().getProfile();
      final liters = profile?.tankLiters ?? widget.tankLiters;
      if (mounted) {
        setState(() {
          _litersController.text = liters.toStringAsFixed(0);
        });
      }
    } catch (e) {
      // Si no hay usuario o falla Supabase, dejamos el valor recibido.
    }
  }

  Future<void> _initMap() async {
    try {
      final pos = await determinePosition();
      final origin = LatLng(pos.latitude, pos.longitude);
      final destination = LatLng(
        widget.station.latitud,
        widget.station.longitud,
      );

      final route = await widget.directionsRepository.getRoute(origin, destination);

      if (mounted) {
        setState(() {
          _userPosition = origin;
          _routePoints = route;
          _loadingMap = false;
        });
      }
    } on LocationPermissionException catch (e) {
      if (mounted) {
        setState(() => _loadingMap = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Configuración',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingMap = false);
      }
    }
  }

  Future<void> _loadNearbyStations() async {
    try {
      final pos = await determinePosition();
      final repo = GasStationRepository();
      final stations = await repo.fetchStations(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _nearbyStations = stations;
          _loadingSavings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSavings = false);
      }
    }
  }

  double? _maxNearbyPrice() {
    final prices = _nearbyStations
        .map((s) => s.priceFor(widget.preferredFuel))
        .where((p) => p != null)
        .cast<double>()
        .toList();
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a > b ? a : b);
  }

  @override
  void dispose() {
    _litersController.dispose();
    super.dispose();
  }

  Future<void> _launchMaps() async {
    try {
      final pos = await determinePosition();
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
          destination: Coords(widget.station.latitud, widget.station.longitud),
          origin: Coords(pos.latitude, pos.longitude),
          destinationTitle: widget.station.nombre,
        );
        return;
      }

      if (!mounted) return;
      await _showMapOptions(availableMaps);
    } on LocationPermissionException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Configuración',
            onPressed: () => Geolocator.openAppSettings(),
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
                    final pos = await determinePosition();
                    await map.showDirections(
                      destination: Coords(widget.station.latitud, widget.station.longitud),
                      origin: Coords(pos.latitude, pos.longitude),
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

  Future<void> _onMapFabPressed() async {
    setState(() => _fabScale = 0.92);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _fabScale = 1.0);
    await _launchMaps();
  }

  Future<void> _saveTankSize(String value) async {
    final liters = double.tryParse(value.replaceAll(',', '.'));
    if (liters != null && liters > 0) {
      // Guardado local por si el usuario no está logueado.
      // El perfil de Supabase se actualiza desde ProfilePage.
    }
  }

  Widget _buildSavingsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final fuelColor = FuelColors.of(widget.preferredFuel);
    final stationPrice = widget.station.priceFor(widget.preferredFuel);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: fuelColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Calculadora de ahorro',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _litersController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*')),
              ],
              decoration: InputDecoration(
                labelText: 'Litros del depósito',
                prefixIcon: const Icon(Icons.local_gas_station),
                border: const OutlineInputBorder(),
                suffixText: 'L',
                helperText: stationPrice == null
                    ? 'No hay precio para ${widget.preferredFuel.displayName}'
                    : 'Precio ${widget.preferredFuel.displayName}: ${stationPrice.toStringAsFixed(2)} €/L',
              ),
              onChanged: _saveTankSize,
            ),
            const SizedBox(height: 12),
            _buildSavingsResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsResult() {
    final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
    final stationPrice = widget.station.priceFor(widget.preferredFuel);
    final maxPrice = _maxNearbyPrice();
    final colorScheme = Theme.of(context).colorScheme;

    if (_loadingSavings) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Calculando precios cercanos...'),
        ],
      );
    }

    if (liters == null || liters <= 0 || stationPrice == null) {
      return Text(
        'Introduce los litros de tu depósito para ver el ahorro estimado.',
        style: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final costHere = liters * stationPrice;

    if (maxPrice == null || maxPrice <= stationPrice) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Llenar ${liters.toStringAsFixed(0)} L te costaría:',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            '${costHere.toStringAsFixed(2)} €',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: FuelColors.of(widget.preferredFuel),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Esta es una de las opciones más baratas de la zona.',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }

    final costMax = liters * maxPrice;
    final savings = costMax - costHere;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Llenar ${liters.toStringAsFixed(0)} L te costaría:',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          '${costHere.toStringAsFixed(2)} €',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: FuelColors.of(widget.preferredFuel),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.savings, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahorras ${savings.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Frente a ${maxPrice.toStringAsFixed(2)} €/L en la más cara de la zona',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mapa individual compacto
            SizedBox(
              height: 240,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.hardEdge,
                  child: _loadingMap
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
                                if (_userPosition != null)
                                  Marker(
                                    markerId: const MarkerId('user'),
                                    position: _userPosition!,
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
                                onTap: _onMapFabPressed,
                                child: AnimatedScale(
                                  scale: _fabScale,
                                  duration: const Duration(milliseconds: 120),
                                  child: FloatingActionButton.small(
                                    onPressed: _onMapFabPressed,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.station.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.station.direccion,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Marca: ${widget.station.marca}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFuelPriceGrid(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _launchMaps,
                        icon: const Icon(Icons.directions),
                        label: const Text('Cómo llegar'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSavingsCard(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: BannerAdWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelPriceGrid() {
    final fuels = FuelType.values
        .where((f) => widget.station.priceFor(f) != null)
        .toList();

    if (fuels.isEmpty) {
      return const Text('No hay precios disponibles para esta estación.');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: fuels.length,
      itemBuilder: (context, index) {
        final fuel = fuels[index];
        final price = widget.station.priceFor(fuel)!;
        final isActive = fuel == widget.preferredFuel;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: FuelColors.of(fuel),
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: FuelColors.of(fuel).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fuel.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${price.toStringAsFixed(2)} €/L',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
