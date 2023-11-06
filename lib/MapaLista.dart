import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaLista extends StatefulWidget {
  final LatLng initialPosition;

  MapaLista({required this.initialPosition});

  @override
  _MapaListaState createState() => _MapaListaState();
}

class _MapaListaState extends State<MapaLista> {
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialPosition = CameraPosition(
      target: widget.initialPosition,
      zoom: 14.0, 
    );
    return Scaffold(
    
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId(widget.initialPosition.toString()),
            position: widget.initialPosition,
          ),
        },
      ),
    );
  }
}