import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livelocation/mymap/bloc/mymap_event.dart';
import 'package:livelocation/mymap/bloc/mymap_state.dart';

class MyMapBloc extends Bloc<MyMapEvent, MyMapState> {
  MyMapBloc() : super(MyMapInitial());

  @override
  Stream<MyMapState> mapEventToState(MyMapEvent event) async* {
    if (event is AddMarkerEvent) {
      final newMarker = Marker(
        markerId: MarkerId(event.position.toString()),
        position: event.position,
      );
      final markers = (state is MarkersUpdated)
          ? (state as MarkersUpdated).markers.toSet()
          : Set<Marker>();
      markers.add(newMarker);
      yield MarkersUpdated(markers);
    }
  }
}
