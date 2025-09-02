// domain.dart
class Favorite {
  final String stationId;
  final DateTime createdAt;

  Favorite({required this.stationId, required this.createdAt});
}

abstract class IFavoriteRepository {
  Future<void> addFavorite(String stationId);
  Future<void> removeFavorite(String stationId);
  Future<List<String>> getFavorites();
}
