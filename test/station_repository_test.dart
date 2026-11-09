import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'support/stations.dart';

http.Response jsonResponse(
  String body,
  int status, {
  Map<String, String>? headers,
}) => http.Response.bytes(
  utf8.encode(body),
  status,
  headers: headers ?? {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'Full Canary catalog uses supported radius and limit without user GPS',
    () async {
      final repo = GasStationRepository(
        client: MockClient((request) async {
          expect(request.url.queryParameters['latitud'], '28.5');
          expect(request.url.queryParameters['longitud'], '-15.8');
          expect(request.url.queryParameters['radio'], '300');
          expect(request.url.queryParameters['limite'], '2000');
          expect(request.url.queryParameters['fields'], 'current');
          return jsonResponse(
            jsonEncode([stationJson()]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final catalog = await repo.fetchCatalog();
      expect(catalog.stations.single.nombre, 'Disa San José');
      expect(catalog.offline, isFalse);
    },
  );

  test(
    'Fresh cache avoids a second request; failed refresh keeps known prices',
    () async {
      var requests = 0;
      final repo = GasStationRepository(
        client: MockClient((_) async {
          requests++;
          if (requests > 1) throw http.ClientException('offline');
          return jsonResponse(jsonEncode([stationJson()]), 200);
        }),
      );
      final first = await repo.fetchCatalog();
      await repo.fetchCatalog();
      expect(requests, 1);
      final fallback = await repo.fetchCatalog(forceRefresh: true);
      expect(fallback.offline, isTrue);
      expect(fallback.fetchedAt, first.fetchedAt);
      expect(fallback.stations.single.gasolina95, 1.459);
    },
  );

  test(
    'An empty server response cannot overwrite an existing catalog',
    () async {
      var requests = 0;
      final repo = GasStationRepository(
        client: MockClient(
          (_) async => jsonResponse(
            jsonEncode(++requests == 1 ? [stationJson()] : []),
            200,
          ),
        ),
      );
      await repo.fetchCatalog();
      final catalog = await repo.fetchCatalog(forceRefresh: true);
      expect(catalog.offline, isTrue);
      expect(catalog.stations, hasLength(1));
    },
  );

  test(
    'Network error without cache is reported rather than an empty search',
    () async {
      final repo = GasStationRepository(
        client: MockClient((_) async => jsonResponse('Unavailable', 503)),
      );
      await expectLater(repo.fetchCatalog(), throwsException);
    },
  );

  test('A corrupt cache does not prevent a valid network load', () async {
    SharedPreferences.setMockInitialValues({
      'canaryStationCatalog.v1': '{invalid',
    });
    final repo = GasStationRepository(
      client: MockClient(
        (_) async => jsonResponse(jsonEncode([stationJson()]), 200),
      ),
    );
    expect((await repo.fetchCatalog()).stations, hasLength(1));
  });

  test('Deduplicates repeated station IDs', () async {
    final repo = GasStationRepository(
      client: MockClient(
        (_) async =>
            jsonResponse(jsonEncode([stationJson(), stationJson()]), 200),
      ),
    );
    expect((await repo.fetchCatalog()).stations, hasLength(1));
  });

  test(
    'Does not silently return a catalog truncated at the API limit',
    () async {
      final repo = GasStationRepository(
        client: MockClient(
          (_) async => jsonResponse(
            jsonEncode(List.generate(2000, (id) => stationJson(id: id))),
            200,
          ),
        ),
      );
      await expectLater(repo.fetchCatalog(), throwsFormatException);
    },
  );
}
