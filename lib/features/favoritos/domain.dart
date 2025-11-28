// domain.dart
class Favorite {
  final String stationId;
  final DateTime createdAt;

  Favorite({required this.stationId, required this.createdAt});
}

abstract class IFavoriteRepository {
  Future<void> addFavorite(int stationId);
  Future<void> removeFavorite(int stationId);
  Future<List<int>> getFavorites();
}
