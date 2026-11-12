import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/core/theme/theme_cubit.dart';
import 'package:gasolineras_can/features/auth/auth_bloc.dart';
import 'vehicle_profile_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:gasolineras_can/l10n/l10n.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.orange),
            const SizedBox(width: 12),
            Text(context.l10n.authCerrarSesion),
          ],
        ),
        content: Text(
          context.l10n.authCerrarSesionPregunta,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.authCancelar),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().logout();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.authCerrarSesion),
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
                        border: Border.all(color: Colors.white, width: 4),
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
                      user.email ?? context.l10n.authUsuarioDesconocido,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.authMiembroActivo,
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
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(context.l10n.authComoUsarGasoCan),
                    subtitle: Text(context.l10n.authConsultarGuia),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/guide'),
                  ),
                ),
                const SizedBox(height: 16),
                _buildThemeCard(context),
                const SizedBox(height: 16),
                _buildVehicleCard(context),
                const SizedBox(height: 16),

                // Tarjeta de información del usuario
                _buildInfoCard(
                  context,
                  title: context.l10n.authInformacionCuenta,
                  children: [
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: context.l10n.authEmail,
                      value: user.email ?? context.l10n.authNoDisponible,
                      color: colorScheme.primary,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.fingerprint,
                      label: context.l10n.authIdUsuario,
                      value: user.id.substring(0, 8),
                      color: colorScheme.secondary,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: context.l10n.authMiembroDesde,
                      value: DateFormat(
                        'dd/MM/yyyy',
                        context.l10n.localeName,
                      ).format(DateTime.parse(user.createdAt)),
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
                    label: Text(
                      context.l10n.authCerrarSesion,
                      style: const TextStyle(
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

                const SizedBox(height: 8),

                // Borrar la cuenta (obligatorio en App Store)
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _showDeleteAccountConfirmation(context),
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: Text(context.l10n.authEliminarCuenta),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    // Se guarda antes de los await: luego el context puede no estar montado.
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.authEliminarCuenta),
        content: Text(
          l10n.authEliminarCuentaAviso,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.authCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.authEliminar),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final authBloc = context.read<AuthBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await authBloc.deleteAccount();
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.authCuentaEliminada)));
    } on SignInWithAppleAuthorizationException catch (e) {
      // Canceló la confirmación de Apple: no se ha borrado nada.
      navigator.pop();
      if (e.code != AuthorizationErrorCode.canceled) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.authAppleNoConfirmo)),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al eliminar la cuenta: $e');
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.authErrorEliminarCuenta)),
      );
    }
  }

  Widget _buildVehicleCard(BuildContext context) => VehicleProfileCard(
    key: ValueKey(Supabase.instance.client.auth.currentUser?.id),
  );

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
              context.l10n.authPerfilNoDisponible,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.authPerfilIniciaSesion,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.go('/login');
              },
              icon: const Icon(Icons.login),
              label: Text(
                context.l10n.authIniciarSesion,
                style: const TextStyle(
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
            OutlinedButton.icon(
              onPressed: () => context.push('/guide'),
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(context.l10n.authComoUsarGasoCan),
            ),
            const SizedBox(height: 16),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.authApariencia,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              // Sin ✓ en la opción marcada y el texto en una línea (se reduce si
              // no cabe): en iPhone estrechos «Oscuro» se partía en dos.
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.l10n.authTemaAuto, maxLines: 1),
                  ),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.l10n.authTemaClaro, maxLines: 1),
                  ),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(context.l10n.authTemaOscuro, maxLines: 1),
                  ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          child: Icon(icon, color: color, size: 24),
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
