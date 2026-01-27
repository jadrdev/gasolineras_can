// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Canary Islands Gas Stations';

  @override
  String get tabGasStations => 'Gas Stations';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get tabProfile => 'Profile';

  @override
  String get sortByPrice => 'Sort by price';

  @override
  String get sortByDistance => 'Sort by distance';

  @override
  String get searchHint => 'Search by name, address or brand';

  @override
  String get noGasStationsFound => 'No gas stations found';

  @override
  String get tryRefreshOrChangeFilters => 'Try refreshing or changing filters.';

  @override
  String get retry => 'Retry';

  @override
  String updatedMinutesAgo(int minutes) {
    return 'Updated $minutes min ago';
  }

  @override
  String updatedHoursAgo(int hours) {
    return 'Updated $hours h ago';
  }

  @override
  String updatedDaysAgo(int days) {
    return 'Updated $days days ago';
  }

  @override
  String updatedOn(String date) {
    return 'Updated on $date';
  }

  @override
  String get notUpdated => 'Not updated';

  @override
  String get gasoline95 => 'Gasoline 95';

  @override
  String get gasoline98 => 'Gasoline 98';

  @override
  String get diesel => 'Diesel';

  @override
  String get dieselPremium => 'Premium Diesel';

  @override
  String get yourLocation => 'Your location';

  @override
  String get howToGetThere => 'Get directions';

  @override
  String get selectMapApp => 'Select a map app';

  @override
  String get noMapAppsInstalled => 'No map apps installed';

  @override
  String get address => 'Address:';

  @override
  String get brand => 'Brand:';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get noFavorites => 'You have no favorites';

  @override
  String get addFavoritesFromMainList =>
      'Add gas stations to favorites from the main list';

  @override
  String get favoriteStationsNotFound => 'Favorite gas stations not found';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get activeMember => 'Active member';

  @override
  String get accountInformation => 'Account information';

  @override
  String get email => 'Email';

  @override
  String get userId => 'User ID';

  @override
  String get memberSince => 'Member since';

  @override
  String get profileNotAvailable => 'Profile not available';

  @override
  String get loginToViewProfile =>
      'Log in to view your profile and access additional features';

  @override
  String get login => 'Login';

  @override
  String get loginPrompt => 'Log in to continue';

  @override
  String get password => 'Password';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Sign up';

  @override
  String get createAccount => 'Create account';

  @override
  String get registration => 'Registration';

  @override
  String get createAccountToSaveFavorites =>
      'Create your account to save your favorite gas stations';

  @override
  String get emailAddress => 'Email address';

  @override
  String get minimumCharacters => 'Minimum 6 characters';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get registrationSuccess =>
      '✅ Thanks for signing up! We\'ve sent you an email to confirm your registration. Please check your inbox.';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';
}
