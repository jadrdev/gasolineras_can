// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Tankstellen der Kanarischen Inseln';

  @override
  String get tabGasStations => 'Tankstellen';

  @override
  String get tabFavorites => 'Favoriten';

  @override
  String get tabProfile => 'Profil';

  @override
  String get sortByPrice => 'Nach Preis sortieren';

  @override
  String get sortByDistance => 'Nach Entfernung sortieren';

  @override
  String get searchHint => 'Nach Name, Adresse oder Marke suchen';

  @override
  String get noGasStationsFound => 'Keine Tankstellen gefunden';

  @override
  String get tryRefreshOrChangeFilters =>
      'Versuchen Sie zu aktualisieren oder Filter zu ändern.';

  @override
  String get retry => 'Wiederholen';

  @override
  String updatedMinutesAgo(int minutes) {
    return 'Vor $minutes Min. aktualisiert';
  }

  @override
  String updatedHoursAgo(int hours) {
    return 'Vor $hours Std. aktualisiert';
  }

  @override
  String updatedDaysAgo(int days) {
    return 'Vor $days Tagen aktualisiert';
  }

  @override
  String updatedOn(String date) {
    return 'Aktualisiert am $date';
  }

  @override
  String get notUpdated => 'Nicht aktualisiert';

  @override
  String get gasoline95 => 'Benzin 95';

  @override
  String get gasoline98 => 'Benzin 98';

  @override
  String get diesel => 'Diesel';

  @override
  String get dieselPremium => 'Premium Diesel';

  @override
  String get yourLocation => 'Ihr Standort';

  @override
  String get howToGetThere => 'Route anzeigen';

  @override
  String get selectMapApp => 'Karten-App auswählen';

  @override
  String get noMapAppsInstalled => 'Keine Karten-Apps installiert';

  @override
  String get address => 'Adresse:';

  @override
  String get brand => 'Marke:';

  @override
  String get myFavorites => 'Meine Favoriten';

  @override
  String get noFavorites => 'Sie haben keine Favoriten';

  @override
  String get addFavoritesFromMainList =>
      'Fügen Sie Tankstellen aus der Hauptliste zu Favoriten hinzu';

  @override
  String get favoriteStationsNotFound =>
      'Favorisierte Tankstellen nicht gefunden';

  @override
  String get logout => 'Abmelden';

  @override
  String get logoutConfirmation => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get activeMember => 'Aktives Mitglied';

  @override
  String get accountInformation => 'Kontoinformationen';

  @override
  String get email => 'E-Mail';

  @override
  String get userId => 'Benutzer-ID';

  @override
  String get memberSince => 'Mitglied seit';

  @override
  String get profileNotAvailable => 'Profil nicht verfügbar';

  @override
  String get loginToViewProfile =>
      'Melden Sie sich an, um Ihr Profil anzuzeigen und auf zusätzliche Funktionen zuzugreifen';

  @override
  String get login => 'Anmelden';

  @override
  String get loginPrompt => 'Melden Sie sich an, um fortzufahren';

  @override
  String get password => 'Passwort';

  @override
  String get noAccount => 'Noch kein Konto?';

  @override
  String get register => 'Registrieren';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get registration => 'Registrierung';

  @override
  String get createAccountToSaveFavorites =>
      'Erstellen Sie Ihr Konto, um Ihre Lieblingstankstellen zu speichern';

  @override
  String get emailAddress => 'E-Mail-Adresse';

  @override
  String get minimumCharacters => 'Mindestens 6 Zeichen';

  @override
  String get passwordTooShort =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto?';

  @override
  String get registrationSuccess =>
      '✅ Vielen Dank für Ihre Registrierung! Wir haben Ihnen eine E-Mail zur Bestätigung Ihrer Registrierung gesendet. Bitte überprüfen Sie Ihren Posteingang.';

  @override
  String get invalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';
}
