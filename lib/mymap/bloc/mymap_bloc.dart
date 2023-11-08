import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livelocation/mymap/bloc/mymap_event.dart';
import 'package:livelocation/mymap/bloc/mymap_state.dart';
import 'package:livelocation/mymap/ui/mymap.dart';

class MyMapBloc extends Bloc<MyMapEvent, MyMapState> {
  Set<Marker> markers = {};

  MyMapBloc() : super(MyMapInitial()) {
    on<AddMarkerEvent>(onAddMarker);
  }

  void onAddMarker(AddMarkerEvent event, Emitter<MyMapState> emit) async {
    final newMarker = Marker(
      markerId: MarkerId(event.position.toString()),
      position: event.position,
      onTap: () {
        // Navega a SaveLocationScreen cuando se presiona el marcador
        Navigator.push(
          event.context,
          MaterialPageRoute(
            builder: (context) => SaveLocationScreen(position: event.position),
          ),
        );
      },
    );
    markers.add(newMarker);
    emit(MarkersUpdated(markers));
  }
}
