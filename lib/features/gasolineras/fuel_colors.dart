import 'package:flutter/material.dart';
import 'package:gasolineras_can/l10n/l10n.dart';

enum FuelType { g95, g98, diesel, dieselPremium }

extension FuelTypeName on FuelType {
  /// Nombre traducido del combustible con los textos de [l10n]. En las
  /// pantallas: `fuel.label(context.l10n)`.
  String label(AppLocalizations l10n) {
    switch (this) {
      case FuelType.g95:
        return l10n.fuelGasoline95;
      case FuelType.g98:
        return l10n.fuelGasoline98;
      case FuelType.diesel:
        return l10n.fuelDiesel;
      case FuelType.dieselPremium:
        return l10n.fuelDieselPremium;
    }
  }

  String get shortLabel {
    switch (this) {
      case FuelType.g95:
        return '95';
      case FuelType.g98:
        return '98';
      case FuelType.diesel:
        return 'D';
      case FuelType.dieselPremium:
        return 'DP';
    }
  }
}

/// Única fuente de verdad para el color de cada tipo de combustible.
/// Antes cada pantalla (listado, favoritos, detalle) definía su propio
/// mapeo de colores por separado, y se habían desincronizado: por
/// ejemplo, el diésel premium salía gris en listado/detalle pero podía
/// salir verde/naranja/rojo en favoritos.
class FuelColors {
  FuelColors._();

  static Color of(FuelType type) {
    switch (type) {
      case FuelType.g95:
        return Colors.green;
      case FuelType.g98:
        return Colors.blue;
      case FuelType.diesel:
      case FuelType.dieselPremium:
        return Colors.grey[900]!;
    }
  }
}
