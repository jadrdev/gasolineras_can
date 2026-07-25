import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/core/theme/theme_cubit.dart';
import 'package:gasolineras_can/features/auth/auth_bloc.dart';
import 'package:gasolineras_can/features/auth/user_profile_repository.dart';
import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 12),
            Text('Cerrar sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Si no hay usuario logueado, mostrar pantalla de login
    if (user == null) {
      return _buildLoginPrompt(context, colorScheme);
    }

    // Si hay usuario logueado, mostrar perfil normal
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  children: [
                    // Avatar grande con borde
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.email?.substring(0, 1).toUpperCase() ?? '?',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Email del usuario
                    Text(
                      user.email ?? 'Usuario desconocido',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Miembro activo',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThemeCard(context),
                const SizedBox(height: 16),
                _buildVehicleCard(context),
                const SizedBox(height: 16),

                // Tarjeta de información del usuario
                _buildInfoCard(
                  context,
                  title: 'Información de la cuenta',
                  children: [
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email ?? 'No disponible',
                      color: colorScheme.primary,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.fingerprint,
                      label: 'ID de usuario',
                      value: user.id.substring(0, 8),
                      color: colorScheme.secondary,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Miembro desde',
                      value: DateFormat('dd/MM/yyyy').format(
                        DateTime.parse(user.createdAt),
                      ),
                      color: colorScheme.tertiary,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Botón de cerrar sesión
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showLogoutConfirmation(context),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<UserProfile?>(
      future: UserProfileRepository().getProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final fuel = profile?.preferredFuel ?? FuelType.g95;
        final liters = profile?.tankLiters ?? 50.0;
        final licensePlate = profile?.licensePlate ?? '';

        return StatefulBuilder(
          builder: (context, setInnerState) {
            final litersController = TextEditingController(
              text: liters.toStringAsFixed(0),
            );
            final plateController = TextEditingController(text: licensePlate);

            Future<void> saveVehicleData() async {
              final parsed = double.tryParse(
                litersController.text.replaceAll(',', '.'),
              );
              final plate = plateController.text.trim().toUpperCase();

              await UserProfileRepository().updatePreferences(
                preferredFuel: fuel,
                tankLiters: parsed != null && parsed > 0 ? parsed : liters,
                licensePlate: plate,
              );
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Mi vehículo',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Matrícula',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: plateController,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\-]'),
                        ),
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Ej: 1234ABC',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onTapOutside: (_) async => saveVehicleData(),
                      onSubmitted: (_) async => saveVehicleData(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La matrícula se guarda automáticamente al salir del campo o pulsar intro.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Combustible habitual',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PopupMenuButton<FuelType>(
                      initialValue: fuel,
                      onSelected: (selected) async {
                        await saveVehicleData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Combustible actualizado a ${selected.displayName}')),
                          );
                        }
                      },
                      itemBuilder: (context) => FuelType.values.map((fuelType) {
                        final isSelected = fuelType == fuel;
                        return PopupMenuItem(
                          value: fuelType,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: FuelColors.of(fuelType),
                                child: Text(
                                  fuelType.shortLabel,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(fuelType.displayName)),
                              if (isSelected)
                                const Icon(Icons.check, size: 18, color: Colors.blue),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: FuelColors.of(fuel),
                              child: Text(
                                fuel.shortLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(fuel.displayName),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: litersController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Litros del depósito',
                        prefixIcon: Icon(Icons.local_gas_station),
                        suffixText: 'L',
                        border: OutlineInputBorder(),
                      ),
                      onTapOutside: (_) async {
                        await saveVehicleData();
                      },
                      onSubmitted: (value) async {
                        await saveVehicleData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tamaño del depósito actualizado')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await saveVehicleData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Datos del vehículo guardados')),
                            );
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar datos del vehículo'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 100,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Perfil no disponible',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Inicia sesión para ver tu perfil y acceder a funciones adicionales',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.go('/login');
              },
              icon: const Icon(Icons.login),
              label: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildThemeCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apariencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('Auto'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Claro'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Oscuro'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) {
                context.read<ThemeCubit>().setThemeMode(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
