import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/map_tools.dart';
import '../../l10n/l10n.dart';
import 'charging_detail_page.dart';
import 'charging_point.dart';
import 'charging_widgets.dart';

/// Mapa de puntos de recarga con el precio por kWh en cada marcador.
class ChargingMapPage extends StatefulWidget {
  const ChargingMapPage({super.key, required this.points});

  final List<ChargingPoint> points;

  @override
  State<ChargingMapPage> createState() => _ChargingMapPageState();
}

class _ChargingMapPageState extends State<ChargingMapPage> {
  GoogleMapController? _controller;
  late final Future<Set<Marker>> _markers = _buildMarkers();
  final Map<String, Future<BitmapDescriptor>> _icons = {};

  static const _cluster = ClusterManagerId('recarga');

  Future<Set<Marker>> _buildMarkers() async {
    // Se lee antes de cualquier await: _markers se crea en el primer build.
    final l10n = context.l10n;
    final markers = <Marker>{};
    for (final point in widget.points) {
      final label = evPriceLabel(l10n, point);
      final color = point.status == ChargingStatus.notOperational
          ? Colors.grey
          : evColor;
      final icon = await (_icons['$label-${color.toARGB32()}'] ??= priceMarker(
        label,
        color,
      ));
      markers.add(
        Marker(
          markerId: MarkerId('ev-${point.id}'),
          clusterManagerId: _cluster,
          position: LatLng(point.latitude, point.longitude),
          icon: icon,
          onTap: () => _showSheet(point),
        ),
      );
    }
    return markers;
  }

  void _showSheet(ChargingPoint point) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (point.address != null) ...[
                  const SizedBox(height: 4),
                  Text(point.address!),
                ],
                const SizedBox(height: 12),
                ChargingPriceSummary(point: point),
                const SizedBox(height: 8),
                ConnectorChips(point: point),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChargingDetailPage(point: point),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                        label: Text(l10n.stationViewDetail),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => launchDirections(
                          context,
                          latitude: point.latitude,
                          longitude: point.longitude,
                          title: point.name,
                        ),
                        icon: const Icon(Icons.directions),
                        label: Text(l10n.stationDirections),
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

  Future<void> _fit() async {
    final points = widget.points;
    if (points.isEmpty) return;
    if (points.length == 1) {
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(points.first.latitude, points.first.longitude),
          14,
        ),
      );
      return;
    }
    final lats = points.map((p) => p.latitude).toList()..sort();
    final lons = points.map((p) => p.longitude).toList()..sort();
    await _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(lats.first - 0.001, lons.first - 0.001),
          northeast: LatLng(lats.last + 0.001, lons.last + 0.001),
        ),
        48,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.evMapTitle(widget.points.length)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.view_list_outlined),
            label: Text(l10n.stationViewList),
          ),
        ],
      ),
      body: FutureBuilder<Set<Marker>>(
        future: _markers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.stationMapLoadError));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.points.first.latitude,
                    widget.points.first.longitude,
                  ),
                  zoom: 12,
                ),
                markers: snapshot.data!,
                clusterManagers: {
                  ClusterManager(
                    clusterManagerId: _cluster,
                    onClusterTap: (cluster) => _controller?.animateCamera(
                      CameraUpdate.newLatLngBounds(cluster.bounds, 80),
                    ),
                  ),
                },
                mapToolbarEnabled: false,
                padding: EdgeInsets.only(
                  bottom: 72 + MediaQuery.paddingOf(context).bottom,
                ),
                onMapCreated: (controller) {
                  _controller = controller;
                  _fit();
                },
              ),
              // Atribución de Open Charge Map, siempre visible.
              Positioned(
                left: 8,
                right: 72,
                bottom: 8 + MediaQuery.paddingOf(context).bottom,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const OcmAttribution(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: l10n.stationShowAllResults,
        onPressed: _fit,
        child: const Icon(Icons.zoom_out_map),
      ),
    );
  }
}
