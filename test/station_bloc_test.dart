import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolineras_can/features/gasolineras/BLoC/gas_station_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';
import 'support/stations.dart';

class ControlledRepository extends GasStationRepository {
  final pending = <Completer<StationCatalog>>[];
  @override
  Future<StationCatalog> fetchCatalog({bool forceRefresh = false}) {
    final request = Completer<StationCatalog>();
    pending.add(request);
    return request.future;
  }
}

void main() {
  test('An older request cannot replace a newer refresh', () async {
    final repo = ControlledRepository();
    final bloc = GasStationBloc(repo);
    final emitted = <GasStationLoaded>[];
    final subscription = bloc.stream.listen((state) {
      if (state is GasStationLoaded) emitted.add(state);
    });
    bloc.add(LoadStations());
    await Future<void>.delayed(Duration.zero);
    bloc.add(LoadStations(forceRefresh: true));
    await Future<void>.delayed(Duration.zero);
    repo.pending[1].complete(
      StationCatalog([sampleStations().last], DateTime.now()),
    );
    await Future<void>.delayed(Duration.zero);
    repo.pending[0].complete(
      StationCatalog([sampleStations().first], DateTime.now()),
    );
    await Future<void>.delayed(Duration.zero);
    expect(emitted, hasLength(1));
    expect(emitted.single.stations.single.id, 2);
    await subscription.cancel();
    await bloc.close();
  });

  test(
    'No GPS still produces searchable stations and offline metadata',
    () async {
      final repo = ControlledRepository();
      final bloc = GasStationBloc(repo);
      final loaded = bloc.stream.firstWhere(
        (state) => state is GasStationLoaded,
      );
      bloc.add(LoadStations());
      await Future<void>.delayed(Duration.zero);
      repo.pending.single.complete(
        StationCatalog(sampleStations(), DateTime(2026), offline: true),
      );
      final state = await loaded as GasStationLoaded;
      expect(state.stations, hasLength(2));
      expect(state.stations.first.distancia, isNull);
      expect(state.offline, isTrue);
      await bloc.close();
    },
  );
}
