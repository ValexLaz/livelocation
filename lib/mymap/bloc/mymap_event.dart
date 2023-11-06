import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MyMapEvent extends Equatable {
  const MyMapEvent();
}

class AddMarkerEvent extends MyMapEvent {
  final LatLng position;

  AddMarkerEvent(this.position);

  @override
  List<Object> get props => [position];
}
