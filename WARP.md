# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Gasolineras de Canarias is a Flutter mobile application that helps users find gas stations in the Canary Islands. The app displays gas stations sorted by price or distance, integrates with Firebase for authentication, and uses Google Maps for location services.

## Development Commands

### Setup and Dependencies
```bash
# Get Flutter dependencies
flutter pub get

# Clean and rebuild (when having dependency issues)
flutter clean && flutter pub get

# Update iOS CocoaPods dependencies (if needed)
cd ios && pod update Firebase/Messaging && cd ..
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run with specific flavor/environment
flutter run --debug
flutter run --release

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### Testing and Quality
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analyze code for linting issues
flutter analyze

# Format code
flutter format .
```

### Building
```bash
# Build APK for Android
flutter build apk

# Build iOS (requires Xcode)
flutter build ios

# Build for web
flutter build web
```

## Architecture Overview

This Flutter app follows a **Clean Architecture** pattern with **BLoC** state management:

### Feature-Based Structure
- `lib/features/` - Contains domain-specific features (auth, gasolineras, favoritos, directions)
- Each feature follows Clean Architecture layers:
  - `domain/` - Business logic and entities
  - `data/` - Repositories and data sources
  - `presentacion/` - UI components and BLoC presentation layer

### Core Components
- `lib/core/` - Shared utilities and services
  - `config.dart` - App configuration (API keys from .env)
  - `location.dart` - Location services
  - `directions_service.dart` - Google Maps integration

### State Management (BLoC Pattern)
- Uses `flutter_bloc` for state management
- Each feature has its own BLoC (AuthBloc, GasStationBloc)
- BLoCs handle events and emit states
- UI components use `BlocBuilder` and `BlocProvider`

### Key Dependencies
- **Firebase**: Authentication, Firestore, Cloud Messaging
- **Google Maps**: `google_maps_flutter` for map display
- **Navigation**: `go_router` with auth-based routing
- **Local Storage**: `shared_preferences` for user preferences
- **HTTP**: For API calls to gas station data
- **Location**: `geolocator` for user location

### Authentication Flow
- Firebase Authentication with email/password
- `AuthBloc` manages auth state globally
- Router redirects based on authentication status
- Login screen → Home screen flow

### Data Architecture
- **Repository Pattern**: Each feature has repositories for data access
- **Mock/Real Data Toggle**: Use `useMock` flag in `GasStationListPage` to switch between mock and real API data
- **Favorites**: Local storage with stream-based updates

## Environment Configuration

### Required Environment Variables
Create a `.env` file based on `.env.example`:
```
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

### Firebase Setup
- Firebase project: `gasolineras-can`
- Configured for Android and iOS platforms
- `firebase_options.dart` contains platform-specific configuration

## Key Features Implementation

### Gas Station List
- Fetches stations based on user location
- Sortable by price or distance (preference stored locally)
- Pull-to-refresh functionality
- Favorites management with real-time updates

### Location Services
- Uses `geolocator` for current position
- Calculates distance to gas stations
- Handles location permissions

### Mock vs Real Data
- Development toggle in `GasStationListPage` (`useMock` constant)
- Mock data for directions service
- Real API integration for gas station data

## Development Notes

### BLoC Events and States
 - Events trigger state changes (`AuthLoggedIn`, `LoadStations`)
- States represent UI state (`AuthInitial`, `GasStationLoaded`)
- Use `BlocBuilder` for reactive UI updates

### Navigation
- `go_router` with auth-aware routing
- Routes: `/login` and `/home`
- Automatic redirection based on auth state

### Error Handling
- BLoC states include error states
- UI shows retry buttons for failed operations
- Location permission handling

### Testing
- Uses `bloc_test` for BLoC unit testing
- `mockito` for mocking dependencies
- Widget tests in `test/` directory
