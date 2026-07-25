import 'package:gasolineras_can/features/gasolineras/fuel_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final FuelType preferredFuel;
  final double tankLiters;
  final String? licensePlate;

  const UserProfile({
    required this.id,
    required this.email,
    this.preferredFuel = FuelType.g95,
    this.tankLiters = 50,
    this.licensePlate,
  });
}

/// Repositorio para leer y escribir preferencias del usuario en Supabase.
/// Tabla: `users` con columnas `id`, `email`, `preferred_fuel`, `tank_liters`,
/// `license_plate`.
class UserProfileRepository {
  final SupabaseClient _client;

  UserProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  User? get _currentUser => currentUser;

  /// Obtiene el perfil del usuario autenticado, o `null` si no hay sesión.
  Future<UserProfile?> getProfile() async {
    final user = _currentUser;
    if (user == null) return null;

    final response = await _client
        .from('users')
        .select('id, email, preferred_fuel, tank_liters, license_plate')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return UserProfile(
      id: response['id'] as String,
      email: response['email'] as String? ?? user.email ?? '',
      preferredFuel: _parseFuel(response['preferred_fuel']),
      tankLiters: (response['tank_liters'] as num?)?.toDouble() ?? 50,
      licensePlate: response['license_plate'] as String?,
    );
  }

  /// Actualiza las preferencias del usuario autenticado.
  Future<void> updatePreferences({
    required FuelType preferredFuel,
    required double tankLiters,
    String? licensePlate,
  }) async {
    final user = _currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final values = <String, dynamic>{
      'preferred_fuel': preferredFuel.name,
      'tank_liters': tankLiters,
    };

    if (licensePlate != null) {
      values['license_plate'] = licensePlate.isEmpty ? null : licensePlate;
    }

    await _client.from('users').update(values).eq('id', user.id);
  }

  /// Actualiza únicamente la matrícula del usuario autenticado.
  Future<void> updateLicensePlate(String? licensePlate) async {
    final user = _currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    await _client.from('users').update({
      'license_plate': licensePlate?.isEmpty ?? true ? null : licensePlate,
    }).eq('id', user.id);
  }

  static FuelType _parseFuel(dynamic value) {
    final name = value as String?;
    return FuelType.values.firstWhere(
      (f) => f.name == name,
      orElse: () => FuelType.g95,
    );
  }
}
