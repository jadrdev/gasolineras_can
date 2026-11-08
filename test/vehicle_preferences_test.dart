import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolineras_can/features/auth/vehicle_profile_card.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';

void main() {
  testWidgets(
    'Saves newly selected fuel and preserves edited liters on rebuild',
    (tester) async {
      FuelType? savedFuel;
      double? savedLiters;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehiclePreferencesForm(
              initialFuel: FuelType.g95,
              initialLiters: 50,
              initialPlate: '',
              onSave: (fuel, liters, plate) async {
                savedFuel = fuel;
                savedLiters = liters;
              },
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byKey(const ValueKey('vehicle-liters')),
        '42,5',
      );
      await tester.tap(find.byKey(const ValueKey('vehicle-fuel')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Diésel').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar datos del vehículo'));
      await tester.pumpAndSettle();
      expect(savedFuel, FuelType.diesel);
      expect(savedLiters, 42.5);
      expect(find.text('Datos del vehículo guardados'), findsOneWidget);
    },
  );

  testWidgets('Failed save keeps edits and never displays success', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VehiclePreferencesForm(
            initialFuel: FuelType.g95,
            initialLiters: 50,
            initialPlate: '',
            onSave: (_, liters, plate) async => throw Exception('offline'),
          ),
        ),
      ),
    );
    await tester.enterText(find.byKey(const ValueKey('vehicle-liters')), '60');
    await tester.tap(find.text('Guardar datos del vehículo'));
    await tester.pumpAndSettle();
    expect(find.text('Datos del vehículo guardados'), findsNothing);
    expect(
      find.text(
        'No se pudieron guardar los datos. Puedes volver a intentarlo.',
      ),
      findsOneWidget,
    );
    expect(find.text('60'), findsOneWidget);
  });

  testWidgets('Invalid tank size blocks saving', (tester) async {
    var saves = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VehiclePreferencesForm(
            initialFuel: FuelType.g95,
            initialLiters: 50,
            initialPlate: '',
            onSave: (_, liters, plate) async {
              saves++;
            },
          ),
        ),
      ),
    );
    await tester.enterText(find.byKey(const ValueKey('vehicle-liters')), '-1');
    await tester.tap(find.text('Guardar datos del vehículo'));
    await tester.pumpAndSettle();
    expect(saves, 0);
  });
}
