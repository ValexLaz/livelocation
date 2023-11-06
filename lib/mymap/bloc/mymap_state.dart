import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MyMapState extends Equatable {
  const MyMapState();
}

class MyMapInitial extends MyMapState {
  @override
  List<Object> get props => [];
}

class MarkersUpdated extends MyMapState {
  final Set<Marker> markers;

  MarkersUpdated(this.markers);

  @override
  List<Object> get props => [markers];
}
