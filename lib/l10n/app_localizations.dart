import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// Title of the application
  ///
  /// In es, this message translates to:
  /// **'Gasolineras de Canarias'**
  String get appTitle;

  /// Tab label for gas stations list
  ///
  /// In es, this message translates to:
  /// **'Gasolineras'**
  String get tabGasStations;

  /// Tab label for favorites
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get tabFavorites;

  /// Tab label for profile
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get tabProfile;

  /// Menu option to sort by price
  ///
  /// In es, this message translates to:
  /// **'Ordenar por precio'**
  String get sortByPrice;

  /// Menu option to sort by distance
  ///
  /// In es, this message translates to:
  /// **'Ordenar por distancia'**
  String get sortByDistance;

  /// Hint text for search field
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre, dirección o marca'**
  String get searchHint;

  /// Message when no gas stations are found
  ///
  /// In es, this message translates to:
  /// **'No se han encontrado gasolineras'**
  String get noGasStationsFound;

  /// Suggestion when no results found
  ///
  /// In es, this message translates to:
  /// **'Prueba a actualizar o cambiar los filtros.'**
  String get tryRefreshOrChangeFilters;

  /// Button to retry an action
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Last update time in minutes
  ///
  /// In es, this message translates to:
  /// **'Actualizado hace {minutes} min'**
  String updatedMinutesAgo(int minutes);

  /// Last update time in hours
  ///
  /// In es, this message translates to:
  /// **'Actualizado hace {hours} h'**
  String updatedHoursAgo(int hours);

  /// Last update time in days
  ///
  /// In es, this message translates to:
  /// **'Actualizado hace {days} días'**
  String updatedDaysAgo(int days);

  /// Last update date
  ///
  /// In es, this message translates to:
  /// **'Actualizado el {date}'**
  String updatedOn(String date);

  /// When there's no update information
  ///
  /// In es, this message translates to:
  /// **'Sin actualizar'**
  String get notUpdated;

  /// Gasoline 95 fuel type
  ///
  /// In es, this message translates to:
  /// **'Gasolina 95'**
  String get gasoline95;

  /// Gasoline 98 fuel type
  ///
  /// In es, this message translates to:
  /// **'Gasolina 98'**
  String get gasoline98;

  /// Diesel fuel type
  ///
  /// In es, this message translates to:
  /// **'Diésel'**
  String get diesel;

  /// Premium diesel fuel type
  ///
  /// In es, this message translates to:
  /// **'Diésel Premium'**
  String get dieselPremium;

  /// Label for user's current location
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación'**
  String get yourLocation;

  /// Button to get directions
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get howToGetThere;

  /// Title for map app selector
  ///
  /// In es, this message translates to:
  /// **'Selecciona una app de mapas'**
  String get selectMapApp;

  /// Message when no map apps are available
  ///
  /// In es, this message translates to:
  /// **'No hay aplicaciones de mapas instaladas'**
  String get noMapAppsInstalled;

  /// Address label
  ///
  /// In es, this message translates to:
  /// **'Dirección:'**
  String get address;

  /// Brand label
  ///
  /// In es, this message translates to:
  /// **'Marca:'**
  String get brand;

  /// Title for favorites page
  ///
  /// In es, this message translates to:
  /// **'Mis Favoritos'**
  String get myFavorites;

  /// Message when user has no favorites
  ///
  /// In es, this message translates to:
  /// **'No tienes favoritos'**
  String get noFavorites;

  /// Instruction to add favorites
  ///
  /// In es, this message translates to:
  /// **'Agrega gasolineras a favoritos desde la lista principal'**
  String get addFavoritesFromMainList;

  /// Message when favorite stations can't be found
  ///
  /// In es, this message translates to:
  /// **'No se encontraron las gasolineras favoritas'**
  String get favoriteStationsNotFound;

  /// Logout button text
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas cerrar sesión?'**
  String get logoutConfirmation;

  /// Cancel button text
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Active member status
  ///
  /// In es, this message translates to:
  /// **'Miembro activo'**
  String get activeMember;

  /// Account information section title
  ///
  /// In es, this message translates to:
  /// **'Información de la cuenta'**
  String get accountInformation;

  /// Email label
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get email;

  /// User ID label
  ///
  /// In es, this message translates to:
  /// **'ID de usuario'**
  String get userId;

  /// Member since label
  ///
  /// In es, this message translates to:
  /// **'Miembro desde'**
  String get memberSince;

  /// Profile not available title
  ///
  /// In es, this message translates to:
  /// **'Perfil no disponible'**
  String get profileNotAvailable;

  /// Message prompting user to login
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para ver tu perfil y acceder a funciones adicionales'**
  String get loginToViewProfile;

  /// Login button text
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// Login prompt message
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para continuar'**
  String get loginPrompt;

  /// Password field label
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// Prompt for users without account
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get noAccount;

  /// Register button text
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get register;

  /// Create account title
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// Registration title
  ///
  /// In es, this message translates to:
  /// **'Registro'**
  String get registration;

  /// Registration subtitle
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta para guardar tus gasolineras favoritas'**
  String get createAccountToSaveFavorites;

  /// Email address field label
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailAddress;

  /// Password minimum length hint
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get minimumCharacters;

  /// Password too short error
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get passwordTooShort;

  /// Confirm password field label
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// Passwords don't match error
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDoNotMatch;

  /// Prompt for users with existing account
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get alreadyHaveAccount;

  /// Registration success message
  ///
  /// In es, this message translates to:
  /// **'✅ ¡Gracias por registrarte! Te hemos enviado un email para confirmar tu registro. Por favor, revisa tu bandeja de entrada.'**
  String get registrationSuccess;

  /// Invalid email error
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico no válido'**
  String get invalidEmail;

  /// Settings section title
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// Language setting label
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Select language dialog title
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get selectLanguage;

  /// Spanish language option
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// English language option
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// German language option
  ///
  /// In es, this message translates to:
  /// **'Deutsch'**
  String get german;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
