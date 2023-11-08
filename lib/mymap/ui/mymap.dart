import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:livelocation/mymap/bloc/mymap_bloc.dart'; // Asegúrate de importar tu BLoC aquí
import 'package:livelocation/mymap/bloc/mymap_event.dart'; // Asegúrate de importar tus eventos aquí
import 'package:livelocation/mymap/bloc/mymap_state.dart';

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
            // Actualiza los marcadores del mapa
            setState(() {
              _markers = state.markers;
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
              // Envía un AddMarkerEvent al BLoC cuando se presiona durante mucho tiempo en el mapa
              context.read<MyMapBloc>().add(AddMarkerEvent(position, context));
            },
            markers: _markers, // Usa los marcadores actualizados
            myLocationEnabled:
                true, // para mostrar el botón de la ubicación actual
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

  void _saveLocation() async {
    final position = widget.position;

    // Get the current document
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('locaciones')
        .doc('user1')
        .get();

    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    int counter = doc.exists && data?.containsKey('counter') == true
        ? (data?['counter'] ?? 0)
        : 0;
    counter++; // Increment the counter

    String nameKey = 'nombre$counter';
    String coordinatesKey = 'coordenadas$counter';

    String coordinatesString = '${position.latitude},${position.longitude}';

    FirebaseFirestore.instance.collection('locaciones').doc('user1').set({
      'counter': counter,
      nameKey: _controller.text,
      coordinatesKey: coordinatesString,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: _saveLocation,
            ),
          ],
        ),
      ),
    );
  }
}
