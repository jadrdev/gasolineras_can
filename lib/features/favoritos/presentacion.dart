import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../gasolineras/models/gas_station.dart';

class FavoriteWidget extends StatelessWidget {
  final GasStation station;
  final FavoriteRepository repository;

  const FavoriteWidget({
    super.key,
    required this.station,
    required this.repository,
  });

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(child: Text('Inicia sesión')),
          ],
        ),
        content: const Text(
          'Necesitas iniciar sesión para guardar gasolineras en tus favoritos.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/login');
            },
            icon: const Icon(Icons.login),
            label: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;

    return StreamBuilder<List<int>>(
      stream: repository.favoritesStream(),
      builder: (context, snapshot) {
        final favorites = snapshot.data ?? [];
        final isFavorite = favorites.contains(station.id);

        return IconButton(
          icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          color: isFavorite ? Colors.amber : null,
          onPressed: () async {
            // Si no está logueado, mostrar diálogo
            if (!isLoggedIn) {
              _showLoginDialog(context);
              return;
            }

            // Si está logueado, proceder normalmente
            if (isFavorite) {
              await repository.removeFavorite(station.id);
            } else {
              await repository.addFavorite(station.id);
            }
          },
        );
      },
    );
  }
}
