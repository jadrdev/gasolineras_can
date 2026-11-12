import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/gas_station.dart';
import '../data/gas_station_repository.dart';
import '../../../l10n/l10n.dart';

abstract class GasStationEvent {}

class LoadStations extends GasStationEvent {
  final double? lat;
  final double? lng;
  final bool forceRefresh;
  LoadStations({this.lat, this.lng, this.forceRefresh = false});
}

abstract class GasStationState {}

class GasStationInitial extends GasStationState {}

class GasStationLoading extends GasStationState {}

class GasStationLoaded extends GasStationState {
  final List<GasStation> stations;
  final bool offline;
  final DateTime? fetchedAt;
  GasStationLoaded(this.stations, {this.offline = false, this.fetchedAt});
}

class GasStationError extends GasStationState {
  final String message;
  GasStationError(this.message);
}

class GasStationLoadError extends GasStationEvent {
  final String message;
  GasStationLoadError(this.message);
}

class GasStationBloc extends Bloc<GasStationEvent, GasStationState> {
  final GasStationRepository repository;
  int _generation = 0;
  GasStationBloc(this.repository) : super(GasStationInitial()) {
    on<LoadStations>((event, emit) async {
      final generation = ++_generation;
      emit(GasStationLoading());
      try {
        final catalog = await repository.fetchCatalog(
          forceRefresh: event.forceRefresh,
        );
        if (generation != _generation) return;
        for (final station in catalog.stations) {
          if (event.lat != null && event.lng != null) {
            station.calcularDistancia(event.lat!, event.lng!);
          } else {
            station.distancia = null;
          }
        }
        emit(
          GasStationLoaded(
            catalog.stations,
            offline: catalog.offline,
            fetchedAt: catalog.fetchedAt,
          ),
        );
      } catch (_) {
        if (generation == _generation) {
          emit(GasStationError(l10nSistema.stationLoadError));
        }
      }
    });
    on<GasStationLoadError>((event, emit) {
      _generation++;
      emit(GasStationError(event.message));
    });
  }
}
