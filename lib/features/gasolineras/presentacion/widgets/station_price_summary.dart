import 'package:gasolineras_can/core/format.dart';
import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fuel.displayName, style: theme.textTheme.labelLarge),
        const SizedBox(height: 2),
        if (price == null)
          const Text('Sin precio disponible')
        else ...[
          Semantics(
            label: '${fuel.displayName}: ${decimal(price!, 3)} euros por litro',
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
              '${decimal(price! * liters, 2)} € para ${decimal(liters, liters == liters.roundToDouble() ? 0 : 1)} L · estimado',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ],
    );
  }
}
