// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Gasolineras de Canarias';

  @override
  String get authRegistroExitoso =>
      '✅ Registrierung erfolgreich! Falls eine Bestätigung per E-Mail aktiv ist, sieh in deinem Posteingang nach. Andernfalls kannst du dich jetzt anmelden.';

  @override
  String get authCrearCuenta => 'Konto erstellen';

  @override
  String get authGasolinerasDeCanarias => 'Tankstellen der Kanaren';

  @override
  String get authUneteYAhorra => 'Mitmachen und sparen';

  @override
  String get authRegistroSubtitulo =>
      'Speichere deine Lieblingstankstellen und erhalte Preisalarme.';

  @override
  String get authCorreoElectronico => 'E-Mail';

  @override
  String get authCorreoObligatorio => 'E-Mail ist erforderlich';

  @override
  String get authCorreoNoValido => 'Ungültige E-Mail-Adresse';

  @override
  String get authContrasena => 'Passwort';

  @override
  String get authMinimoCaracteres => 'Mindestens 6 Zeichen';

  @override
  String get authContrasenaObligatoria => 'Passwort ist erforderlich';

  @override
  String get authContrasenaCorta =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get authConfirmarContrasena => 'Passwort bestätigen';

  @override
  String get authContrasenasNoCoinciden =>
      'Die Passwörter stimmen nicht überein';

  @override
  String get authYaTienesCuenta => 'Schon ein Konto?';

  @override
  String get authIniciaSesion => 'Anmelden';

  @override
  String get authVolverAlInicio => 'Zurück zum Start';

  @override
  String get authBienvenido => 'Willkommen';

  @override
  String get authLoginSubtitulo =>
      'Greife auf deine Favoriten und Fahrzeugeinstellungen zu.';

  @override
  String get authOlvidasteContrasena => 'Passwort vergessen?';

  @override
  String get authIniciarSesion => 'Anmelden';

  @override
  String get authNoTienesCuenta => 'Noch kein Konto?';

  @override
  String get authRegistrate => 'Registrieren';

  @override
  String get authO => 'oder';

  @override
  String get authIniciarSesionApple => 'Mit Apple anmelden';

  @override
  String get authCerrarSesion => 'Abmelden';

  @override
  String get authCerrarSesionPregunta => 'Möchtest du dich wirklich abmelden?';

  @override
  String get authCancelar => 'Abbrechen';

  @override
  String get authUsuarioDesconocido => 'Unbekannter Nutzer';

  @override
  String get authMiembroActivo => 'Aktives Mitglied';

  @override
  String get authComoUsarGasoCan => 'So funktioniert GasoCan';

  @override
  String get authConsultarGuia => 'Anleitung erneut ansehen';

  @override
  String get authInformacionCuenta => 'Kontoinformationen';

  @override
  String get authEmail => 'E-Mail';

  @override
  String get authNoDisponible => 'Nicht verfügbar';

  @override
  String get authIdUsuario => 'Nutzer-ID';

  @override
  String get authMiembroDesde => 'Mitglied seit';

  @override
  String get authEliminarCuenta => 'Konto löschen';

  @override
  String get authEliminarCuentaAviso =>
      'Dein Konto, deine Lieblingstankstellen, Preisalarme und Fahrzeugdaten werden gelöscht. Das kann nicht rückgängig gemacht werden.';

  @override
  String get authEliminar => 'Löschen';

  @override
  String get authCuentaEliminada => 'Dein Konto wurde gelöscht';

  @override
  String get authAppleNoConfirmo =>
      'Apple konnte deine Identität nicht bestätigen. Dein Konto bleibt aktiv.';

  @override
  String get authErrorEliminarCuenta =>
      'Das Konto konnte nicht gelöscht werden. Bitte versuche es später erneut.';

  @override
  String get authPerfilNoDisponible => 'Profil nicht verfügbar';

  @override
  String get authPerfilIniciaSesion =>
      'Melde dich an, um dein Profil zu sehen und weitere Funktionen zu nutzen';

  @override
  String get authApariencia => 'Darstellung';

  @override
  String get authTemaAuto => 'Auto';

  @override
  String get authTemaClaro => 'Hell';

  @override
  String get authTemaOscuro => 'Dunkel';

  @override
  String get authErrorCargarVehiculo =>
      'Fahrzeugdaten konnten nicht geladen werden.';

  @override
  String get authReintentar => 'Erneut versuchen';

  @override
  String get authVehiculoGuardado => 'Fahrzeugdaten gespeichert';

  @override
  String get authErrorGuardarVehiculo =>
      'Die Daten konnten nicht gespeichert werden. Du kannst es erneut versuchen.';

  @override
  String get authMiVehiculo => 'Mein Fahrzeug';

  @override
  String get authCombustibleHabitual => 'Üblicher Kraftstoff';

  @override
  String get authLitrosDeposito => 'Tankgröße (Liter)';

  @override
  String get authLitrosNoValidos =>
      'Gib ein Volumen über 0 und bis 1000 Liter ein.';

  @override
  String get authMatriculaOpcional => 'Kennzeichen (optional)';

  @override
  String get authCambiosAlGuardar =>
      'Änderungen werden beim Tippen auf Speichern übernommen.';

  @override
  String get authGuardando => 'Wird gespeichert…';

  @override
  String get authGuardarVehiculo => 'Fahrzeugdaten speichern';

  @override
  String get authErrorInesperadoLogin =>
      'Unerwarteter Fehler bei der Anmeldung';

  @override
  String get authAppleSinIdentidad => 'Apple hat keine Identität übermittelt';

  @override
  String get authErrorApple => 'Anmeldung mit Apple fehlgeschlagen';

  @override
  String authErrorAppleDetalle(String detalle) {
    return 'Anmeldung mit Apple fehlgeschlagen: $detalle';
  }

  @override
  String get authErrorEmailConfirmacion =>
      'Die Bestätigungs-E-Mail konnte nicht gesendet werden. Bitte versuche es später erneut.';

  @override
  String authErrorDetalle(String detalle) {
    return 'Fehler: $detalle';
  }

  @override
  String authErrorInesperado(String detalle) {
    return 'Unerwarteter Fehler: $detalle';
  }

  @override
  String get fuelGasoline95 => 'Super 95';

  @override
  String get fuelGasoline98 => 'Super Plus 98';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelDieselPremium => 'Premium-Diesel';

  @override
  String get stationWelcome => '🏝 Willkommen bei Tankstellen Kanaren';

  @override
  String get stationListTitle => 'Tankstellen';

  @override
  String get stationUseMyLocation => 'Meinen Standort verwenden';

  @override
  String get stationRefreshPrices => 'Preise aktualisieren';

  @override
  String get stationZoneAll => 'Alle Kanaren';

  @override
  String get stationZoneNearby => 'In meiner Nähe · 16 km';

  @override
  String stationFuelTooltip(String fuel) {
    return 'Kraftstoff: $fuel';
  }

  @override
  String get stationSortTooltip => 'Ergebnisse sortieren';

  @override
  String get stationSortByPrice => 'Nach Preis';

  @override
  String get stationSortByDistance => 'Nach Luftlinie';

  @override
  String get stationTextSearchAllIslands => 'Textsuche auf allen Kanaren';

  @override
  String stationOfflineNotice(String date) {
    return 'Preise konnten nicht aktualisiert werden. Es werden gespeicherte Daten vom $date angezeigt.';
  }

  @override
  String stationCountByPrice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tankstellen · nach Preis',
      one: '1 Tankstelle · nach Preis',
    );
    return '$_temp0';
  }

  @override
  String stationCountByDistance(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tankstellen · nach Entfernung',
      one: '1 Tankstelle · nach Entfernung',
    );
    return '$_temp0';
  }

  @override
  String get stationViewList => 'Liste';

  @override
  String get stationViewMap => 'Karte';

  @override
  String get stationNoResults => 'Keine Tankstellen gefunden';

  @override
  String get stationNoResultsHint =>
      'Versuche es mit einem Teil des Namens, einer anderen Marke oder einer Gemeinde.';

  @override
  String get stationClearSearchAll => 'Suche löschen und alle Kanaren anzeigen';

  @override
  String get stationRetry => 'Erneut versuchen';

  @override
  String get stationUnknownDate => 'unbekanntes Datum';

  @override
  String stationStraightLineKm(String km) {
    return '$km km Luftlinie';
  }

  @override
  String stationUpdatedAt(String date) {
    return 'Aktualisiert · $date';
  }

  @override
  String stationStalePriceAt(String date) {
    return 'Preis nicht aktuell · $date';
  }

  @override
  String get stationLoadError =>
      'Tankstellen konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get stationSearchHint => 'Marke, Adresse oder Gemeinde';

  @override
  String get stationClearSearch => 'Suche löschen';

  @override
  String get stationNoPrice => 'Kein Preis verfügbar';

  @override
  String stationPricePerLitreSemantics(String fuel, String price) {
    return '$fuel: $price Euro pro Liter';
  }

  @override
  String stationTankEstimate(String total, String liters) {
    return '$total € für $liters L · geschätzt';
  }

  @override
  String stationFuelPrice(String fuel, String price) {
    return '$fuel: $price €/L';
  }

  @override
  String stationFuelNoPrice(String fuel) {
    return '$fuel: kein Preis';
  }

  @override
  String get stationViewDetail => 'Details ansehen';

  @override
  String get stationDirections => 'Route';

  @override
  String get stationChooseMapApp => 'Karten-App auswählen';

  @override
  String get stationNoMapsInstalled => 'Keine Karten-Apps installiert';

  @override
  String stationMapOpenError(String error) {
    return 'Karte konnte nicht geöffnet werden: $error';
  }

  @override
  String stationMapTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Karte · $count Tankstellen',
      one: 'Karte · 1 Tankstelle',
    );
    return '$_temp0';
  }

  @override
  String get stationNoStationsToShow => 'Keine Tankstellen zum Anzeigen.';

  @override
  String get stationMapLoadError =>
      'Karte konnte nicht geladen werden. Geh zurück zur Liste und versuche es erneut.';

  @override
  String get stationShowAllResults => 'Alle Ergebnisse anzeigen';

  @override
  String get stationSettings => 'Einstellungen';

  @override
  String get stationCalculateRefuel => 'Tankfüllung berechnen';

  @override
  String get stationLitresToEuros => 'Liter in €';

  @override
  String get stationEurosToLitres => '€ in Liter';

  @override
  String get stationMoneyAvailable => 'Verfügbarer Betrag';

  @override
  String stationNoPriceFor(String fuel) {
    return 'Kein Preis für $fuel';
  }

  @override
  String stationPriceFor(String fuel, String price) {
    return 'Preis $fuel: $price €/L';
  }

  @override
  String get stationTankLitres => 'Tankinhalt (Liter)';

  @override
  String get stationEnterLitresHint =>
      'Gib den Tankinhalt in Litern ein, um die geschätzte Ersparnis zu sehen.';

  @override
  String stationFillCost(String liters) {
    return '$liters L tanken kostet dich:';
  }

  @override
  String get stationCheckingNearby => 'Preise in der Nähe werden abgefragt…';

  @override
  String get stationEstimateNote =>
      'Schätzung nur für den Kraftstoff, ohne Anfahrt.';

  @override
  String stationYouSave(String amount) {
    return 'Du sparst $amount €';
  }

  @override
  String stationSavingsVsMax(String price) {
    return 'Im Vergleich zum höchsten Preis im Umkreis von 16 km ($price €/L). Ohne Anfahrt.';
  }

  @override
  String get stationEnterMoneyHint =>
      'Gib einen Betrag ein, um zu sehen, wie viele Liter du bekommst.';

  @override
  String stationWithMoneyYouGet(String amount) {
    return 'Für $amount € bekommst du:';
  }

  @override
  String stationExtraLitres(String liters) {
    return 'Du bekommst $liters L mehr';
  }

  @override
  String stationEquivalentSavings(String amount, String price) {
    return 'Entspricht $amount € Ersparnis · Im Vergleich zu $price €/L';
  }

  @override
  String get stationDetailTitle => 'Tankstellendetails';

  @override
  String get stationPricesByFuel => 'Preise nach Kraftstoff';

  @override
  String get stationLocation => 'Standort';

  @override
  String get stationYourLocation => 'Dein Standort';

  @override
  String get stationNoPricesAvailable =>
      'Für diese Tankstelle sind keine Preise verfügbar.';

  @override
  String get stationYourFuel => 'Dein Kraftstoff';

  @override
  String get favTitle => 'Meine Favoriten';

  @override
  String get favRetry => 'Erneut versuchen';

  @override
  String get favUpdateError => 'Favoriten konnten nicht aktualisiert werden.';

  @override
  String get favLoadError =>
      'Deine Favoriten konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get favEmptyTitle => 'Noch keine Favoriten';

  @override
  String get favEmptyHint =>
      'Füge Tankstellen über die Hauptliste zu deinen Favoriten hinzu';

  @override
  String get favNotFound => 'Deine Lieblingstankstellen wurden nicht gefunden';

  @override
  String get favStraightLine => 'Luftlinie';

  @override
  String get favOfflinePrices =>
      'Gespeicherte Preise: Sie konnten nicht aktualisiert werden.';

  @override
  String get favToggleError => 'Favorit konnte nicht aktualisiert werden';

  @override
  String get favLoginTitle => 'Anmelden';

  @override
  String get favLoginMessage =>
      'Melde dich an, um Tankstellen in deinen Favoriten zu speichern.';

  @override
  String get favLoginCancel => 'Abbrechen';

  @override
  String get favLoginAction => 'Anmelden';

  @override
  String get favRemoveTooltip => 'Aus Favoriten entfernen';

  @override
  String get favAddTooltip => 'Als Favorit speichern';

  @override
  String get guideTitle => 'Kurzanleitung';

  @override
  String get guideClose => 'Anleitung schließen';

  @override
  String get guideSkip => 'Überspringen';

  @override
  String get guideNext => 'Weiter';

  @override
  String get guideStart => 'Los geht\'s';

  @override
  String get guideStep1Title => 'Tankstellen finden';

  @override
  String get guideStep1Body =>
      'Suche nach Name, Marke oder Gemeinde. Du kannst die Kanaren auch erkunden, ohne deinen Standort zu teilen.';

  @override
  String get guideStep2Title => 'Preise vergleichen';

  @override
  String get guideStep2Body =>
      'Sieh dir die Preise nach Kraftstoffart an und achte auf das Aktualisierungsdatum, um zu wissen, wann sie gemeldet wurden.';

  @override
  String get guideStep3Title => 'Route wählen';

  @override
  String get guideStep3Body =>
      'Wechsle zwischen Liste und Karte, um die Tankstellen zu finden. Tippe in den Details auf „Route“, um eine Navi-App zu öffnen.';

  @override
  String get guideStep4Title => 'Lieblingstankstellen speichern';

  @override
  String get guideStep4Body =>
      'Melde dich an, um Lieblingstankstellen zu speichern. In deinem Profil kannst du Fahrzeug und Liter einstellen, um die Kosten zu schätzen.';

  @override
  String get navStations => 'Tankstellen';

  @override
  String get navFavorites => 'Favoriten';

  @override
  String get navProfile => 'Profil';

  @override
  String get splashTitle => 'Tankstellen der Kanaren';

  @override
  String get splashSubtitle => 'Finde den besten Preis in deiner Nähe';

  @override
  String get notifChannelName => 'Preissenkungen';

  @override
  String get notifChannelDescription =>
      'Hinweise, wenn der Preis an deinen Lieblingstankstellen sinkt';

  @override
  String get locationServicesOff =>
      'Die Ortungsdienste sind deaktiviert. Bitte aktiviere GPS auf deinem Gerät.';

  @override
  String get locationDenied =>
      'Standortberechtigung verweigert. Bitte erlaube den Standortzugriff, um fortzufahren.';

  @override
  String get locationDeniedForever =>
      'Standortberechtigung dauerhaft verweigert. Öffne die Einstellungen und erlaube dieser App den Standortzugriff.';

  @override
  String locationError(String detalle) {
    return 'Standort konnte nicht ermittelt werden: $detalle';
  }
}
