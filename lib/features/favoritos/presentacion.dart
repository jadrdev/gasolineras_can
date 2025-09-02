import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import '../gasolineras/models/gas_station.dart';

class FavoriteWidget extends StatelessWidget {
  final GasStation station;
  final FavoriteRepository repository;

  const FavoriteWidget({
    super.key,
    required this.station,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: repository.favoritesStream(), // ← usa el stream de favoritos
      builder: (context, snapshot) {
        final favorites = snapshot.data ?? [];
        final isFavorite = favorites.contains(station.id.toString());

        return IconButton(
          icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          color: Colors.amber,
          onPressed: () async {
            if (isFavorite) {
              await repository.removeFavorite(station.id.toString());
            } else {
              await repository.addFavorite(station.id.toString());
            }
            // No necesitamos setState, el StreamBuilder se actualizará automáticamente
          },
        );
      },
    );
  }
}
