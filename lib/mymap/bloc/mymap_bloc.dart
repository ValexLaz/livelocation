import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livelocation/mymap/bloc/mymap_event.dart';
import 'package:livelocation/mymap/bloc/mymap_state.dart';
import 'package:livelocation/mymap/ui/mymap.dart';

class MyMapBloc extends Bloc<MyMapEvent, MyMapState> {
  Set<Marker> markers = {};
  bool _markerAdded = false; // Agrega esta línea

  MyMapBloc() : super(MyMapInitial()) {
    on<AddMarkerEvent>(onAddMarker);
    on<ClearMarkersEvent>(onClearMarkers);
    on<MarkerAddedEvent>(onMarkerAdded); // Agrega esta línea
  }

  void onAddMarker(AddMarkerEvent event, Emitter<MyMapState> emit) async {
    markers.clear();
    _markerAdded = true;
    final newMarker = Marker(
      markerId: MarkerId(event.position.toString()),
      position: event.position,
      onTap: () {
        Navigator.push(
          event.context,
          MaterialPageRoute(
            builder: (context) => SaveLocationScreen(position: event.position),
          ),
        );
      },
    );
    markers.add(newMarker);
    emit(MarkersUpdated(markers, _markerAdded));
  }

  void onClearMarkers(ClearMarkersEvent event, Emitter<MyMapState> emit) async {
    markers.clear();
    emit(MarkersUpdated(markers, _markerAdded));
  }

  // Agrega esta función
  void onMarkerAdded(MarkerAddedEvent event, Emitter<MyMapState> emit) {
    _markerAdded = event.added;
    emit(MarkerAddedState(_markerAdded));
  }
}
