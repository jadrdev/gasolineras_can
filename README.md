# gasolineras_can

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Google Maps API key (Android)

This project reads the Google Maps API key from Gradle manifest placeholders.
To provide your API key locally (do NOT commit it), add one of the following to
`android/local.properties` or `~/.gradle/gradle.properties`:

```
MAPS_API_KEY=YOUR_ACTUAL_API_KEY_HERE
```

After adding the key, rebuild the Android app:

```
flutter clean
flutter run
```

Make sure the key is enabled for Android Maps SDK in the Google Cloud Console
and restricted to your app's package name and SHA-1 for best security.
