import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/features/auth/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 36,
            child: Text(user?.email?.substring(0, 1).toUpperCase() ?? '?'),
          ),
          const SizedBox(height: 12),
          Text(user?.email ?? 'Usuario desconocido'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.read<AuthBloc>().logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
