import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/features/gasolineras/models/gas_station.dart';
import 'package:gasolineras_can/features/gasolineras/data/gas_station_repository.dart';

// Eventos
abstract class GasStationEvent {}

class LoadStations extends GasStationEvent {
  final double lat;
  final double lng;
  LoadStations({required this.lat, required this.lng});
}

// Estados
abstract class GasStationState {}

class GasStationInitial extends GasStationState {}

class GasStationLoading extends GasStationState {}

class GasStationLoaded extends GasStationState {
  final List<GasStation> stations;
  GasStationLoaded(this.stations);
}

class GasStationError extends GasStationState {
  final String message;
  GasStationError(this.message);
}

class GasStationLoadError extends GasStationEvent {
  final String message;
  GasStationLoadError(this.message);
}

class LoadStationsWithDistance extends GasStationEvent {
  final List<GasStation> estaciones;
  LoadStationsWithDistance(this.estaciones);
}

// BLoC
class GasStationBloc extends Bloc<GasStationEvent, GasStationState> {
  final GasStationRepository repository;

  GasStationBloc(this.repository) : super(GasStationInitial()) {
    on<LoadStations>((event, emit) async {
      emit(GasStationLoading());
      try {
        final stations = await repository.fetchStations(event.lat, event.lng);

        // Calculamos distancia para cada estación
        for (var e in stations) {
          e.calcularDistancia(event.lat, event.lng);
        }

        emit(GasStationLoaded(stations));
      } catch (e) {
        emit(GasStationError(e.toString()));
      }
    });

    // Handler del nuevo evento
    on<LoadStationsWithDistance>((event, emit) {
      emit(GasStationLoaded(event.estaciones));
    });
  }
}

