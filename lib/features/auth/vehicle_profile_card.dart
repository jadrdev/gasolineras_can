import 'package:flutter/material.dart';
import '../gasolineras/fuel_colors.dart';
import 'user_profile_repository.dart';

class VehicleProfileCard extends StatefulWidget {
  const VehicleProfileCard({super.key});
  @override
  State<VehicleProfileCard> createState() => _VehicleProfileCardState();
}

class _VehicleProfileCardState extends State<VehicleProfileCard> {
  final _repository = UserProfileRepository();
  late Future<UserProfile?> _profile = _repository.getProfile();
  @override
  Widget build(BuildContext context) => FutureBuilder<UserProfile?>(
    future: _profile,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (snapshot.hasError) {
        return Column(
          children: [
            const Text('No se pudieron cargar los datos del vehículo.'),
            TextButton(
              onPressed: () =>
                  setState(() => _profile = _repository.getProfile()),
              child: const Text('Reintentar'),
            ),
          ],
        );
      }
      return VehiclePreferencesForm(
        initialFuel: snapshot.data?.preferredFuel ?? FuelType.g95,
        initialLiters: snapshot.data?.tankLiters ?? 50,
        initialPlate: snapshot.data?.licensePlate ?? '',
        onSave: (fuel, liters, plate) => _repository.updatePreferences(
          preferredFuel: fuel,
          tankLiters: liters,
          licensePlate: plate,
        ),
      );
    },
  );
}

class VehiclePreferencesForm extends StatefulWidget {
  final FuelType initialFuel;
  final double initialLiters;
  final String initialPlate;
  final Future<void> Function(FuelType, double, String) onSave;
  const VehiclePreferencesForm({
    super.key,
    required this.initialFuel,
    required this.initialLiters,
    required this.initialPlate,
    required this.onSave,
  });
  @override
  State<VehiclePreferencesForm> createState() => _VehiclePreferencesFormState();
}

class _VehiclePreferencesFormState extends State<VehiclePreferencesForm> {
  final _form = GlobalKey<FormState>();
  late FuelType _fuel = widget.initialFuel;
  late final _liters = TextEditingController(
    text: widget.initialLiters.toString(),
  );
  late final _plate = TextEditingController(text: widget.initialPlate);
  bool _saving = false;

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _fuel,
        double.parse(_liters.text.replaceAll(',', '.')),
        _plate.text.trim().toUpperCase(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos del vehículo guardados')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron guardar los datos. Puedes volver a intentarlo.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _liters.dispose();
    _plate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mi vehículo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<FuelType>(
              key: const ValueKey('vehicle-fuel'),
              initialValue: _fuel,
              decoration: const InputDecoration(
                labelText: 'Combustible habitual',
                border: OutlineInputBorder(),
              ),
              items: FuelType.values
                  .map(
                    (fuel) => DropdownMenuItem(
                      value: fuel,
                      child: Text(fuel.displayName),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (fuel) {
                      if (fuel != null) setState(() => _fuel = fuel);
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('vehicle-liters'),
              controller: _liters,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Litros del depósito',
                suffixText: 'L',
                border: OutlineInputBorder(),
              ),
              validator: (text) {
                final liters = double.tryParse(
                  (text ?? '').replaceAll(',', '.'),
                );
                return liters == null ||
                        !liters.isFinite ||
                        liters <= 0 ||
                        liters > 1000
                    ? 'Introduce una capacidad entre 0 y 1000 litros, mayor que cero.'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('vehicle-plate'),
              controller: _plate,
              enabled: !_saving,
              textCapitalization: TextCapitalization.characters,
              maxLength: 15,
              decoration: const InputDecoration(
                labelText: 'Matrícula (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const Text('Los cambios se aplican al pulsar Guardar.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(
                _saving ? 'Guardando…' : 'Guardar datos del vehículo',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
