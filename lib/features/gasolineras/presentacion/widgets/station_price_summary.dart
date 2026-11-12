import 'package:gasolineras_can/core/format.dart';
import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:gasolineras_can/l10n/l10n.dart';

/// A readable price hierarchy shared by the list and station detail.
class StationPriceSummary extends StatelessWidget {
  final FuelType fuel;
  final double? price;
  final double liters;

  const StationPriceSummary({
    super.key,
    required this.fuel,
    required this.price,
    required this.liters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final fuelName = fuel.label(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fuelName, style: theme.textTheme.labelLarge),
        const SizedBox(height: 2),
        if (price == null)
          Text(l10n.stationNoPrice)
        else ...[
          Semantics(
            label: l10n.stationPricePerLitreSemantics(
              fuelName,
              decimal(price!, 3),
            ),
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                text: decimal(price!, 3),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  TextSpan(text: ' €/L', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ),
          if (liters.isFinite && liters > 0)
            Text(
              l10n.stationTankEstimate(
                decimal(price! * liters, 2),
                decimal(liters, liters == liters.roundToDouble() ? 0 : 1),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ],
    );
  }
}
