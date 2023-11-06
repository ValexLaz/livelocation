import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _markerAdded = false;
  LocationData? _currentLocation;
  Set<Marker> _markers = {}; 

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
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SaveLocationScreen(position: position),
              ),
            );
          },
        ),
      );
    });
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
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialPosition,
        markers: _markers, 
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        onLongPress: _addMarker,
        myLocationEnabled: true, // para mostrar el botón de la ubicación actual
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
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('locaciones').doc('user1').get();

  Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
  int counter = doc.exists && data?.containsKey('counter') == true ? (data?['counter'] ?? 0) : 0;  
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