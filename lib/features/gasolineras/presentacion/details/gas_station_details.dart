import 'package:gasolineras_can/core/format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/station_price_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _moneyController = TextEditingController();
  bool _isMoneyToLiters = false; // false = litros a €, true = € a litros.
  List<GasStation> _nearbyStations = [];
  bool _loadingSavings = true;

  // Mapa individual
  LatLng? _userPosition;
  List<LatLng> _routePoints = [];
  bool _loadingMap = true;

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
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        if (mounted) setState(() => _loadingMap = false);
        return;
      }
      final pos = await determinePosition();
      final origin = LatLng(pos.latitude, pos.longitude);
      final destination = LatLng(
        widget.station.latitud,
        widget.station.longitud,
      );

      final route = await widget.directionsRepository.getRoute(
        origin,
        destination,
      );

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
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
      final pos = await determinePosition();
      final stations = await GasStationRepository().fetchStations(
        pos.latitude,
        pos.longitude,
      );
      if (mounted) {
        setState(
          () => _nearbyStations = stations.where((s) {
            s.calcularDistancia(pos.latitude, pos.longitude);
            return (s.distancia ?? double.infinity) <= 16;
          }).toList(),
        );
      }
    } catch (_) {
      // The cost calculation remains available without nearby comparisons.
    } finally {
      if (mounted) setState(() => _loadingSavings = false);
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
    _moneyController.dispose();
    super.dispose();
  }

  void _syncValuesOnModeChange() {
    final price = widget.station.priceFor(widget.preferredFuel);
    if (price == null || price <= 0) return;

    if (_isMoneyToLiters) {
      // Pasamos de litros a dinero: pre-rellenamos con el coste equivalente.
      final liters = double.tryParse(
        _litersController.text.replaceAll(',', '.'),
      );
      if (liters != null && liters > 0) {
        _moneyController.text = decimal(liters * price, 2);
      }
    } else {
      // Pasamos de dinero a litros: pre-rellenamos con los litros equivalentes.
      final money = double.tryParse(_moneyController.text.replaceAll(',', '.'));
      if (money != null && money > 0) {
        _litersController.text = (money / price).toStringAsFixed(0);
      }
    }
  }

  Future<void> _launchMaps() async {
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
          destination: Coords(widget.station.latitud, widget.station.longitud),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al abrir el mapa: $e')));
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      destination: Coords(
                        widget.station.latitud,
                        widget.station.longitud,
                      ),
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

  Future<void> _saveTankSize(String value) async {
    final liters = double.tryParse(value.replaceAll(',', '.'));
    if (liters != null && liters > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('tankLiters', liters);
    }
  }

  Widget _buildSavingsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final fuelColor = FuelColors.of(widget.preferredFuel);
    final stationPrice = widget.station.priceFor(widget.preferredFuel);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: fuelColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Calcula tu repostaje',
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
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Litros a €'),
                  icon: Icon(Icons.local_gas_station),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('€ a litros'),
                  icon: Icon(Icons.euro),
                ),
              ],
              selected: {_isMoneyToLiters},
              onSelectionChanged: (selected) {
                setState(() {
                  _isMoneyToLiters = selected.first;
                  _syncValuesOnModeChange();
                });
              },
            ),
            const SizedBox(height: 12),
            _buildCalculatorInput(stationPrice),
            const SizedBox(height: 12),
            _buildSavingsResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorInput(double? stationPrice) {
    if (_isMoneyToLiters) {
      return TextField(
        controller: _moneyController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*')),
        ],
        decoration: InputDecoration(
          labelText: 'Dinero disponible',
          prefixIcon: const Icon(Icons.euro),
          border: const OutlineInputBorder(),
          suffixText: '€',
          helperText: stationPrice == null
              ? 'No hay precio para ${widget.preferredFuel.displayName}'
              : 'Precio ${widget.preferredFuel.displayName}: ${decimal(stationPrice, 3)} €/L',
        ),
        onChanged: (_) => setState(() {}),
      );
    }

    return TextField(
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
            : 'Precio ${widget.preferredFuel.displayName}: ${decimal(stationPrice, 3)} €/L',
      ),
      onChanged: (_) => setState(() {}),
      onSubmitted: _saveTankSize,
    );
  }

  Widget _buildSavingsResult() {
    return _isMoneyToLiters
        ? _buildMoneyToLitersResult()
        : _buildLitersToMoneyResult();
  }

  Widget _buildLitersToMoneyResult() {
    final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
    final stationPrice = widget.station.priceFor(widget.preferredFuel);
    final maxPrice = _maxNearbyPrice();
    final colorScheme = Theme.of(context).colorScheme;
    final fuelColor = FuelColors.of(widget.preferredFuel);

    if (liters == null || liters <= 0 || stationPrice == null) {
      return Text(
        'Introduce los litros de tu depósito para ver el ahorro estimado.',
        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
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
            '${decimal(costHere, 2)} €',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: fuelColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _loadingSavings
                ? 'Consultando precios cercanos…'
                : 'Estimación del combustible; no incluye desplazamiento.',
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
          '${decimal(costHere, 2)} €',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: fuelColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildSavingsBox(
          title: 'Ahorras ${decimal(savings, 2)} €',
          subtitle:
              'Frente al mayor precio a 16 km de tu ubicación (${decimal(maxPrice, 3)} €/L). No incluye desplazamiento.',
        ),
      ],
    );
  }

  Widget _buildMoneyToLitersResult() {
    final money = double.tryParse(_moneyController.text.replaceAll(',', '.'));
    final stationPrice = widget.station.priceFor(widget.preferredFuel);
    final maxPrice = _maxNearbyPrice();
    final colorScheme = Theme.of(context).colorScheme;
    final fuelColor = FuelColors.of(widget.preferredFuel);

    if (money == null ||
        money <= 0 ||
        stationPrice == null ||
        stationPrice <= 0) {
      return Text(
        'Introduce la cantidad de dinero para ver cuántos litros obtienes.',
        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
      );
    }

    final litersHere = money / stationPrice;

    if (maxPrice == null || maxPrice <= stationPrice) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Con ${decimal(money, 2)} € obtienes:',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            '${decimal(litersHere, 2)} L',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: fuelColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _loadingSavings
                ? 'Consultando precios cercanos…'
                : 'Estimación del combustible; no incluye desplazamiento.',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }

    final litersMax = money / maxPrice;
    final savingsLiters = litersHere - litersMax;
    final savingsMoney = savingsLiters * stationPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Con ${decimal(money, 2)} € obtienes:',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          '${decimal(litersHere, 2)} L',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: fuelColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildSavingsBox(
          title: 'Sacas ${decimal(savingsLiters, 2)} L más',
          subtitle:
              'Ahorro equivalente: ${decimal(savingsMoney, 2)} € · Frente a ${decimal(maxPrice, 3)} €/L',
        ),
      ],
    );
  }

  Widget _buildSavingsBox({required String title, required String subtitle}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  subtitle,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de gasolinera'),
        actions: [
          FavoriteWidget(
            station: widget.station,
            repository: widget.favoriteRepository,
          ),
        ],
      ),
      // Sin SafeArea abajo: el contenido pasa por debajo del indicador de
      // inicio en vez de cortarse en seco; el margen final lo compensa.
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Text(
              widget.station.nombre,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              [
                widget.station.direccion,
                widget.station.municipio,
              ].where((part) => part.isNotEmpty).join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StationPriceSummary(
                  fuel: widget.preferredFuel,
                  price: widget.station.priceFor(widget.preferredFuel),
                  liters: liters ?? widget.tankLiters,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _launchMaps,
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Cómo llegar'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 20),
            _buildSavingsCard(),
            const SizedBox(height: 24),
            Text('Precios por combustible', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildFuelPriceGrid(),
            const SizedBox(height: 24),
            Text('Ubicación', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _loadingMap
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.station.latitud,
                            widget.station.longitud,
                          ),
                          zoom: 14,
                        ),
                        mapToolbarEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('station'),
                            position: LatLng(
                              widget.station.latitud,
                              widget.station.longitud,
                            ),
                            infoWindow: InfoWindow(
                              title: widget.station.nombre,
                            ),
                          ),
                          if (_userPosition != null)
                            Marker(
                              markerId: const MarkerId('user'),
                              position: _userPosition!,
                              infoWindow: const InfoWindow(
                                title: 'Tu ubicación',
                              ),
                            ),
                        },
                        polylines: {
                          if (_routePoints.isNotEmpty)
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: _routePoints,
                              color: theme.colorScheme.primary,
                              width: 5,
                            ),
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelPriceGrid() {
    final theme = Theme.of(context);
    final fuels = FuelType.values
        .where((f) => widget.station.priceFor(f) != null)
        .toList();
    if (fuels.isEmpty) {
      return const Text('No hay precios disponibles para esta estación.');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 340 &&
                MediaQuery.textScalerOf(context).scale(14) <= 20
            ? 2
            : 1;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fuels.map((fuel) {
            final active = fuel == widget.preferredFuel;
            return SizedBox(
              width: (constraints.maxWidth - (columns - 1) * 8) / columns,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: active
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fuel.displayName,
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                          if (active)
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: theme.colorScheme.onPrimaryContainer,
                              semanticLabel: 'Tu combustible',
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${decimal(widget.station.priceFor(fuel)!, 3)} €/L',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
