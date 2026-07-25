import 'package:flutter/material.dart';

enum FuelType { g95, g98, diesel, dieselPremium }

extension FuelTypeName on FuelType {
  String get displayName {
    switch (this) {
      case FuelType.g95:
        return 'Gasolina 95';
      case FuelType.g98:
        return 'Gasolina 98';
      case FuelType.diesel:
        return 'Diésel';
      case FuelType.dieselPremium:
        return 'Diésel Premium';
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
