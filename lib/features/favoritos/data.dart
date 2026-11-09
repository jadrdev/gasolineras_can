import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'domain.dart';

class FavoriteRepository implements IFavoriteRepository {
  final SupabaseClient supabase;
  FavoriteRepository({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  bool get isLoggedIn => supabase.auth.currentUser != null;

  /// Último valor conocido de favoritos del usuario actual (compartido entre
  /// todas las instancias del repositorio).
  List<int> get cachedFavorites {
    final userId = supabase.auth.currentUser?.id;
    return (userId == null ? null : _FavoritesFeed._feeds[userId]?.latest) ??
        const [];
  }

  // Stream de favoritos en tiempo real
  @override
  Stream<List<int>> favoritesStream() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('⚠️ favoritesStream: No hay usuario autenticado');
      return Stream.value([]);
    }
    return _FavoritesFeed.of(this, userId).stream;
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
      if (!e.toString().contains('23505')) rethrow;
      debugPrint('ℹ️ El favorito ya existe, ignorando error');
    }
    _FavoritesFeed._feeds[userId]?.apply(add: stationId);
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
      rethrow;
    }
    _FavoritesFeed._feeds[userId]?.apply(remove: stationId);
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

/// Una única suscripción realtime por usuario, compartida por toda la app.
///
/// Un `SupabaseStreamBuilder` no admite varios `listen`: cada uno vuelve a
/// unirse al mismo topic realtime y el servidor cierra la unión anterior, así
/// que con varias estrellas en pantalla algunas se quedaban sin datos. Además
/// el canal puede caer (red, app en segundo plano) sin recuperarse. Este feed
/// multiplexa un solo canal, reintenta con backoff y siembra el valor inicial
/// por REST para no depender solo del WebSocket.
class _FavoritesFeed {
  static final Map<String, _FavoritesFeed> _feeds = {};

  static _FavoritesFeed of(FavoriteRepository repo, String userId) {
    // Al cambiar de usuario, descartamos los feeds de otros usuarios.
    _feeds.removeWhere((id, feed) {
      if (id == userId) return false;
      feed._disconnect();
      return true;
    });
    return _feeds.putIfAbsent(userId, () => _FavoritesFeed._(repo, userId));
  }

  _FavoritesFeed._(this._repo, this._userId);

  final FavoriteRepository _repo;
  final String _userId;
  List<int>? latest;

  late final StreamController<List<int>> _controller =
      StreamController<List<int>>.broadcast(
        onListen: _onListen,
        onCancel: _onCancel,
      );
  StreamSubscription<List<Map<String, dynamic>>>? _realtime;
  Timer? _retryTimer;
  Timer? _idleTimer;
  int _attempt = 0;

  /// Cada suscriptor recibe primero el último valor conocido.
  Stream<List<int>> get stream => Stream.multi((listener) {
    final current = latest;
    if (current != null) listener.add(current);
    final sub = _controller.stream.listen(
      listener.addSync,
      onError: listener.addErrorSync,
    );
    listener.onCancel = sub.cancel;
  });

  void apply({int? add, int? remove}) {
    final ids = [...?latest];
    if (add != null && !ids.contains(add)) ids.add(add);
    if (remove != null) ids.remove(remove);
    _emit(ids);
  }

  void _emit(List<int> ids) {
    if (_feeds[_userId] != this) return;
    latest = ids;
    _controller.add(ids);
  }

  void _onListen() {
    _idleTimer?.cancel();
    if (_realtime == null && _retryTimer == null) _connect();
  }

  void _onCancel() {
    // Las estrellas entran y salen al hacer scroll; no cerramos el canal
    // inmediatamente para no reconectar continuamente.
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 10), () {
      if (!_controller.hasListener) _disconnect();
    });
  }

  void _connect() {
    _retryTimer = null;
    debugPrint('🔄 favoritesStream: Iniciando stream para user $_userId');
    _refreshFromRest();
    _realtime = _repo.supabase
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .listen(
          (rows) {
            _attempt = 0;
            final ids = rows.map((r) => r['station_id'] as int).toList();
            debugPrint('⭐ favoritesStream: Favoritos actuales: $ids');
            _emit(ids);
          },
          onError: (Object e) {
            debugPrint('❌ favoritesStream: error realtime: $e');
            _scheduleRetry();
          },
          onDone: _scheduleRetry,
        );
  }

  Future<void> _refreshFromRest() async {
    try {
      final ids = await _repo.getFavorites();
      if (_repo.supabase.auth.currentUser?.id == _userId) _emit(ids);
    } catch (e) {
      debugPrint('❌ favoritesStream: error cargando favoritos: $e');
    }
  }

  void _scheduleRetry() {
    _realtime?.cancel();
    _realtime = null;
    if (!_controller.hasListener || _retryTimer != null) return;
    final delay = Duration(seconds: min(30, 1 << min(_attempt++, 5)));
    debugPrint('🔁 favoritesStream: reintentando en ${delay.inSeconds}s');
    _retryTimer = Timer(delay, _connect);
  }

  void _disconnect() {
    _idleTimer?.cancel();
    _retryTimer?.cancel();
    _retryTimer = null;
    _realtime?.cancel();
    _realtime = null;
  }
}
