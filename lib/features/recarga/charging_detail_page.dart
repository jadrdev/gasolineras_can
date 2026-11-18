import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/map_tools.dart';
import '../../l10n/l10n.dart';
import 'charging_point.dart';
import 'charging_widgets.dart';

/// Ficha de un punto de recarga: precio, conectores, calculadora y ruta.
class ChargingDetailPage extends StatefulWidget {
  const ChargingDetailPage({super.key, required this.point});

  final ChargingPoint point;

  @override
  State<ChargingDetailPage> createState() => _ChargingDetailPageState();
}

class _ChargingDetailPageState extends State<ChargingDetailPage> {
  final _kwh = TextEditingController(text: '40');

  @override
  void dispose() {
    _kwh.dispose();
    super.dispose();
  }

  double? get _kwhValue {
    final value = double.tryParse(_kwh.text.replaceAll(',', '.'));
    return value != null && value > 0 && value <= 200 ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final point = widget.point;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.evDetailTitle)),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            32 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Text(
              point.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (point.address != null || point.town != null)
              Text(
                [
                  point.address,
                  point.town,
                ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (point.operator != null) ...[
              const SizedBox(height: 4),
              Text(point.operator!, style: theme.textTheme.titleSmall),
            ],
            if (point.status == ChargingStatus.notOperational) ...[
              const SizedBox(height: 8),
              Text(
                l10n.evOutOfService,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChargingPriceSummary(point: point),
                    const SizedBox(height: 4),
                    if (point.priceKwh != null || point.free)
                      Text(
                        l10n.evPriceCommunity,
                        style: theme.textTheme.bodySmall,
                      )
                    else if (point.usageCost != null)
                      Text(
                        l10n.evListedPrice(point.usageCost!),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (point.updated != null)
                      Text(
                        l10n.evReviewedAt(evDate(l10n, point.updated!)),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => launchDirections(
                context,
                latitude: point.latitude,
                longitude: point.longitude,
                title: point.name,
              ),
              icon: const Icon(Icons.directions),
              label: Text(l10n.stationDirections),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.evConnectors,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (final c in point.connectors)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.ev_station_outlined),
                      title: Text(
                        c.label.isEmpty ? connectorName(l10n, c.kind) : c.label,
                      ),
                      subtitle: c.kw == null
                          ? null
                          : Text(
                              '${decimal(c.kw!, c.kw! % 1 == 0 ? 0 : 1)} kW',
                            ),
                      trailing: Text('×${c.quantity}'),
                    ),
                  if (point.connectors.isEmpty)
                    ListTile(dense: true, title: Text(l10n.evConnOther)),
                ],
              ),
            ),
            if (point.priceKwh != null) ...[
              const SizedBox(height: 16),
              _calculator(l10n, theme, point.priceKwh!),
            ],
            const SizedBox(height: 24),
            const OcmAttribution(),
          ],
        ),
      ),
    );
  }

  Widget _calculator(AppLocalizations l10n, ThemeData theme, double price) {
    final kwh = _kwhValue;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: evColor),
                const SizedBox(width: 8),
                Text(
                  l10n.evCalcTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kwh,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.evCalcKwh,
                suffixText: 'kWh',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (kwh != null) ...[
              const SizedBox(height: 12),
              Text(l10n.evCalcCost(decimal(kwh, kwh % 1 == 0 ? 0 : 1))),
              Text(
                euros(price * kwh, 2),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: evColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(l10n.evCalcNote, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
