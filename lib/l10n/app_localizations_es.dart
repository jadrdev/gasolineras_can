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
  String get authRegistroExitoso =>
      '✅ ¡Registro exitoso! Si la confirmación por email está habilitada, revisa tu bandeja de entrada. En caso contrario, ya puedes iniciar sesión.';

  @override
  String get authCrearCuenta => 'Crear cuenta';

  @override
  String get authGasolinerasDeCanarias => 'Gasolineras de Canarias';

  @override
  String get authUneteYAhorra => 'Únete y ahorra';

  @override
  String get authRegistroSubtitulo =>
      'Guarda tus gasolineras favoritas y recibe alertas de precios.';

  @override
  String get authCorreoElectronico => 'Correo electrónico';

  @override
  String get authCorreoObligatorio => 'El correo es obligatorio';

  @override
  String get authCorreoNoValido => 'Correo electrónico no válido';

  @override
  String get authContrasena => 'Contraseña';

  @override
  String get authMinimoCaracteres => 'Mínimo 6 caracteres';

  @override
  String get authContrasenaObligatoria => 'La contraseña es obligatoria';

  @override
  String get authContrasenaCorta =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authConfirmarContrasena => 'Confirmar contraseña';

  @override
  String get authContrasenasNoCoinciden => 'Las contraseñas no coinciden';

  @override
  String get authYaTienesCuenta => '¿Ya tienes cuenta?';

  @override
  String get authIniciaSesion => 'Inicia sesión';

  @override
  String get authVolverAlInicio => 'Volver al inicio';

  @override
  String get authBienvenido => 'Bienvenido';

  @override
  String get authLoginSubtitulo =>
      'Accede a tus favoritos y preferencias de vehículo.';

  @override
  String get authOlvidasteContrasena => '¿Olvidaste tu contraseña?';

  @override
  String get authIniciarSesion => 'Iniciar sesión';

  @override
  String get authNoTienesCuenta => '¿No tienes cuenta?';

  @override
  String get authRegistrate => 'Regístrate';

  @override
  String get authO => 'o';

  @override
  String get authIniciarSesionApple => 'Iniciar sesión con Apple';

  @override
  String get authCerrarSesion => 'Cerrar sesión';

  @override
  String get authCerrarSesionPregunta =>
      '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get authCancelar => 'Cancelar';

  @override
  String get authUsuarioDesconocido => 'Usuario desconocido';

  @override
  String get authMiembroActivo => 'Miembro activo';

  @override
  String get authComoUsarGasoCan => 'Cómo usar GasoCan';

  @override
  String get authConsultarGuia => 'Vuelve a consultar la guía';

  @override
  String get authInformacionCuenta => 'Información de la cuenta';

  @override
  String get authEmail => 'Email';

  @override
  String get authNoDisponible => 'No disponible';

  @override
  String get authIdUsuario => 'ID de usuario';

  @override
  String get authMiembroDesde => 'Miembro desde';

  @override
  String get authEliminarCuenta => 'Eliminar cuenta';

  @override
  String get authEliminarCuentaAviso =>
      'Se borrarán tu cuenta, tus gasolineras favoritas, tus alertas de precio y los datos de tu vehículo. No se puede deshacer.';

  @override
  String get authEliminar => 'Eliminar';

  @override
  String get authCuentaEliminada => 'Tu cuenta se ha eliminado';

  @override
  String get authAppleNoConfirmo =>
      'Apple no pudo confirmar tu identidad. La cuenta sigue activa.';

  @override
  String get authErrorEliminarCuenta =>
      'No se pudo eliminar la cuenta. Inténtalo de nuevo más tarde.';

  @override
  String get authPerfilNoDisponible => 'Perfil no disponible';

  @override
  String get authPerfilIniciaSesion =>
      'Inicia sesión para ver tu perfil y acceder a funciones adicionales';

  @override
  String get authApariencia => 'Apariencia';

  @override
  String get authTemaAuto => 'Auto';

  @override
  String get authTemaClaro => 'Claro';

  @override
  String get authTemaOscuro => 'Oscuro';

  @override
  String get authErrorCargarVehiculo =>
      'No se pudieron cargar los datos del vehículo.';

  @override
  String get authReintentar => 'Reintentar';

  @override
  String get authVehiculoGuardado => 'Datos del vehículo guardados';

  @override
  String get authErrorGuardarVehiculo =>
      'No se pudieron guardar los datos. Puedes volver a intentarlo.';

  @override
  String get authMiVehiculo => 'Mi vehículo';

  @override
  String get authCombustibleHabitual => 'Combustible habitual';

  @override
  String get authLitrosDeposito => 'Litros del depósito';

  @override
  String get authLitrosNoValidos =>
      'Introduce una capacidad entre 0 y 1000 litros, mayor que cero.';

  @override
  String get authMatriculaOpcional => 'Matrícula (opcional)';

  @override
  String get authCambiosAlGuardar =>
      'Los cambios se aplican al pulsar Guardar.';

  @override
  String get authGuardando => 'Guardando…';

  @override
  String get authGuardarVehiculo => 'Guardar datos del vehículo';

  @override
  String get authErrorInesperadoLogin => 'Error inesperado al iniciar sesión';

  @override
  String get authAppleSinIdentidad => 'Apple no devolvió la identidad';

  @override
  String get authErrorApple => 'No se pudo iniciar sesión con Apple';

  @override
  String authErrorAppleDetalle(String detalle) {
    return 'No se pudo iniciar sesión con Apple: $detalle';
  }

  @override
  String get authErrorEmailConfirmacion =>
      'No se pudo enviar el email de confirmación. Vuelve a intentarlo más tarde.';

  @override
  String authErrorDetalle(String detalle) {
    return 'Error: $detalle';
  }

  @override
  String authErrorInesperado(String detalle) {
    return 'Error inesperado: $detalle';
  }

  @override
  String get fuelGasoline95 => 'Gasolina 95';

  @override
  String get fuelGasoline98 => 'Gasolina 98';

  @override
  String get fuelDiesel => 'Diésel';

  @override
  String get fuelDieselPremium => 'Diésel Premium';

  @override
  String get stationWelcome => '🏝 Bienvenido a Gasolineras Canarias';

  @override
  String get stationListTitle => 'Gasolineras';

  @override
  String get stationUseMyLocation => 'Usar mi ubicación';

  @override
  String get stationRefreshPrices => 'Actualizar precios';

  @override
  String get stationZoneAll => 'Toda Canarias';

  @override
  String get stationZoneNearby => 'Cerca de mí · 16 km';

  @override
  String stationFuelTooltip(String fuel) {
    return 'Combustible: $fuel';
  }

  @override
  String get stationSortTooltip => 'Ordenar resultados';

  @override
  String get stationSortByPrice => 'Por precio';

  @override
  String get stationSortByDistance => 'Por distancia en línea recta';

  @override
  String get stationTextSearchAllIslands =>
      'Búsqueda por texto en toda Canarias';

  @override
  String stationOfflineNotice(String date) {
    return 'No se pudieron actualizar los precios. Mostrando datos guardados del $date.';
  }

  @override
  String stationCountByPrice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gasolineras · por precio',
      one: '1 gasolinera · por precio',
    );
    return '$_temp0';
  }

  @override
  String stationCountByDistance(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gasolineras · por distancia',
      one: '1 gasolinera · por distancia',
    );
    return '$_temp0';
  }

  @override
  String get stationViewList => 'Lista';

  @override
  String get stationViewMap => 'Mapa';

  @override
  String get stationNoResults => 'No se han encontrado gasolineras';

  @override
  String get stationNoResultsHint =>
      'Prueba con parte del nombre, otra marca o un municipio.';

  @override
  String get stationClearSearchAll => 'Borrar búsqueda y ver toda Canarias';

  @override
  String get stationRetry => 'Reintentar';

  @override
  String get stationUnknownDate => 'fecha desconocida';

  @override
  String stationStraightLineKm(String km) {
    return '$km km en línea recta';
  }

  @override
  String stationUpdatedAt(String date) {
    return 'Actualizado · $date';
  }

  @override
  String stationStalePriceAt(String date) {
    return 'Precio sin actualización reciente · $date';
  }

  @override
  String get stationLoadError =>
      'No se pudieron cargar las gasolineras. Comprueba la conexión y vuelve a intentarlo.';

  @override
  String get stationSearchHint => 'Marca, dirección o municipio';

  @override
  String get stationClearSearch => 'Borrar búsqueda';

  @override
  String get stationNoPrice => 'Sin precio disponible';

  @override
  String stationPricePerLitreSemantics(String fuel, String price) {
    return '$fuel: $price euros por litro';
  }

  @override
  String stationTankEstimate(String total, String liters) {
    return '$total € para $liters L · estimado';
  }

  @override
  String stationFuelPrice(String fuel, String price) {
    return '$fuel: $price €/L';
  }

  @override
  String stationFuelNoPrice(String fuel) {
    return '$fuel: sin precio';
  }

  @override
  String get stationViewDetail => 'Ver detalle';

  @override
  String get stationDirections => 'Cómo llegar';

  @override
  String get stationChooseMapApp => 'Selecciona una app de mapas';

  @override
  String get stationNoMapsInstalled =>
      'No hay aplicaciones de mapas instaladas';

  @override
  String stationMapOpenError(String error) {
    return 'Error al abrir el mapa: $error';
  }

  @override
  String stationMapTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mapa · $count gasolineras',
      one: 'Mapa · 1 gasolinera',
    );
    return '$_temp0';
  }

  @override
  String get stationNoStationsToShow => 'No hay gasolineras para mostrar.';

  @override
  String get stationMapLoadError =>
      'No se pudo cargar el mapa. Vuelve a la lista e inténtalo de nuevo.';

  @override
  String get stationShowAllResults => 'Ver todos los resultados';

  @override
  String get stationSettings => 'Configuración';

  @override
  String get stationCalculateRefuel => 'Calcula tu repostaje';

  @override
  String get stationLitresToEuros => 'Litros a €';

  @override
  String get stationEurosToLitres => '€ a litros';

  @override
  String get stationMoneyAvailable => 'Dinero disponible';

  @override
  String stationNoPriceFor(String fuel) {
    return 'No hay precio para $fuel';
  }

  @override
  String stationPriceFor(String fuel, String price) {
    return 'Precio $fuel: $price €/L';
  }

  @override
  String get stationTankLitres => 'Litros del depósito';

  @override
  String get stationEnterLitresHint =>
      'Introduce los litros de tu depósito para ver el ahorro estimado.';

  @override
  String stationFillCost(String liters) {
    return 'Llenar $liters L te costaría:';
  }

  @override
  String get stationCheckingNearby => 'Consultando precios cercanos…';

  @override
  String get stationEstimateNote =>
      'Estimación del combustible; no incluye desplazamiento.';

  @override
  String stationYouSave(String amount) {
    return 'Ahorras $amount €';
  }

  @override
  String stationSavingsVsMax(String price) {
    return 'Frente al mayor precio a 16 km de tu ubicación ($price €/L). No incluye desplazamiento.';
  }

  @override
  String get stationEnterMoneyHint =>
      'Introduce la cantidad de dinero para ver cuántos litros obtienes.';

  @override
  String stationWithMoneyYouGet(String amount) {
    return 'Con $amount € obtienes:';
  }

  @override
  String stationExtraLitres(String liters) {
    return 'Sacas $liters L más';
  }

  @override
  String stationEquivalentSavings(String amount, String price) {
    return 'Ahorro equivalente: $amount € · Frente a $price €/L';
  }

  @override
  String get stationDetailTitle => 'Detalle de gasolinera';

  @override
  String get stationPricesByFuel => 'Precios por combustible';

  @override
  String get stationLocation => 'Ubicación';

  @override
  String get stationYourLocation => 'Tu ubicación';

  @override
  String get stationNoPricesAvailable =>
      'No hay precios disponibles para esta estación.';

  @override
  String get stationYourFuel => 'Tu combustible';

  @override
  String get favTitle => 'Mis Favoritos';

  @override
  String get favRetry => 'Reintentar';

  @override
  String get favUpdateError => 'No se pudieron actualizar los favoritos.';

  @override
  String get favLoadError =>
      'No se pudieron cargar tus favoritos. Comprueba la conexión y vuelve a intentarlo.';

  @override
  String get favEmptyTitle => 'No tienes favoritos';

  @override
  String get favEmptyHint =>
      'Agrega gasolineras a favoritos desde la lista principal';

  @override
  String get favNotFound => 'No se encontraron las gasolineras favoritas';

  @override
  String get favStraightLine => 'En línea recta';

  @override
  String get favOfflinePrices =>
      'Precios guardados: no se han podido actualizar.';

  @override
  String get favToggleError => 'No se pudo actualizar el favorito';

  @override
  String get favLoginTitle => 'Inicia sesión';

  @override
  String get favLoginMessage =>
      'Necesitas iniciar sesión para guardar gasolineras en tus favoritos.';

  @override
  String get favLoginCancel => 'Cancelar';

  @override
  String get favLoginAction => 'Iniciar sesión';

  @override
  String get favRemoveTooltip => 'Quitar de favoritos';

  @override
  String get favAddTooltip => 'Guardar favorito';

  @override
  String get guideTitle => 'Cómo usar GasoCan';

  @override
  String get guideClose => 'Cerrar guía';

  @override
  String get guideSkip => 'Omitir';

  @override
  String get guideNext => 'Siguiente';

  @override
  String get guideStart => 'Empezar';

  @override
  String get guideStep1Title => 'Encuentra gasolineras';

  @override
  String get guideStep1Body =>
      'Busca por nombre, marca o municipio. Puedes explorar Canarias aunque no compartas tu ubicación.';

  @override
  String get guideStep2Title => 'Compara precios';

  @override
  String get guideStep2Body =>
      'Consulta los precios por tipo de combustible y fíjate en la fecha de actualización para saber cuándo se comunicaron.';

  @override
  String get guideStep3Title => 'Elige cómo llegar';

  @override
  String get guideStep3Body =>
      'Cambia entre lista y mapa para situar las estaciones. En la ficha, toca “Cómo llegar” para abrir una app de navegación.';

  @override
  String get guideStep4Title => 'Guarda tus preferidas';

  @override
  String get guideStep4Body =>
      'Inicia sesión para guardar gasolineras favoritas. En tu perfil puedes configurar el vehículo y los litros para estimar el coste.';

  @override
  String get navStations => 'Gasolineras';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get splashTitle => 'Gasolineras de Canarias';

  @override
  String get splashSubtitle => 'Encuentra el mejor precio cerca de ti';

  @override
  String get notifChannelName => 'Bajadas de precio';

  @override
  String get notifChannelDescription =>
      'Avisos cuando baja el precio en tus gasolineras favoritas';

  @override
  String get locationServicesOff =>
      'Los servicios de ubicación están desactivados. Por favor, activa el GPS en tu dispositivo.';

  @override
  String get locationDenied =>
      'Permiso de ubicación denegado. Por favor, permite el acceso a la ubicación para continuar.';

  @override
  String get locationDeniedForever =>
      'Permiso de ubicación denegado permanentemente. Ve a configuración y permite el acceso a la ubicación para esta aplicación.';

  @override
  String locationError(String detalle) {
    return 'Error al obtener la ubicación: $detalle';
  }
}
