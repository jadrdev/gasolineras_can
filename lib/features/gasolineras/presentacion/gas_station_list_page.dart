import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config.dart';
import '../../../core/directions_service.dart';
import '../../../core/location.dart';
import '../../auth/user_profile_repository.dart';
import '../../favoritos/data.dart';
import '../../favoritos/presentacion.dart';
import '../BLoC/gas_station_bloc.dart';
import '../data/gas_station_repository.dart';
import '../data/station_search.dart';
import 'widgets/station_price_summary.dart';
import '../fuel_colors.dart';
import '../models/gas_station.dart';
import 'details/gas_station_details.dart';
import 'map/gas_station_map_page.dart';
import 'station_search_field.dart';

enum SortBy { precio, distancia }

class GasStationListPage extends StatefulWidget {
  final GasStationRepository? stationRepository;
  final FavoriteRepository? favoriteRepository;
  final Future<Position> Function()? locate;
  final Future<UserProfile?> Function()? loadProfile;
  const GasStationListPage({
    super.key,
    this.stationRepository,
    this.favoriteRepository,
    this.locate,
    this.loadProfile,
  });
  @override
  State<GasStationListPage> createState() => _GasStationListPageState();
}

class _GasStationListPageState extends State<GasStationListPage> {
  late final GasStationBloc _bloc;
  late final _favorites = widget.favoriteRepository ?? FavoriteRepository();
  final _search = TextEditingController();
  StreamSubscription<void>? _profileSubscription;
  SortBy _sort = SortBy.precio;
  FuelType _fuel = FuelType.g95;
  double _tankLiters = 50;
  Position? _position;
  String _zone = 'nearby';
  String _query = '';
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _bloc = GasStationBloc(widget.stationRepository ?? GasStationRepository());
    _profileSubscription = UserProfileRepository.changes.listen(
      (_) => _loadPreferences(),
    );
    _loadPreferences();
    // Browsing/search does not wait for GPS permission or a location fix.
    _bloc.add(LoadStations());
    _locate();
  }

  Future<void> _locate({
    bool forceRefresh = false,
    bool requestPermission = false,
  }) async {
    if (_locating) return;
    setState(() => _locating = true);
    Position? position;
    try {
      if (widget.locate == null && !requestPermission) {
        final permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          if (mounted) setState(() => _locating = false);
          return;
        }
      }
      position =
          await (widget.locate?.call() ??
              determinePosition(forceRefresh: forceRefresh));
    } catch (_) {
      /* Manual search remains available. */
    }
    if (!mounted) return;
    setState(() {
      _position = position;
      _locating = false;
      final state = _bloc.state;
      if (position != null && state is GasStationLoaded) {
        for (final station in state.stations) {
          station.calcularDistancia(position.latitude, position.longitude);
        }
      }
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final fuel = prefs.getString('fuelType');
    UserProfile? profile;
    try {
      profile =
          await (widget.loadProfile?.call() ??
              UserProfileRepository().getProfile());
    } catch (_) {
      /* Use local settings. */
    }
    if (!mounted) return;
    setState(() {
      _sort = SortBy.values.firstWhere(
        (v) => v.name == prefs.getString('sortBy'),
        orElse: () => SortBy.precio,
      );
      _fuel =
          profile?.preferredFuel ??
          FuelType.values.firstWhere(
            (v) => v.name == fuel,
            orElse: () => FuelType.g95,
          );
      _tankLiters = profile?.tankLiters ?? prefs.getDouble('tankLiters') ?? 50;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fuelType', _fuel.name);
    await prefs.setString('sortBy', _sort.name);
  }

  Future<void> _refresh() async {
    unawaited(_locate(forceRefresh: true));
    // Subscribe before dispatching and keep the refresh indicator until completion.
    final done = _bloc.stream.firstWhere(
      (s) => s is GasStationLoaded || s is GasStationError,
    );
    _bloc.add(
      LoadStations(
        lat: _position?.latitude,
        lng: _position?.longitude,
        forceRefresh: true,
      ),
    );
    await done;
  }

  List<GasStation> _visibleStations(List<GasStation> stations) {
    for (final station in stations) {
      if (_position != null) {
        station.calcularDistancia(_position!.latitude, _position!.longitude);
      }
    }
    final filtered = stations.where((s) {
      if (!matchesStation(s, _query)) return false;
      if (_zone.startsWith('municipio:')) {
        return s.municipio == _zone.substring(10);
      }
      // Typing searches every island; the 16 km radius must not hide matches.
      if (_zone == 'nearby' && _query.trim().isEmpty && _position != null) {
        return (s.distancia ?? double.infinity) <= 16;
      }
      return true;
    }).toList();
    filtered.sort((a, b) {
      final comparison = _sort == SortBy.precio
          ? (a.priceFor(_fuel) ?? double.infinity).compareTo(
              b.priceFor(_fuel) ?? double.infinity,
            )
          : (a.distancia ?? double.infinity).compareTo(
              b.distancia ?? double.infinity,
            );
      if (comparison != 0) return comparison;
      final distance = (a.distancia ?? double.infinity).compareTo(
        b.distancia ?? double.infinity,
      );
      return distance != 0 ? distance : a.nombre.compareTo(b.nombre);
    });
    return filtered;
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _search.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<GasStationBloc, GasStationState>(
    bloc: _bloc,
    builder: (context, state) {
      final stations = state is GasStationLoaded
          ? state.stations
          : <GasStation>[];
      final filtered = _visibleStations(stations);
      final municipalities =
          stations
              .map((s) => s.municipio)
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList()
            ..sort(
              (a, b) =>
                  normalizeStationText(a).compareTo(normalizeStationText(b)),
            );
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gasolineras'),
          actions: [
            if (_position == null)
              IconButton(
                tooltip: 'Usar mi ubicación',
                onPressed: _locating
                    ? null
                    : () =>
                          _locate(forceRefresh: true, requestPermission: true),
                icon: const Icon(Icons.my_location),
              ),
            IconButton(
              tooltip: 'Actualizar precios',
              onPressed: state is GasStationLoading ? null : _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: StationSearchField(
                controller: _search,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value:
                            _zone.startsWith('municipio:') &&
                                !municipalities.contains(_zone.substring(10))
                            ? null
                            : _zone,
                        hint: Text(_zone.replaceFirst('municipio:', '')),
                        selectedItemBuilder: (_) => [
                          _zoneLabel(
                            _position == null || _query.trim().isNotEmpty
                                ? 'Toda Canarias'
                                : 'Cerca de mí · 16 km',
                          ),
                          _zoneLabel('Toda Canarias'),
                          ...municipalities.map(_zoneLabel),
                        ],
                        items: [
                          const DropdownMenuItem(
                            value: 'nearby',
                            child: Text('Cerca de mí · 16 km'),
                          ),
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('Toda Canarias'),
                          ),
                          ...municipalities.map(
                            (m) => DropdownMenuItem(
                              value: 'municipio:$m',
                              child: Text(m, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _zone = value);
                          if (value == 'nearby') {
                            _locate(
                              forceRefresh: true,
                              requestPermission: true,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<FuelType>(
                    tooltip: 'Combustible: ${_fuel.displayName}',
                    initialValue: _fuel,
                    itemBuilder: (_) => FuelType.values
                        .map(
                          (fuel) => PopupMenuItem(
                            value: fuel,
                            child: Text(fuel.displayName),
                          ),
                        )
                        .toList(),
                    onSelected: (fuel) {
                      setState(() => _fuel = fuel);
                      _savePreferences();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _fuel.shortLabel,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<SortBy>(
                    tooltip: 'Ordenar resultados',
                    initialValue: _sort,
                    icon: const Icon(Icons.sort),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: SortBy.precio,
                        child: Text('Por precio'),
                      ),
                      PopupMenuItem(
                        value: SortBy.distancia,
                        enabled: _position != null,
                        child: const Text('Por distancia en línea recta'),
                      ),
                    ],
                    onSelected: (sort) {
                      setState(() => _sort = sort);
                      _savePreferences();
                    },
                  ),
                ],
              ),
            ),
            if (_zone == 'nearby' && _query.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Búsqueda por texto en toda Canarias',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            if (state is GasStationLoaded && state.offline)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'No se pudieron actualizar los precios. Mostrando datos guardados del ${_date(state.fetchedAt)}.',
                ),
              ),
            if (state is GasStationLoaded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${filtered.length} gasolineras · ${_sort == SortBy.precio ? 'Precio' : 'Distancia'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: const Text('Lista'),
                          icon: MediaQuery.textScalerOf(context).scale(14) > 18
                              ? null
                              : const Icon(Icons.view_list_outlined),
                        ),
                        ButtonSegment(
                          value: true,
                          label: const Text('Mapa'),
                          icon: MediaQuery.textScalerOf(context).scale(14) > 18
                              ? null
                              : const Icon(Icons.map_outlined),
                        ),
                      ],
                      selected: const {false},
                      onSelectionChanged: filtered.isEmpty
                          ? null
                          : (selection) {
                              if (!selection.first) return;
                              FocusScope.of(context).unfocus();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GasStationMapPage(
                                    stations: filtered,
                                    preferredFuel: _fuel,
                                    tankLiters: _tankLiters,
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: state is GasStationLoaded
                    ? ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filtered.isEmpty ? 1 : filtered.length,
                        itemBuilder: (context, index) => filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    const Icon(Icons.search_off, size: 40),
                                    const Text(
                                      'No se han encontrado gasolineras',
                                    ),
                                    const Text(
                                      'Prueba con parte del nombre, otra marca o un municipio.',
                                    ),
                                    TextButton(
                                      onPressed: () => setState(() {
                                        _zone = 'all';
                                        _query = '';
                                        _search.clear();
                                      }),
                                      child: const Text(
                                        'Borrar búsqueda y ver toda Canarias',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _stationCard(filtered[index]),
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 40),
                          if (state is GasStationError) ...[
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Center(
                              child: FilledButton(
                                onPressed: _refresh,
                                child: const Text('Reintentar'),
                              ),
                            ),
                          ] else
                            const Center(child: CircularProgressIndicator()),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _zoneLabel(String label) => Align(
    alignment: Alignment.centerLeft,
    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
  );

  static String _date(DateTime? date) => date == null
      ? 'fecha desconocida'
      : '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Widget _stationCard(GasStation station) {
    final price = station.priceFor(_fuel);
    final stale =
        station.lastUpdate == null ||
        DateTime.now().difference(station.lastUpdate!).inHours >= 48;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GasStationDetailPage(
              station: station,
              favoriteRepository: _favorites,
              directionsRepository: DirectionsService(
                AppConfig.googleMapsApiKey,
              ),
              preferredFuel: _fuel,
              tankLiters: _tankLiters,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                          station.nombre,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          [
                            station.municipio,
                            station.direccion,
                          ].where((part) => part.isNotEmpty).join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  FavoriteWidget(
                    key: ValueKey(station.id),
                    station: station,
                    repository: _favorites,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StationPriceSummary(
                fuel: _fuel,
                price: price,
                liters: _tankLiters,
              ),
              const SizedBox(height: 8),
              if (station.distancia != null)
                Text(
                  '${station.distancia!.toStringAsFixed(1)} km en línea recta',
                ),
              Text(
                '${stale ? 'Precio sin actualización reciente · ' : 'Actualizado · '}${_date(station.lastUpdate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: stale ? Theme.of(context).colorScheme.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
