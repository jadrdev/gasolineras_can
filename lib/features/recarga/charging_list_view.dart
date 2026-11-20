import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/format.dart';
import '../../l10n/l10n.dart';
import '../gasolineras/data/station_search.dart';
import 'charging_detail_page.dart';
import 'charging_map_page.dart';
import 'charging_point.dart';
import 'charging_widgets.dart';

/// Lista de puntos de recarga. Ocupa el sitio de la lista de gasolineras
/// cuando se elige «⚡ Eléctrico» en el selector de combustible.
class ChargingListView extends StatefulWidget {
  const ChargingListView({
    super.key,
    required this.position,
    required this.query,
    required this.nearby,
    required this.sortByPrice,
    this.repository,
  });

  final Position? position;
  final String query;

  /// Solo los de 16 km a la redonda (zona «Cerca de mí» sin búsqueda).
  final bool nearby;
  final bool sortByPrice;
  final ChargingRepository? repository;

  @override
  State<ChargingListView> createState() => ChargingListViewState();
}

class ChargingListViewState extends State<ChargingListView> {
  late final _repository = widget.repository ?? ChargingRepository();
  late Future<List<ChargingPoint>> _points = _repository.all();
  bool _onlyFast = false;
  ConnectorKind? _connector;

  /// La llama el botón de recargar de la pantalla.
  Future<void> refresh() async {
    final future = _repository.all(forceRefresh: true);
    setState(() => _points = future);
    await future.catchError((_) => <ChargingPoint>[]);
  }

  bool _matches(ChargingPoint p) {
    final words = normalizeStationText(
      widget.query,
    ).split(' ').where((w) => w.isNotEmpty);
    if (words.isEmpty) return true;
    final haystack = normalizeStationText(
      [p.name, p.operator, p.address, p.town].whereType<String>().join(' '),
    );
    return words.every(haystack.contains);
  }

  List<ChargingPoint> _visible(List<ChargingPoint> points) {
    final position = widget.position;
    if (position != null) {
      for (final p in points) {
        p.calcDistance(position.latitude, position.longitude);
      }
    }
    final list = points.where((p) {
      if (!_matches(p)) return false;
      if (_onlyFast && !p.fast) return false;
      if (_connector != null && !p.has(_connector!)) return false;
      if (widget.nearby && position != null) {
        return (p.distance ?? double.infinity) <= 16;
      }
      return true;
    }).toList();
    list.sort((a, b) {
      // Los que están fuera de servicio, al final.
      final out =
          (a.status == ChargingStatus.notOperational ? 1 : 0) -
          (b.status == ChargingStatus.notOperational ? 1 : 0);
      if (out != 0) return out;
      final byDistance = (a.distance ?? double.infinity).compareTo(
        b.distance ?? double.infinity,
      );
      if (!widget.sortByPrice) return byDistance;
      final byPrice = a.sortPrice.compareTo(b.sortPrice);
      return byPrice != 0 ? byPrice : byDistance;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<List<ChargingPoint>>(
      future: _points,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ListView(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l10n.evLoadError, textAlign: TextAlign.center),
              ),
              Center(
                child: FilledButton(
                  onPressed: refresh,
                  child: Text(l10n.stationRetry),
                ),
              ),
            ],
          );
        }
        final points = _visible(snapshot.data ?? []);
        return Column(
          children: [
            _filters(l10n),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    widget.sortByPrice
                        ? l10n.evCountByPrice(points.length)
                        : l10n.evCountByDistance(points.length),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.stationViewList),
                        icon: const Icon(Icons.view_list_outlined),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.stationViewMap),
                        icon: const Icon(Icons.map_outlined),
                      ),
                    ],
                    selected: const {false},
                    onSelectionChanged: points.isEmpty
                        ? null
                        : (selection) {
                            if (!selection.first) return;
                            FocusScope.of(context).unfocus();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChargingMapPage(points: points),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: points.length + 1,
                  itemBuilder: (context, index) {
                    if (index == points.length) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          children: [
                            if (points.isEmpty) ...[
                              const Icon(Icons.ev_station_outlined, size: 40),
                              Text(
                                l10n.evNoResults,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                            ],
                            const ChargingAttribution(),
                          ],
                        ),
                      );
                    }
                    return _card(points[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filters(AppLocalizations l10n) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        FilterChip(
          avatar: const Icon(Icons.bolt, size: 18),
          label: Text(l10n.evFilterFast),
          selected: _onlyFast,
          onSelected: (value) => setState(() => _onlyFast = value),
        ),
        for (final kind in const [
          ConnectorKind.type2,
          ConnectorKind.ccs,
          ConnectorKind.chademo,
        ]) ...[
          const SizedBox(width: 8),
          FilterChip(
            label: Text(connectorName(l10n, kind)),
            selected: _connector == kind,
            onSelected: (value) =>
                setState(() => _connector = value ? kind : null),
          ),
        ],
      ],
    ),
  );

  Widget _card(ChargingPoint point) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final subtitle = [
      point.town,
      point.address,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChargingDetailPage(point: point)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(point.name, style: theme.textTheme.titleMedium),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (point.operator != null)
                Text(point.operator!, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              ChargingPriceSummary(point: point),
              const SizedBox(height: 8),
              ConnectorChips(point: point),
              const SizedBox(height: 8),
              if (point.distance != null)
                Text(l10n.stationStraightLineKm(decimal(point.distance!, 1))),
              if (point.available != null &&
                  point.status != ChargingStatus.notOperational)
                ChargingOccupancy(
                  point: point,
                  style: theme.textTheme.bodySmall,
                )
              else if (point.status == ChargingStatus.notOperational)
                Text(
                  l10n.evOutOfService,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
