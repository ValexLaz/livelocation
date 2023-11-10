import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:livelocation/mymap/bloc/mymap_bloc.dart';
import 'package:livelocation/mymap/bloc/mymap_event.dart';
import 'package:livelocation/mymap/bloc/mymap_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  Set<Marker> _markers = {}; // Define _markers
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _markerAdded = false;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _markerAdded=false;
  }

  _getCurrentLocation() async {
    final location = Location();
    try {
      final currentLocation = await location.getLocation();
      setState(() {
        _currentLocation = currentLocation;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _addMarker(LatLng position) {
    BlocProvider.of<MyMapBloc>(context).add(AddMarkerEvent(position, context));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return Center(child: CircularProgressIndicator());
    }

    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      ),
      zoom: 14.0,
    );

    return Scaffold(
      body: BlocConsumer<MyMapBloc, MyMapState>(
        listener: (context, state) {
          if (state is MarkersUpdated) {
            setState(() {
              _markers = state.markers;
            });
          }else if(state is MarkerAddedState){
            setState(() {
              _markerAdded = state.added;
            });
          }
        },
        builder: (context, state) {
          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            onLongPress: (LatLng position) {
              context.read<MyMapBloc>().add(AddMarkerEvent(position, context));
              setState(() {
                _markerAdded = true;
              });
            },
            markers: _markers, 
            myLocationEnabled:
                true, 
          );
        },
      ),
    );
  }
}

class SaveLocationScreen extends StatefulWidget {
  final LatLng position;

  SaveLocationScreen({required this.position});

  @override
  _SaveLocationScreenState createState() => _SaveLocationScreenState();
}

class _SaveLocationScreenState extends State<SaveLocationScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: BlocProvider.of<MyMapBloc>(context), // Usa la instancia existente de MyMapBloc
        child: Scaffold(
          appBar: AppBar(
            title: Text('Save Location'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                ElevatedButton(
                  child: Text('Save'),
                  onPressed: () {
                    _saveLocation(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

  void _saveLocation(BuildContext context) async {
    final position = widget.position;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      String coordinatesString = '${position.latitude},${position.longitude}';
      await FirebaseFirestore.instance.collection('guardados').add({
        'longitude': position.longitude.toString(),
        'latitude': position.latitude.toString(),
        'uid': uid,
        'name': _controller.text,
      });

      // Asegúrate de que `_markerAdded` se establece en false al guardar
      context.read<MyMapBloc>().add(MarkerAddedEvent(false));

      Navigator.pop(context); // Volver al mapa
    } else {
      print('No se pudo guardar la ubicación');
    }
  }
}
