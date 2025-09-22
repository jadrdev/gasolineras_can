import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/features/auth/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
          Text(user?.email ?? 'Usuario anónimo'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Usamos AuthBloc para cerrar sesión
              final authBloc = context.read<AuthBloc>();
              authBloc.logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
