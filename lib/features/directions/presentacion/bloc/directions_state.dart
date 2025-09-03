import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DirectionsState extends Equatable {
  const DirectionsState();

  @override
  List<Object?> get props => [];
}

class DirectionsInitial extends DirectionsState {}

class DirectionsLoading extends DirectionsState {}

class DirectionsLoaded extends DirectionsState {
  final List<LatLng> points;

  const DirectionsLoaded(this.points);

  @override
  List<Object?> get props => [points];
}

class DirectionsError extends DirectionsState {
  final String message;

  const DirectionsError(this.message);

  @override
  List<Object?> get props => [message];
}
