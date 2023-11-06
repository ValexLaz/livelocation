import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:livelocation/LocationListScreen.dart';
import 'package:livelocation/mymap/ui/mymap.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: LocationScreen()));
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  loc.LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _getCurrentLocation(); // Obtener la ubicación actual al iniciar la pantalla
  }

  _getCurrentLocation() async {
    try {
      final currentLocation = await location.getLocation();
      setState(() {
        _currentLocation = currentLocation;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location App'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyMap(),
                ),
              );
            },
            child: Text('Ver mi ubicación en el mapa'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LocationListScreen(),
                ),
              );
            },
            child: Text('Ver lista de ubicaciones'),
          ),
          TextButton(
            onPressed: () {
              _getLocation();
            },
            child: Text('add my location'),
          ),
          TextButton(
            onPressed: () {
              _listenLocation();
            },
            child: Text('enable location'),
          ),
          TextButton(
            onPressed: () {
              _stopListening();
            },
            child: Text('stop location'),
          ),
          if (_currentLocation !=
              null) // Muestra las coordenadas si están disponibles
            Column(
              children: [
                Text("Latitud: ${_currentLocation!.latitude}"),
                Text("Longitud: ${_currentLocation!.longitude}"),
              ],
            ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('locaciones')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    String name = data.containsKey('name') ? data['name'].toString() : '';
                    String latitude = data.containsKey('latitude') ? data['latitude'].toString() : '';
                    String longitude = data.containsKey('longitude') ? data['longitude'].toString() : '';

                    return ListTile(
                      title: Text(name),
                      subtitle: Row(
                        children: [
                          Text(latitude),
                          Text(longitude),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.directions),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyMap(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
        
      ),
    );
  }

  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance
          .collection('locaciones')
          .doc('user1')
          .set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
        'name': 'josemaria',
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentLocation) async {
      await FirebaseFirestore.instance
          .collection('locaciones')
          .doc('user1')
          .set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'name': 'josemaria',
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
