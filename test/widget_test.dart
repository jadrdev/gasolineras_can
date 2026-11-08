import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolineras_can/core/location.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:gasolineras_can/features/favoritos/presentacion.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/gas_station_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'support/stations.dart';

class TestStationRepository extends GasStationRepository {
  @override
  Future<StationCatalog> fetchCatalog({bool forceRefresh = false}) async =>
      StationCatalog(sampleStations(), DateTime.now());
}

class TestFavorites extends FavoriteRepository {
  TestFavorites()
    : super(
        client: SupabaseClient(
          'https://example.supabase.co',
          'test-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );
  @override
  bool get isLoggedIn => false;
  final Stream<List<int>> _favorites = Stream.value(
    <int>[],
  ).asBroadcastStream();
  @override
  Stream<List<int>> favoritesStream() => _favorites;
}

class FailingFavorites extends TestFavorites {
  FailingFavorites() {
    cachedFavorites = [1];
  }
  @override
  bool get isLoggedIn => true;
  @override
  Stream<List<int>> favoritesStream() => const Stream.empty();
  @override
  Future<void> removeFavorite(int stationId) async =>
      throw Exception('offline');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<void> openList(
    WidgetTester tester, {
    bool located = false,
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: GasStationListPage(
          stationRepository: TestStationRepository(),
          favoriteRepository: TestFavorites(),
          locate: () async {
            if (!located) throw LocationPermissionException('denied');
            return Position(
              latitude: 28.48,
              longitude: -16.31,
              timestamp: DateTime.now(),
              accuracy: 10,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
          },
          loadProfile: () async => null,
          banner: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Search stays visible and editable after zero matches', (
    tester,
  ) async {
    await openList(tester);
    final search = find.byKey(const ValueKey('station-search'));
    await tester.enterText(search, 'no existe una estacion asi');
    await tester.pumpAndSettle();
    expect(find.text('No se han encontrado gasolineras'), findsOneWidget);
    expect(search, findsOneWidget);
    await tester.enterText(search, 'jose laguna');
    await tester.pumpAndSettle();
    expect(find.text('DISA SAN JOSÉ'), findsOneWidget);
    expect(find.text('No se han encontrado gasolineras'), findsNothing);
    await tester.tap(find.byTooltip('Borrar búsqueda'));
    await tester.pumpAndSettle();
    expect(find.text('REPSOL ARRECIFE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Manual municipality search works with GPS denied', (
    tester,
  ) async {
    await openList(tester);
    await tester.enterText(
      find.byKey(const ValueKey('station-search')),
      'arrecife',
    );
    await tester.pumpAndSettle();
    expect(find.text('REPSOL ARRECIFE'), findsOneWidget);
    expect(find.text('DISA SAN JOSÉ'), findsNothing);
    expect(find.text('1.509 €/L', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Typing finds stations outside the initial 16 km radius', (
    tester,
  ) async {
    await openList(tester, located: true);
    expect(find.text('DISA SAN JOSÉ'), findsOneWidget);
    expect(find.text('REPSOL ARRECIFE'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('station-search')),
      'repsol arrecife',
    );
    await tester.pumpAndSettle();
    expect(find.text('REPSOL ARRECIFE'), findsOneWidget);
    expect(find.text('Búsqueda por texto en toda Canarias'), findsOneWidget);
    await tester.tap(find.byTooltip('Borrar búsqueda'));
    await tester.pumpAndSettle();
    expect(find.text('DISA SAN JOSÉ'), findsOneWidget);
    expect(find.text('REPSOL ARRECIFE'), findsNothing);
  });

  testWidgets(
    'First launch does not request GPS permission before user action',
    (tester) async {
      var permissionRequests = 0;
      const channel = MethodChannel('flutter.baseflow.com/geolocator');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'checkPermission') return 0;
        if (call.method == 'requestPermission') {
          permissionRequests++;
          return 0;
        }
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: GasStationListPage(
            stationRepository: TestStationRepository(),
            favoriteRepository: TestFavorites(),
            loadProfile: () async => null,
            banner: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(permissionRequests, 0);
      expect(find.byTooltip('Usar mi ubicación'), findsOneWidget);
      expect(find.text('Toda Canarias').hitTestable(), findsOneWidget);
      expect(find.text('Cerca de mí · 16 km').hitTestable(), findsNothing);
      expect(find.byKey(const ValueKey('station-search')), findsOneWidget);
      expect(find.text('DISA SAN JOSÉ'), findsOneWidget);
    },
  );

  testWidgets(
    'Compact list remains usable on a narrow screen with large dark text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openList(tester, textScale: 1.6, brightness: Brightness.dark);
      expect(find.byKey(const ValueKey('station-search')), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.byKey(const ValueKey('station-search')),
        'arrecife',
      );
      await tester.pumpAndSettle();
      expect(find.text('75.45 € para 50 L · estimado'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Favorite delete failure restores star and explains failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavoriteWidget(
            station: sampleStations().first,
            repository: FailingFavorites(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quitar de favoritos'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('No se pudo actualizar el favorito'), findsOneWidget);
  });
}
