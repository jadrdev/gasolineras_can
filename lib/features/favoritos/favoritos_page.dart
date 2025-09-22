import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';

class FavoritesPage extends StatelessWidget {
  final FavoriteRepository repository;
  const FavoritesPage({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    // Usamos el stream si tu repo lo expone; si no, podrías usar FutureBuilder(getFavorites)
    return StreamBuilder<List<String>>(
      stream: repository.favoritesStream(),
      builder: (context, snapshot) {
        final favs = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (favs.isEmpty) {
          return const Center(child: Text("No tienes favoritos"));
        }
        return ListView.builder(
          itemCount: favs.length,
          itemBuilder: (context, index) {
            final stationId = favs[index];
            return ListTile(
              title: Text('Estación #$stationId'),
              subtitle: Text('Toca para ver detalle (implementar enlace)'),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  // Aquí podrías navegar al detalle: necesitarás resolver estación por id
                },
              ),
            );
          },
        );
      },
    );
  }
}
