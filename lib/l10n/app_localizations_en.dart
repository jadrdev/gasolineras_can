// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gasolineras de Canarias';

  @override
  String get authRegistroExitoso =>
      '✅ You\'re signed up! If email confirmation is on, check your inbox. Otherwise, you can sign in now.';

  @override
  String get authCrearCuenta => 'Create account';

  @override
  String get authGasolinerasDeCanarias => 'Canary Islands petrol stations';

  @override
  String get authUneteYAhorra => 'Join and save';

  @override
  String get authRegistroSubtitulo =>
      'Save your favourite petrol stations and get price alerts.';

  @override
  String get authCorreoElectronico => 'Email';

  @override
  String get authCorreoObligatorio => 'Email is required';

  @override
  String get authCorreoNoValido => 'Invalid email address';

  @override
  String get authContrasena => 'Password';

  @override
  String get authMinimoCaracteres => 'At least 6 characters';

  @override
  String get authContrasenaObligatoria => 'Password is required';

  @override
  String get authContrasenaCorta => 'Password must be at least 6 characters';

  @override
  String get authConfirmarContrasena => 'Confirm password';

  @override
  String get authContrasenasNoCoinciden => 'Passwords don\'t match';

  @override
  String get authYaTienesCuenta => 'Already have an account?';

  @override
  String get authIniciaSesion => 'Sign in';

  @override
  String get authVolverAlInicio => 'Back to home';

  @override
  String get authBienvenido => 'Welcome';

  @override
  String get authLoginSubtitulo =>
      'Access your favourites and vehicle preferences.';

  @override
  String get authOlvidasteContrasena => 'Forgot your password?';

  @override
  String get authIniciarSesion => 'Sign in';

  @override
  String get authNoTienesCuenta => 'Don\'t have an account?';

  @override
  String get authRegistrate => 'Sign up';

  @override
  String get authO => 'or';

  @override
  String get authIniciarSesionApple => 'Sign in with Apple';

  @override
  String get authCerrarSesion => 'Sign out';

  @override
  String get authCerrarSesionPregunta => 'Are you sure you want to sign out?';

  @override
  String get authCancelar => 'Cancel';

  @override
  String get authUsuarioDesconocido => 'Unknown user';

  @override
  String get authMiembroActivo => 'Active member';

  @override
  String get authComoUsarGasoCan => 'How to use GasoCan';

  @override
  String get authConsultarGuia => 'View the guide again';

  @override
  String get authInformacionCuenta => 'Account information';

  @override
  String get authEmail => 'Email';

  @override
  String get authNoDisponible => 'Not available';

  @override
  String get authIdUsuario => 'User ID';

  @override
  String get authMiembroDesde => 'Member since';

  @override
  String get authEliminarCuenta => 'Delete account';

  @override
  String get authEliminarCuentaAviso =>
      'Your account, favourite petrol stations, price alerts and vehicle details will be deleted. This can\'t be undone.';

  @override
  String get authEliminar => 'Delete';

  @override
  String get authCuentaEliminada => 'Your account has been deleted';

  @override
  String get authAppleNoConfirmo =>
      'Apple couldn\'t confirm your identity. Your account is still active.';

  @override
  String get authErrorEliminarCuenta =>
      'Couldn\'t delete your account. Please try again later.';

  @override
  String get authPerfilNoDisponible => 'Profile unavailable';

  @override
  String get authPerfilIniciaSesion =>
      'Sign in to see your profile and access extra features';

  @override
  String get authApariencia => 'Appearance';

  @override
  String get authTemaAuto => 'Auto';

  @override
  String get authTemaClaro => 'Light';

  @override
  String get authTemaOscuro => 'Dark';

  @override
  String get authErrorCargarVehiculo => 'Couldn\'t load your vehicle details.';

  @override
  String get authReintentar => 'Retry';

  @override
  String get authVehiculoGuardado => 'Vehicle details saved';

  @override
  String get authErrorGuardarVehiculo =>
      'Couldn\'t save your details. Please try again.';

  @override
  String get authMiVehiculo => 'My vehicle';

  @override
  String get authCombustibleHabitual => 'Usual fuel';

  @override
  String get authLitrosDeposito => 'Tank size (litres)';

  @override
  String get authLitrosNoValidos =>
      'Enter a capacity above 0 and up to 1000 litres.';

  @override
  String get authMatriculaOpcional => 'Number plate (optional)';

  @override
  String get authCambiosAlGuardar => 'Changes apply when you tap Save.';

  @override
  String get authGuardando => 'Saving…';

  @override
  String get authGuardarVehiculo => 'Save vehicle details';

  @override
  String get authErrorInesperadoLogin => 'Unexpected error while signing in';

  @override
  String get authAppleSinIdentidad => 'Apple didn\'t return your identity';

  @override
  String get authErrorApple => 'Couldn\'t sign in with Apple';

  @override
  String authErrorAppleDetalle(String detalle) {
    return 'Couldn\'t sign in with Apple: $detalle';
  }

  @override
  String get authErrorEmailConfirmacion =>
      'Couldn\'t send the confirmation email. Please try again later.';

  @override
  String authErrorDetalle(String detalle) {
    return 'Error: $detalle';
  }

  @override
  String authErrorInesperado(String detalle) {
    return 'Unexpected error: $detalle';
  }

  @override
  String get fuelGasoline95 => 'Unleaded 95';

  @override
  String get fuelGasoline98 => 'Super Unleaded 98';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelDieselPremium => 'Premium Diesel';

  @override
  String get stationWelcome => '🏝 Welcome to Canary Islands Petrol Stations';

  @override
  String get stationListTitle => 'Petrol stations';

  @override
  String get stationUseMyLocation => 'Use my location';

  @override
  String get stationRefreshPrices => 'Refresh prices';

  @override
  String get stationZoneAll => 'All Canary Islands';

  @override
  String get stationZoneNearby => 'Near me · 16 km';

  @override
  String stationFuelTooltip(String fuel) {
    return 'Fuel: $fuel';
  }

  @override
  String get stationSortTooltip => 'Sort results';

  @override
  String get stationSortByPrice => 'By price';

  @override
  String get stationSortByDistance => 'By straight-line distance';

  @override
  String get stationTextSearchAllIslands =>
      'Text search across all the Canary Islands';

  @override
  String stationOfflineNotice(String date) {
    return 'Couldn\'t update prices. Showing data saved on $date.';
  }

  @override
  String stationCountByPrice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations · by price',
      one: '1 station · by price',
    );
    return '$_temp0';
  }

  @override
  String stationCountByDistance(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations · by distance',
      one: '1 station · by distance',
    );
    return '$_temp0';
  }

  @override
  String get stationViewList => 'List';

  @override
  String get stationViewMap => 'Map';

  @override
  String get stationNoResults => 'No petrol stations found';

  @override
  String get stationNoResultsHint =>
      'Try part of the name, another brand or a municipality.';

  @override
  String get stationClearSearchAll =>
      'Clear search and show all Canary Islands';

  @override
  String get stationRetry => 'Try again';

  @override
  String get stationUnknownDate => 'unknown date';

  @override
  String stationStraightLineKm(String km) {
    return '$km km in a straight line';
  }

  @override
  String stationUpdatedAt(String date) {
    return 'Updated · $date';
  }

  @override
  String stationStalePriceAt(String date) {
    return 'Price not updated recently · $date';
  }

  @override
  String get stationLoadError =>
      'Couldn\'t load petrol stations. Check your connection and try again.';

  @override
  String get stationSearchHint => 'Brand, address or municipality';

  @override
  String get stationClearSearch => 'Clear search';

  @override
  String get stationNoPrice => 'No price available';

  @override
  String stationPricePerLitreSemantics(String fuel, String price) {
    return '$fuel: $price euros per litre';
  }

  @override
  String stationTankEstimate(String total, String liters) {
    return '€$total for $liters L · estimate';
  }

  @override
  String stationFuelPrice(String fuel, String price) {
    return '$fuel: $price €/L';
  }

  @override
  String stationFuelNoPrice(String fuel) {
    return '$fuel: no price';
  }

  @override
  String get stationViewDetail => 'View details';

  @override
  String get stationDirections => 'Directions';

  @override
  String get stationChooseMapApp => 'Choose a maps app';

  @override
  String get stationNoMapsInstalled => 'No maps apps installed';

  @override
  String stationMapOpenError(String error) {
    return 'Couldn\'t open the map: $error';
  }

  @override
  String stationMapTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Map · $count stations',
      one: 'Map · 1 station',
    );
    return '$_temp0';
  }

  @override
  String get stationNoStationsToShow => 'No petrol stations to show.';

  @override
  String get stationMapLoadError =>
      'Couldn\'t load the map. Go back to the list and try again.';

  @override
  String get stationShowAllResults => 'Show all results';

  @override
  String get stationSettings => 'Settings';

  @override
  String get stationCalculateRefuel => 'Work out your fill-up';

  @override
  String get stationLitresToEuros => 'Litres to €';

  @override
  String get stationEurosToLitres => '€ to litres';

  @override
  String get stationMoneyAvailable => 'Your budget';

  @override
  String stationNoPriceFor(String fuel) {
    return 'No price for $fuel';
  }

  @override
  String stationPriceFor(String fuel, String price) {
    return '$fuel price: $price €/L';
  }

  @override
  String get stationTankLitres => 'Tank size (litres)';

  @override
  String get stationEnterLitresHint =>
      'Enter your tank size in litres to see the estimated saving.';

  @override
  String stationFillCost(String liters) {
    return 'Filling $liters L would cost you:';
  }

  @override
  String get stationCheckingNearby => 'Checking nearby prices…';

  @override
  String get stationEstimateNote => 'Fuel estimate only; travel not included.';

  @override
  String stationYouSave(String amount) {
    return 'You save €$amount';
  }

  @override
  String stationSavingsVsMax(String price) {
    return 'Compared with the highest price within 16 km of you ($price €/L). Travel not included.';
  }

  @override
  String get stationEnterMoneyHint =>
      'Enter an amount to see how many litres you get.';

  @override
  String stationWithMoneyYouGet(String amount) {
    return 'With €$amount you get:';
  }

  @override
  String stationExtraLitres(String liters) {
    return 'You get $liters L more';
  }

  @override
  String stationEquivalentSavings(String amount, String price) {
    return 'Equivalent saving: €$amount · Compared with $price €/L';
  }

  @override
  String get stationDetailTitle => 'Petrol station details';

  @override
  String get stationPricesByFuel => 'Prices by fuel';

  @override
  String get stationLocation => 'Location';

  @override
  String get stationYourLocation => 'Your location';

  @override
  String get stationNoPricesAvailable =>
      'No prices available for this station.';

  @override
  String get stationYourFuel => 'Your fuel';

  @override
  String get favTitle => 'My Favourites';

  @override
  String get favRetry => 'Try again';

  @override
  String get favUpdateError => 'Couldn\'t update your favourites.';

  @override
  String get favLoadError =>
      'Couldn\'t load your favourites. Check your connection and try again.';

  @override
  String get favEmptyTitle => 'No favourites yet';

  @override
  String get favEmptyHint =>
      'Add petrol stations to your favourites from the main list';

  @override
  String get favNotFound => 'Your favourite petrol stations couldn\'t be found';

  @override
  String get favStraightLine => 'As the crow flies';

  @override
  String get favOfflinePrices => 'Saved prices: they couldn\'t be updated.';

  @override
  String get favToggleError => 'Couldn\'t update the favourite';

  @override
  String get favLoginTitle => 'Sign in';

  @override
  String get favLoginMessage =>
      'You need to sign in to save petrol stations to your favourites.';

  @override
  String get favLoginCancel => 'Cancel';

  @override
  String get favLoginAction => 'Sign in';

  @override
  String get favRemoveTooltip => 'Remove from favourites';

  @override
  String get favAddTooltip => 'Save as favourite';

  @override
  String get guideTitle => 'How to use GasoCan';

  @override
  String get guideClose => 'Close guide';

  @override
  String get guideSkip => 'Skip';

  @override
  String get guideNext => 'Next';

  @override
  String get guideStart => 'Get started';

  @override
  String get guideStep1Title => 'Find petrol stations';

  @override
  String get guideStep1Body =>
      'Search by name, brand or town. You can explore the Canary Islands even without sharing your location.';

  @override
  String get guideStep2Title => 'Compare prices';

  @override
  String get guideStep2Body =>
      'Check prices by fuel type and look at the update date to see when they were reported.';

  @override
  String get guideStep3Title => 'Choose how to get there';

  @override
  String get guideStep3Body =>
      'Switch between list and map to locate the stations. On a station\'s page, tap “Directions” to open a navigation app.';

  @override
  String get guideStep4Title => 'Save your favourites';

  @override
  String get guideStep4Body =>
      'Sign in to save favourite petrol stations. In your profile you can set your vehicle and litres to estimate the cost.';

  @override
  String get navStations => 'Stations';

  @override
  String get navFavorites => 'Favourites';

  @override
  String get navProfile => 'Profile';

  @override
  String get splashTitle => 'Canary Islands Petrol Stations';

  @override
  String get splashSubtitle => 'Find the best price near you';

  @override
  String get notifChannelName => 'Price drops';

  @override
  String get notifChannelDescription =>
      'Alerts when prices drop at your favourite petrol stations';

  @override
  String get locationServicesOff =>
      'Location services are turned off. Please turn on GPS on your device.';

  @override
  String get locationDenied =>
      'Location permission denied. Please allow location access to continue.';

  @override
  String get locationDeniedForever =>
      'Location permission permanently denied. Go to Settings and allow location access for this app.';

  @override
  String locationError(String detalle) {
    return 'Couldn\'t get your location: $detalle';
  }
}
