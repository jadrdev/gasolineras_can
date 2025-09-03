import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DirectionsEvent extends Equatable {
  const DirectionsEvent();

  @override
  List<Object?> get props => [];
}

class GetRouteEvent extends DirectionsEvent {
  final LatLng origin;
  final LatLng destination;

  const GetRouteEvent(this.origin, this.destination);

  @override
  List<Object?> get props => [origin, destination];
}
