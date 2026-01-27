// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Gasolineras de Canarias';

  @override
  String get tabGasStations => 'Gasolineras';

  @override
  String get tabFavorites => 'Favoritos';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get sortByPrice => 'Ordenar por precio';

  @override
  String get sortByDistance => 'Ordenar por distancia';

  @override
  String get searchHint => 'Buscar por nombre, dirección o marca';

  @override
  String get noGasStationsFound => 'No se han encontrado gasolineras';

  @override
  String get tryRefreshOrChangeFilters =>
      'Prueba a actualizar o cambiar los filtros.';

  @override
  String get retry => 'Reintentar';

  @override
  String updatedMinutesAgo(int minutes) {
    return 'Actualizado hace $minutes min';
  }

  @override
  String updatedHoursAgo(int hours) {
    return 'Actualizado hace $hours h';
  }

  @override
  String updatedDaysAgo(int days) {
    return 'Actualizado hace $days días';
  }

  @override
  String updatedOn(String date) {
    return 'Actualizado el $date';
  }

  @override
  String get notUpdated => 'Sin actualizar';

  @override
  String get gasoline95 => 'Gasolina 95';

  @override
  String get gasoline98 => 'Gasolina 98';

  @override
  String get diesel => 'Diésel';

  @override
  String get dieselPremium => 'Diésel Premium';

  @override
  String get yourLocation => 'Tu ubicación';

  @override
  String get howToGetThere => 'Cómo llegar';

  @override
  String get selectMapApp => 'Selecciona una app de mapas';

  @override
  String get noMapAppsInstalled => 'No hay aplicaciones de mapas instaladas';

  @override
  String get address => 'Dirección:';

  @override
  String get brand => 'Marca:';

  @override
  String get myFavorites => 'Mis Favoritos';

  @override
  String get noFavorites => 'No tienes favoritos';

  @override
  String get addFavoritesFromMainList =>
      'Agrega gasolineras a favoritos desde la lista principal';

  @override
  String get favoriteStationsNotFound =>
      'No se encontraron las gasolineras favoritas';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirmation => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get activeMember => 'Miembro activo';

  @override
  String get accountInformation => 'Información de la cuenta';

  @override
  String get email => 'Email';

  @override
  String get userId => 'ID de usuario';

  @override
  String get memberSince => 'Miembro desde';

  @override
  String get profileNotAvailable => 'Perfil no disponible';

  @override
  String get loginToViewProfile =>
      'Inicia sesión para ver tu perfil y acceder a funciones adicionales';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginPrompt => 'Inicia sesión para continuar';

  @override
  String get password => 'Contraseña';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get register => 'Regístrate';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get registration => 'Registro';

  @override
  String get createAccountToSaveFavorites =>
      'Crea tu cuenta para guardar tus gasolineras favoritas';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get minimumCharacters => 'Mínimo 6 caracteres';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get registrationSuccess =>
      '✅ ¡Gracias por registrarte! Te hemos enviado un email para confirmar tu registro. Por favor, revisa tu bandeja de entrada.';

  @override
  String get invalidEmail => 'Correo electrónico no válido';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';
}
