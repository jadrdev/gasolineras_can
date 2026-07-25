import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../gasolineras/models/gas_station.dart';

class FavoriteWidget extends StatefulWidget {
  final GasStation station;
  final FavoriteRepository repository;

  const FavoriteWidget({
    super.key,
    required this.station,
    required this.repository,
  });

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  // El estado real vive en Supabase y se refleja vía favoritesStream(), pero
  // esa suscripción realtime tarda en confirmar el cambio (hay un viaje de
  // ida y vuelta de WebSocket por detrás del INSERT/DELETE ya confirmado).
  // Este override optimista pinta la estrella al instante y se descarta en
  // cuanto el stream confirma el mismo valor.
  bool? _optimisticFavorite;

  Future<void> _toggleFavorite(bool currentlyFavorite) async {
    setState(() => _optimisticFavorite = !currentlyFavorite);
    try {
      if (currentlyFavorite) {
        await widget.repository.removeFavorite(widget.station.id);
      } else {
        await widget.repository.addFavorite(widget.station.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _optimisticFavorite = currentlyFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el favorito')),
      );
    }
  }

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

    // Cargar favoritos inicialmente desde caché local para renderizado rápido
    return FutureBuilder<List<int>>(
      future: widget.repository.getFavorites(),
      builder: (context, futureSnapshot) {
        // Usar StreamBuilder con datos iniciales del Future
        return StreamBuilder<List<int>>(
          stream: widget.repository.favoritesStream(),
          initialData: futureSnapshot.data, // 👈 Datos iniciales para renderizado inmediato
          builder: (context, snapshot) {
            final favorites = snapshot.data ?? [];
            final serverFavorite = favorites.contains(widget.station.id);
            final isFavorite = _optimisticFavorite ?? serverFavorite;

            // El stream ya confirmó el valor optimista: dejamos de forzarlo
            // para que vuelva a seguir al servidor (p. ej. si se cambia
            // desde otro dispositivo).
            if (_optimisticFavorite != null && _optimisticFavorite == serverFavorite) {
              _optimisticFavorite = null;
            }

            return IconButton(
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              color: isFavorite ? Colors.amber : null,
              onPressed: () {
                // Si no está logueado, mostrar diálogo
                if (!isLoggedIn) {
                  _showLoginDialog(context);
                  return;
                }

                _toggleFavorite(isFavorite);
              },
            );
          },
        );
      },
    );
  }
}
