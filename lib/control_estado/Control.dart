import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:livelocation/Amigos/UI/amigos.dart';
import 'package:livelocation/LocationListScreen.dart';
import 'package:livelocation/mymap.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
// ignore: depend_on_referenced_packages

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: control()));
}

class control extends StatefulWidget {
  const control({Key? key}) : super(key: key);

  @override
  State<control> createState() => _ControlState();
}
class _ControlState extends  State<control>{
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _ControlSub;
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
        title: Text('Elige el estado de Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
          TextButton(
            onPressed: () {
              _listenLocation();
            },
            child: Text('enable location'),
          ),
          SizedBox(
            width: 85, // Ajusta el valor según la separación deseada
          ),
          TextButton(
            onPressed: () {
              _stopListening();
            },
            child: Text('stop location'),
          )
          ],
        ),
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
    _ControlSub = location.onLocationChanged.handleError((onError) {
      print(onError);
      _ControlSub?.cancel();
      setState(() {
        _ControlSub = null;
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
    _ControlSub?.cancel();
    setState(() {
      _ControlSub = null;
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
