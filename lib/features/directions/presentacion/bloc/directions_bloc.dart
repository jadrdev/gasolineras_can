import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasolineras_can/features/directions/domain/directions_repository.dart';


import 'directions_event.dart';
import 'directions_state.dart';


class DirectionsBloc extends Bloc<DirectionsEvent, DirectionsState> {
  final DirectionsRepository repository;

  DirectionsBloc(this.repository) : super(DirectionsInitial()) {
    on<GetRouteEvent>(_onGetRoute);
  }

  Future<void> _onGetRoute(
    GetRouteEvent event,
    Emitter<DirectionsState> emit,
  ) async {
    emit(DirectionsLoading());
    try {
      final points = await repository.getRoute(event.origin, event.destination);
      emit(DirectionsLoaded(points));
    } catch (e) {
      emit(DirectionsError(e.toString()));
    }
  }
}
