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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Gasolineras de Canarias'**
  String get appTitle;

  /// No description provided for @authRegistroExitoso.
  ///
  /// In es, this message translates to:
  /// **'✅ ¡Registro exitoso! Si la confirmación por email está habilitada, revisa tu bandeja de entrada. En caso contrario, ya puedes iniciar sesión.'**
  String get authRegistroExitoso;

  /// No description provided for @authCrearCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCrearCuenta;

  /// No description provided for @authGasolinerasDeCanarias.
  ///
  /// In es, this message translates to:
  /// **'Gasolineras de Canarias'**
  String get authGasolinerasDeCanarias;

  /// No description provided for @authUneteYAhorra.
  ///
  /// In es, this message translates to:
  /// **'Únete y ahorra'**
  String get authUneteYAhorra;

  /// No description provided for @authRegistroSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Guarda tus gasolineras favoritas y recibe alertas de precios.'**
  String get authRegistroSubtitulo;

  /// No description provided for @authCorreoElectronico.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authCorreoElectronico;

  /// No description provided for @authCorreoObligatorio.
  ///
  /// In es, this message translates to:
  /// **'El correo es obligatorio'**
  String get authCorreoObligatorio;

  /// No description provided for @authCorreoNoValido.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico no válido'**
  String get authCorreoNoValido;

  /// No description provided for @authContrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authContrasena;

  /// No description provided for @authMinimoCaracteres.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get authMinimoCaracteres;

  /// No description provided for @authContrasenaObligatoria.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria'**
  String get authContrasenaObligatoria;

  /// No description provided for @authContrasenaCorta.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get authContrasenaCorta;

  /// No description provided for @authConfirmarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmarContrasena;

  /// No description provided for @authContrasenasNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authContrasenasNoCoinciden;

  /// No description provided for @authYaTienesCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get authYaTienesCuenta;

  /// No description provided for @authIniciaSesion.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get authIniciaSesion;

  /// No description provided for @authVolverAlInicio.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get authVolverAlInicio;

  /// No description provided for @authBienvenido.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get authBienvenido;

  /// No description provided for @authLoginSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Accede a tus favoritos y preferencias de vehículo.'**
  String get authLoginSubtitulo;

  /// No description provided for @authOlvidasteContrasena.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authOlvidasteContrasena;

  /// No description provided for @authIniciarSesion.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authIniciarSesion;

  /// No description provided for @authNoTienesCuenta.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get authNoTienesCuenta;

  /// No description provided for @authRegistrate.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get authRegistrate;

  /// No description provided for @authO.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get authO;

  /// No description provided for @authIniciarSesionApple.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión con Apple'**
  String get authIniciarSesionApple;

  /// No description provided for @authCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get authCerrarSesion;

  /// No description provided for @authCerrarSesionPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas cerrar sesión?'**
  String get authCerrarSesionPregunta;

  /// No description provided for @authCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get authCancelar;

  /// No description provided for @authUsuarioDesconocido.
  ///
  /// In es, this message translates to:
  /// **'Usuario desconocido'**
  String get authUsuarioDesconocido;

  /// No description provided for @authMiembroActivo.
  ///
  /// In es, this message translates to:
  /// **'Miembro activo'**
  String get authMiembroActivo;

  /// No description provided for @authComoUsarGasoCan.
  ///
  /// In es, this message translates to:
  /// **'Cómo usar GasoCan'**
  String get authComoUsarGasoCan;

  /// No description provided for @authConsultarGuia.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a consultar la guía'**
  String get authConsultarGuia;

  /// No description provided for @authInformacionCuenta.
  ///
  /// In es, this message translates to:
  /// **'Información de la cuenta'**
  String get authInformacionCuenta;

  /// No description provided for @authEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get authNoDisponible;

  /// No description provided for @authIdUsuario.
  ///
  /// In es, this message translates to:
  /// **'ID de usuario'**
  String get authIdUsuario;

  /// No description provided for @authMiembroDesde.
  ///
  /// In es, this message translates to:
  /// **'Miembro desde'**
  String get authMiembroDesde;

  /// No description provided for @authEliminarCuenta.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get authEliminarCuenta;

  /// No description provided for @authEliminarCuentaAviso.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán tu cuenta, tus gasolineras favoritas, tus alertas de precio y los datos de tu vehículo. No se puede deshacer.'**
  String get authEliminarCuentaAviso;

  /// No description provided for @authEliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get authEliminar;

  /// No description provided for @authCuentaEliminada.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta se ha eliminado'**
  String get authCuentaEliminada;

  /// No description provided for @authAppleNoConfirmo.
  ///
  /// In es, this message translates to:
  /// **'Apple no pudo confirmar tu identidad. La cuenta sigue activa.'**
  String get authAppleNoConfirmo;

  /// No description provided for @authErrorEliminarCuenta.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta. Inténtalo de nuevo más tarde.'**
  String get authErrorEliminarCuenta;

  /// No description provided for @authPerfilNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Perfil no disponible'**
  String get authPerfilNoDisponible;

  /// No description provided for @authPerfilIniciaSesion.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para ver tu perfil y acceder a funciones adicionales'**
  String get authPerfilIniciaSesion;

  /// No description provided for @authApariencia.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get authApariencia;

  /// No description provided for @authTemaAuto.
  ///
  /// In es, this message translates to:
  /// **'Auto'**
  String get authTemaAuto;

  /// No description provided for @authTemaClaro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get authTemaClaro;

  /// No description provided for @authTemaOscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get authTemaOscuro;

  /// No description provided for @authErrorCargarVehiculo.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los datos del vehículo.'**
  String get authErrorCargarVehiculo;

  /// No description provided for @authReintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get authReintentar;

  /// No description provided for @authVehiculoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Datos del vehículo guardados'**
  String get authVehiculoGuardado;

  /// No description provided for @authErrorGuardarVehiculo.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los datos. Puedes volver a intentarlo.'**
  String get authErrorGuardarVehiculo;

  /// No description provided for @authMiVehiculo.
  ///
  /// In es, this message translates to:
  /// **'Mi vehículo'**
  String get authMiVehiculo;

  /// No description provided for @authCombustibleHabitual.
  ///
  /// In es, this message translates to:
  /// **'Combustible habitual'**
  String get authCombustibleHabitual;

  /// No description provided for @authLitrosDeposito.
  ///
  /// In es, this message translates to:
  /// **'Litros del depósito'**
  String get authLitrosDeposito;

  /// No description provided for @authLitrosNoValidos.
  ///
  /// In es, this message translates to:
  /// **'Introduce una capacidad entre 0 y 1000 litros, mayor que cero.'**
  String get authLitrosNoValidos;

  /// No description provided for @authMatriculaOpcional.
  ///
  /// In es, this message translates to:
  /// **'Matrícula (opcional)'**
  String get authMatriculaOpcional;

  /// No description provided for @authCambiosAlGuardar.
  ///
  /// In es, this message translates to:
  /// **'Los cambios se aplican al pulsar Guardar.'**
  String get authCambiosAlGuardar;

  /// No description provided for @authGuardando.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get authGuardando;

  /// No description provided for @authGuardarVehiculo.
  ///
  /// In es, this message translates to:
  /// **'Guardar datos del vehículo'**
  String get authGuardarVehiculo;

  /// No description provided for @authErrorInesperadoLogin.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado al iniciar sesión'**
  String get authErrorInesperadoLogin;

  /// No description provided for @authAppleSinIdentidad.
  ///
  /// In es, this message translates to:
  /// **'Apple no devolvió la identidad'**
  String get authAppleSinIdentidad;

  /// No description provided for @authErrorApple.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar sesión con Apple'**
  String get authErrorApple;

  /// No description provided for @authErrorAppleDetalle.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar sesión con Apple: {detalle}'**
  String authErrorAppleDetalle(String detalle);

  /// No description provided for @authErrorEmailConfirmacion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el email de confirmación. Vuelve a intentarlo más tarde.'**
  String get authErrorEmailConfirmacion;

  /// No description provided for @authErrorDetalle.
  ///
  /// In es, this message translates to:
  /// **'Error: {detalle}'**
  String authErrorDetalle(String detalle);

  /// No description provided for @authErrorInesperado.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado: {detalle}'**
  String authErrorInesperado(String detalle);

  /// No description provided for @fuelGasoline95.
  ///
  /// In es, this message translates to:
  /// **'Gasolina 95'**
  String get fuelGasoline95;

  /// No description provided for @fuelGasoline98.
  ///
  /// In es, this message translates to:
  /// **'Gasolina 98'**
  String get fuelGasoline98;

  /// No description provided for @fuelDiesel.
  ///
  /// In es, this message translates to:
  /// **'Diésel'**
  String get fuelDiesel;

  /// No description provided for @fuelDieselPremium.
  ///
  /// In es, this message translates to:
  /// **'Diésel Premium'**
  String get fuelDieselPremium;

  /// No description provided for @stationWelcome.
  ///
  /// In es, this message translates to:
  /// **'🏝 Bienvenido a Gasolineras Canarias'**
  String get stationWelcome;

  /// No description provided for @stationListTitle.
  ///
  /// In es, this message translates to:
  /// **'Gasolineras'**
  String get stationListTitle;

  /// No description provided for @stationUseMyLocation.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación'**
  String get stationUseMyLocation;

  /// No description provided for @stationRefreshPrices.
  ///
  /// In es, this message translates to:
  /// **'Actualizar precios'**
  String get stationRefreshPrices;

  /// No description provided for @stationZoneAll.
  ///
  /// In es, this message translates to:
  /// **'Toda Canarias'**
  String get stationZoneAll;

  /// No description provided for @stationZoneNearby.
  ///
  /// In es, this message translates to:
  /// **'Cerca de mí · 16 km'**
  String get stationZoneNearby;

  /// No description provided for @stationFuelTooltip.
  ///
  /// In es, this message translates to:
  /// **'Combustible: {fuel}'**
  String stationFuelTooltip(String fuel);

  /// No description provided for @stationSortTooltip.
  ///
  /// In es, this message translates to:
  /// **'Ordenar resultados'**
  String get stationSortTooltip;

  /// No description provided for @stationSortByPrice.
  ///
  /// In es, this message translates to:
  /// **'Por precio'**
  String get stationSortByPrice;

  /// No description provided for @stationSortByDistance.
  ///
  /// In es, this message translates to:
  /// **'Por distancia en línea recta'**
  String get stationSortByDistance;

  /// No description provided for @stationTextSearchAllIslands.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda por texto en toda Canarias'**
  String get stationTextSearchAllIslands;

  /// No description provided for @stationOfflineNotice.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron actualizar los precios. Mostrando datos guardados del {date}.'**
  String stationOfflineNotice(String date);

  /// No description provided for @stationCountByPrice.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 gasolinera · por precio} other{{count} gasolineras · por precio}}'**
  String stationCountByPrice(int count);

  /// No description provided for @stationCountByDistance.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 gasolinera · por distancia} other{{count} gasolineras · por distancia}}'**
  String stationCountByDistance(int count);

  /// No description provided for @stationViewList.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get stationViewList;

  /// No description provided for @stationViewMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get stationViewMap;

  /// No description provided for @stationNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se han encontrado gasolineras'**
  String get stationNoResults;

  /// No description provided for @stationNoResultsHint.
  ///
  /// In es, this message translates to:
  /// **'Prueba con parte del nombre, otra marca o un municipio.'**
  String get stationNoResultsHint;

  /// No description provided for @stationClearSearchAll.
  ///
  /// In es, this message translates to:
  /// **'Borrar búsqueda y ver toda Canarias'**
  String get stationClearSearchAll;

  /// No description provided for @stationRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get stationRetry;

  /// No description provided for @stationUnknownDate.
  ///
  /// In es, this message translates to:
  /// **'fecha desconocida'**
  String get stationUnknownDate;

  /// No description provided for @stationStraightLineKm.
  ///
  /// In es, this message translates to:
  /// **'{km} km en línea recta'**
  String stationStraightLineKm(String km);

  /// No description provided for @stationUpdatedAt.
  ///
  /// In es, this message translates to:
  /// **'Actualizado · {date}'**
  String stationUpdatedAt(String date);

  /// No description provided for @stationStalePriceAt.
  ///
  /// In es, this message translates to:
  /// **'Precio sin actualización reciente · {date}'**
  String stationStalePriceAt(String date);

  /// No description provided for @stationLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las gasolineras. Comprueba la conexión y vuelve a intentarlo.'**
  String get stationLoadError;

  /// No description provided for @stationSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Marca, dirección o municipio'**
  String get stationSearchHint;

  /// No description provided for @stationClearSearch.
  ///
  /// In es, this message translates to:
  /// **'Borrar búsqueda'**
  String get stationClearSearch;

  /// No description provided for @stationNoPrice.
  ///
  /// In es, this message translates to:
  /// **'Sin precio disponible'**
  String get stationNoPrice;

  /// No description provided for @stationPricePerLitreSemantics.
  ///
  /// In es, this message translates to:
  /// **'{fuel}: {price} euros por litro'**
  String stationPricePerLitreSemantics(String fuel, String price);

  /// No description provided for @stationTankEstimate.
  ///
  /// In es, this message translates to:
  /// **'{total} € para {liters} L · estimado'**
  String stationTankEstimate(String total, String liters);

  /// No description provided for @stationFuelPrice.
  ///
  /// In es, this message translates to:
  /// **'{fuel}: {price} €/L'**
  String stationFuelPrice(String fuel, String price);

  /// No description provided for @stationFuelNoPrice.
  ///
  /// In es, this message translates to:
  /// **'{fuel}: sin precio'**
  String stationFuelNoPrice(String fuel);

  /// No description provided for @stationViewDetail.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get stationViewDetail;

  /// No description provided for @stationDirections.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get stationDirections;

  /// No description provided for @stationChooseMapApp.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una app de mapas'**
  String get stationChooseMapApp;

  /// No description provided for @stationNoMapsInstalled.
  ///
  /// In es, this message translates to:
  /// **'No hay aplicaciones de mapas instaladas'**
  String get stationNoMapsInstalled;

  /// No description provided for @stationMapOpenError.
  ///
  /// In es, this message translates to:
  /// **'Error al abrir el mapa: {error}'**
  String stationMapOpenError(String error);

  /// No description provided for @stationMapTitle.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Mapa · 1 gasolinera} other{Mapa · {count} gasolineras}}'**
  String stationMapTitle(int count);

  /// No description provided for @stationNoStationsToShow.
  ///
  /// In es, this message translates to:
  /// **'No hay gasolineras para mostrar.'**
  String get stationNoStationsToShow;

  /// No description provided for @stationMapLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el mapa. Vuelve a la lista e inténtalo de nuevo.'**
  String get stationMapLoadError;

  /// No description provided for @stationShowAllResults.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los resultados'**
  String get stationShowAllResults;

  /// No description provided for @stationSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get stationSettings;

  /// No description provided for @stationCalculateRefuel.
  ///
  /// In es, this message translates to:
  /// **'Calcula tu repostaje'**
  String get stationCalculateRefuel;

  /// No description provided for @stationLitresToEuros.
  ///
  /// In es, this message translates to:
  /// **'Litros a €'**
  String get stationLitresToEuros;

  /// No description provided for @stationEurosToLitres.
  ///
  /// In es, this message translates to:
  /// **'€ a litros'**
  String get stationEurosToLitres;

  /// No description provided for @stationMoneyAvailable.
  ///
  /// In es, this message translates to:
  /// **'Dinero disponible'**
  String get stationMoneyAvailable;

  /// No description provided for @stationNoPriceFor.
  ///
  /// In es, this message translates to:
  /// **'No hay precio para {fuel}'**
  String stationNoPriceFor(String fuel);

  /// No description provided for @stationPriceFor.
  ///
  /// In es, this message translates to:
  /// **'Precio {fuel}: {price} €/L'**
  String stationPriceFor(String fuel, String price);

  /// No description provided for @stationTankLitres.
  ///
  /// In es, this message translates to:
  /// **'Litros del depósito'**
  String get stationTankLitres;

  /// No description provided for @stationEnterLitresHint.
  ///
  /// In es, this message translates to:
  /// **'Introduce los litros de tu depósito para ver el ahorro estimado.'**
  String get stationEnterLitresHint;

  /// No description provided for @stationFillCost.
  ///
  /// In es, this message translates to:
  /// **'Llenar {liters} L te costaría:'**
  String stationFillCost(String liters);

  /// No description provided for @stationCheckingNearby.
  ///
  /// In es, this message translates to:
  /// **'Consultando precios cercanos…'**
  String get stationCheckingNearby;

  /// No description provided for @stationEstimateNote.
  ///
  /// In es, this message translates to:
  /// **'Estimación del combustible; no incluye desplazamiento.'**
  String get stationEstimateNote;

  /// No description provided for @stationYouSave.
  ///
  /// In es, this message translates to:
  /// **'Ahorras {amount} €'**
  String stationYouSave(String amount);

  /// No description provided for @stationSavingsVsMax.
  ///
  /// In es, this message translates to:
  /// **'Frente al mayor precio a 16 km de tu ubicación ({price} €/L). No incluye desplazamiento.'**
  String stationSavingsVsMax(String price);

  /// No description provided for @stationEnterMoneyHint.
  ///
  /// In es, this message translates to:
  /// **'Introduce la cantidad de dinero para ver cuántos litros obtienes.'**
  String get stationEnterMoneyHint;

  /// No description provided for @stationWithMoneyYouGet.
  ///
  /// In es, this message translates to:
  /// **'Con {amount} € obtienes:'**
  String stationWithMoneyYouGet(String amount);

  /// No description provided for @stationExtraLitres.
  ///
  /// In es, this message translates to:
  /// **'Sacas {liters} L más'**
  String stationExtraLitres(String liters);

  /// No description provided for @stationEquivalentSavings.
  ///
  /// In es, this message translates to:
  /// **'Ahorro equivalente: {amount} € · Frente a {price} €/L'**
  String stationEquivalentSavings(String amount, String price);

  /// No description provided for @stationDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de gasolinera'**
  String get stationDetailTitle;

  /// No description provided for @stationPricesByFuel.
  ///
  /// In es, this message translates to:
  /// **'Precios por combustible'**
  String get stationPricesByFuel;

  /// No description provided for @stationLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get stationLocation;

  /// No description provided for @stationYourLocation.
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación'**
  String get stationYourLocation;

  /// No description provided for @stationNoPricesAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay precios disponibles para esta estación.'**
  String get stationNoPricesAvailable;

  /// No description provided for @stationYourFuel.
  ///
  /// In es, this message translates to:
  /// **'Tu combustible'**
  String get stationYourFuel;

  /// No description provided for @favTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Favoritos'**
  String get favTitle;

  /// No description provided for @favRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get favRetry;

  /// No description provided for @favUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron actualizar los favoritos.'**
  String get favUpdateError;

  /// No description provided for @favLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar tus favoritos. Comprueba la conexión y vuelve a intentarlo.'**
  String get favLoadError;

  /// No description provided for @favEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes favoritos'**
  String get favEmptyTitle;

  /// No description provided for @favEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega gasolineras a favoritos desde la lista principal'**
  String get favEmptyHint;

  /// No description provided for @favNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron las gasolineras favoritas'**
  String get favNotFound;

  /// No description provided for @favStraightLine.
  ///
  /// In es, this message translates to:
  /// **'En línea recta'**
  String get favStraightLine;

  /// No description provided for @favOfflinePrices.
  ///
  /// In es, this message translates to:
  /// **'Precios guardados: no se han podido actualizar.'**
  String get favOfflinePrices;

  /// No description provided for @favToggleError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el favorito'**
  String get favToggleError;

  /// No description provided for @favLoginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get favLoginTitle;

  /// No description provided for @favLoginMessage.
  ///
  /// In es, this message translates to:
  /// **'Necesitas iniciar sesión para guardar gasolineras en tus favoritos.'**
  String get favLoginMessage;

  /// No description provided for @favLoginCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get favLoginCancel;

  /// No description provided for @favLoginAction.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get favLoginAction;

  /// No description provided for @favRemoveTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get favRemoveTooltip;

  /// No description provided for @favAddTooltip.
  ///
  /// In es, this message translates to:
  /// **'Guardar favorito'**
  String get favAddTooltip;

  /// No description provided for @guideTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo usar GasoCan'**
  String get guideTitle;

  /// No description provided for @guideClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar guía'**
  String get guideClose;

  /// No description provided for @guideSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get guideSkip;

  /// No description provided for @guideNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get guideNext;

  /// No description provided for @guideStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get guideStart;

  /// No description provided for @guideStep1Title.
  ///
  /// In es, this message translates to:
  /// **'Encuentra gasolineras'**
  String get guideStep1Title;

  /// No description provided for @guideStep1Body.
  ///
  /// In es, this message translates to:
  /// **'Busca por nombre, marca o municipio. Puedes explorar Canarias aunque no compartas tu ubicación.'**
  String get guideStep1Body;

  /// No description provided for @guideStep2Title.
  ///
  /// In es, this message translates to:
  /// **'Compara precios'**
  String get guideStep2Title;

  /// No description provided for @guideStep2Body.
  ///
  /// In es, this message translates to:
  /// **'Consulta los precios por tipo de combustible y fíjate en la fecha de actualización para saber cuándo se comunicaron.'**
  String get guideStep2Body;

  /// No description provided for @guideStep3Title.
  ///
  /// In es, this message translates to:
  /// **'Elige cómo llegar'**
  String get guideStep3Title;

  /// No description provided for @guideStep3Body.
  ///
  /// In es, this message translates to:
  /// **'Cambia entre lista y mapa para situar las estaciones. En la ficha, toca “Cómo llegar” para abrir una app de navegación.'**
  String get guideStep3Body;

  /// No description provided for @guideStep4Title.
  ///
  /// In es, this message translates to:
  /// **'Guarda tus preferidas'**
  String get guideStep4Title;

  /// No description provided for @guideStep4Body.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para guardar gasolineras favoritas. En tu perfil puedes configurar el vehículo y los litros para estimar el coste.'**
  String get guideStep4Body;

  /// No description provided for @navStations.
  ///
  /// In es, this message translates to:
  /// **'Gasolineras'**
  String get navStations;

  /// No description provided for @navFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @splashTitle.
  ///
  /// In es, this message translates to:
  /// **'Gasolineras de Canarias'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Encuentra el mejor precio cerca de ti'**
  String get splashSubtitle;

  /// No description provided for @notifChannelName.
  ///
  /// In es, this message translates to:
  /// **'Bajadas de precio'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In es, this message translates to:
  /// **'Avisos cuando baja el precio en tus gasolineras favoritas'**
  String get notifChannelDescription;

  /// No description provided for @locationServicesOff.
  ///
  /// In es, this message translates to:
  /// **'Los servicios de ubicación están desactivados. Por favor, activa el GPS en tu dispositivo.'**
  String get locationServicesOff;

  /// No description provided for @locationDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación denegado. Por favor, permite el acceso a la ubicación para continuar.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación denegado permanentemente. Ve a configuración y permite el acceso a la ubicación para esta aplicación.'**
  String get locationDeniedForever;

  /// No description provided for @locationError.
  ///
  /// In es, this message translates to:
  /// **'Error al obtener la ubicación: {detalle}'**
  String locationError(String detalle);
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
