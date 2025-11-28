import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'domain.dart';

class FavoriteRepository implements IFavoriteRepository {
  final supabase = Supabase.instance.client;

  // Stream de favoritos en tiempo real
  @override
  Stream<List<int>> favoritesStream() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('⚠️ favoritesStream: No hay usuario autenticado');
      return Stream.value([]);
    }

    debugPrint('🔄 favoritesStream: Iniciando stream para user $userId');
    
    // Supabase streaming de tabla con sintaxis correcta
    return supabase
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) {
          final ids = rows.map((r) => r['station_id'] as int).toList();
          debugPrint('⭐ favoritesStream: Favoritos actuales: $ids');
          return ids;
        });
  }

  @override
  Future<void> addFavorite(int stationId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    debugPrint('➕ Agregando favorito: station_id=$stationId, user_id=$userId');
    
    try {
      await supabase.from('favorites').insert({
        'user_id': userId,
        'station_id': stationId,
      });
      debugPrint('✅ Favorito agregado exitosamente');
    } catch (e) {
      debugPrint('❌ Error al agregar favorito: $e');
      // Ignorar error de duplicado (23505) - el favorito ya existe
      if (e.toString().contains('23505')) {
        debugPrint('ℹ️ El favorito ya existe, ignorando error');
        return; // Ya está en favoritos, no hacer nada
      }
      rethrow; // Re-lanzar otros errores
    }
  }

  @override
  Future<void> removeFavorite(int stationId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    debugPrint('➖ Eliminando favorito: station_id=$stationId, user_id=$userId');
    
    try {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('station_id', stationId);
      debugPrint('✅ Favorito eliminado exitosamente');
    } catch (e) {
      debugPrint('❌ Error al eliminar favorito: $e');
      // Ignorar errores al eliminar - puede que ya no exista
      return;
    }
  }

  @override
  Future<List<int>> getFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await supabase
        .from('favorites')
        .select('station_id')
        .eq('user_id', userId);

    return (res as List).map((r) => r['station_id'] as int).toList();
  }
}
