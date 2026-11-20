import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../../core/format.dart';
import '../../l10n/l10n.dart';
import 'charging_point.dart';

/// Color de los puntos de recarga (marcadores, etiquetas).
const evColor = Color(0xFF0E9F6E);

String connectorName(AppLocalizations l10n, ConnectorKind kind) =>
    switch (kind) {
      ConnectorKind.type2 => l10n.evConnType2,
      ConnectorKind.ccs => 'CCS',
      ConnectorKind.chademo => 'CHAdeMO',
      ConnectorKind.tesla => 'Tesla',
      ConnectorKind.type1 => l10n.evConnType1,
      ConnectorKind.schuko => 'Schuko',
      ConnectorKind.other => l10n.evConnOther,
    };

/// Precio corto para marcadores y listas: «0,39», «Gratis» o «—».
String evPriceLabel(AppLocalizations l10n, ChargingPoint point) {
  if (point.free) return l10n.evFree;
  if (point.priceKwh == null) return '—';
  return decimal(point.priceKwh!, 2);
}

/// Fecha corta en el formato del idioma (británico en inglés).
String evDate(AppLocalizations l10n, DateTime date) {
  final locale = l10n.localeName == 'en' ? 'en_GB' : l10n.localeName;
  return DateFormat.yMd(locale).format(date.toLocal());
}

/// Fecha y hora cortas: «20/11/2026 13:05».
String evDateTime(AppLocalizations l10n, DateTime date) {
  final locale = l10n.localeName == 'en' ? 'en_GB' : l10n.localeName;
  return DateFormat.yMd(locale).add_Hm().format(date.toLocal());
}

/// Ocupación ahora (solo Red Eléctrica): «2 libres · 1 ocupado · 1 averiado».
class ChargingOccupancy extends StatelessWidget {
  const ChargingOccupancy({super.key, required this.point, this.style});

  final ChargingPoint point;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium;
    final free = point.available ?? 0;
    final busy = point.occupied ?? 0;
    final broken = point.outOfOrder ?? 0;
    if (point.available == null || free + busy + broken == 0) {
      return const SizedBox.shrink();
    }
    final parts = <TextSpan>[
      if (free > 0)
        TextSpan(
          text: l10n.evFreeCount(free),
          style: const TextStyle(color: evColor, fontWeight: FontWeight.w600),
        ),
      if (busy > 0)
        TextSpan(
          text: l10n.evBusyCount(busy),
          style: TextStyle(color: Colors.orange.shade800),
        ),
      if (broken > 0)
        TextSpan(
          text: l10n.evBrokenCount(broken),
          style: TextStyle(color: theme.colorScheme.error),
        ),
    ];
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            if (i > 0) const TextSpan(text: ' · '),
            parts[i],
          ],
        ],
      ),
    );
  }
}

/// Precio grande de un punto de recarga, como el de las gasolineras.
class ChargingPriceSummary extends StatelessWidget {
  const ChargingPriceSummary({super.key, required this.point});

  final ChargingPoint point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (point.free) {
      return Text(
        l10n.evFree,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: evColor,
        ),
      );
    }
    if (point.priceKwh == null) {
      return Text(
        l10n.evNoPrice,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Text.rich(
      TextSpan(
        text: decimal(point.priceKwh!, 2),
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: ' €/kWh', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Fila de conectores: «CCS · 50 kW · ×2».
class ConnectorChips extends StatelessWidget {
  const ConnectorChips({super.key, required this.point});

  final ChargingPoint point;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // Un chip por tipo, con la potencia máxima de ese tipo.
    final byKind = <ConnectorKind, double?>{};
    for (final c in point.connectors) {
      final current = byKind[c.kind];
      if (!byKind.containsKey(c.kind) || (c.kw ?? 0) > (current ?? 0)) {
        byKind[c.kind] = c.kw;
      }
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in byKind.entries)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.value == null
                  ? connectorName(l10n, entry.key)
                  : '${connectorName(l10n, entry.key)} · '
                        '${decimal(entry.value!, entry.value! % 1 == 0 ? 0 : 1)} kW',
              style: theme.textTheme.labelMedium,
            ),
          ),
      ],
    );
  }
}

/// Fuentes obligatorias: Red Eléctrica (con la fecha de los datos, lo piden
/// sus condiciones) y Open Charge Map (CC BY 4.0). Con [point], solo las de
/// ese punto.
class ChargingAttribution extends StatelessWidget {
  const ChargingAttribution({super.key, this.point});

  final ChargingPoint? point;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = point;
    final reveDate = p == null
        ? ChargingRepository.lastReveSync
        : (p.source == ChargingSource.reve ? p.syncedAt : null);
    final ocm =
        p == null ||
        p.source == ChargingSource.ocm ||
        p.priceSource == ChargingSource.ocm;
    return Text(
      [
        if (reveDate != null) l10n.evSourceReve(evDateTime(l10n, reveDate)),
        if (ocm) l10n.evAttribution,
      ].join('\n'),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
