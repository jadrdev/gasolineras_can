import 'package:supabase_flutter/supabase_flutter.dart';
import 'domain.dart';

class FavoriteRepository implements IFavoriteRepository {
  final supabase = Supabase.instance.client;

  // Stream de favoritos en tiempo real
  @override
  Stream<List<String>> favoritesStream() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    // Supabase streaming de tabla
    return supabase
        .from('favorites:user_id=eq.$userId')
        .stream(primaryKey: ['id'])
        .map((rows) => rows.map((r) => r['station_id'] as String).toList());
  }

  @override
  Future<void> addFavorite(String stationId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('favorites').insert({
      'user_id': userId,
      'station_id': stationId,
    });
  }

  @override
  Future<void> removeFavorite(String stationId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('station_id', stationId);
  }

  @override
  Future<List<String>> getFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await supabase
        .from('favorites')
        .select('station_id')
        .eq('user_id', userId);

    return (res as List).map((r) => r['station_id'] as String).toList();
  }
}
