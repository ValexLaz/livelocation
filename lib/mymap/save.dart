import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livelocation/mymap/bloc/mymap_bloc.dart';
import 'package:livelocation/mymap/bloc/mymap_event.dart';

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
      value: BlocProvider.of<MyMapBloc>(
          context), // Usa la instancia existente de MyMapBloc
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

      context.read<MyMapBloc>().add(MarkerAddedEvent(false));

    } else {
      print('No se pudo guardar la ubicación');
    }
  }
}
