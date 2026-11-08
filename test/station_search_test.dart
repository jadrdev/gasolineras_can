import 'package:flutter_test/flutter_test.dart';
import 'package:gasolineras_can/features/gasolineras/data/station_search.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'support/stations.dart';

void main() {
  final station = sampleStations().first;
  for (final query in [
    '  DISA  ',
    'san jose',
    'jose disa',
    'disa laguna',
    'álamos 10',
    'la cuesta',
    'cristobal',
    'SAN JOSE\u0301',
    'disa, san-josé',
  ]) {
    test(
      'Finds station with "$query"',
      () => expect(matchesStation(station, query), isTrue),
    );
  }
  test('Empty and whitespace searches show all stations', () {
    expect(matchesStation(station, ''), isTrue);
    expect(matchesStation(station, '   '), isTrue);
  });
  test(
    'All search words must match',
    () => expect(matchesStation(station, 'disa arrecife'), isFalse),
  );
  test('Parses decimal commas and keeps geographic search fields in cache', () {
    final parsed = GasStation.fromJson(station.toJson());
    expect(parsed.gasolina95, 1.459);
    expect(parsed.municipio, station.municipio);
    expect(matchesStation(parsed, 'cristobal cuesta'), isTrue);
  });
  test('Zero, invalid and negative prices are unavailable', () {
    final parsed = GasStation.fromJson({
      ...stationJson(),
      'Gasolina95': '0',
      'Diesel': -1,
      'Gasolina98': 'NaN',
    });
    expect(parsed.gasolina95, isNull);
    expect(parsed.diesel, isNull);
    expect(parsed.gasolina98, isNull);
  });
  test('Invalid coordinates do not become a station at 0,0', () {
    expect(
      () => GasStation.fromJson({...stationJson(), 'latitud': 'bad'}),
      throwsFormatException,
    );
  });
}
