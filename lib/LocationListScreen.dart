import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livelocation/MapaLista.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Ubicaciones'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('guardados')
            .where('uid', isEqualTo: uid)
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

              String? title = data['name'];
              String? coordinates = '${data['latitude']},${data['longitude']}';

              if (title != null && coordinates != null) {
                List<String> latLng = coordinates.split(",");
                LatLng position =
                    LatLng(double.parse(latLng[0]), double.parse(latLng[1]));

                return Card(
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text('Coordenadas: $coordinates'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MapaLista(initialPosition: position),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container(); // Omitir elementos con datos faltantes
              }
            },
          );
        },
      ),
    );
  }
}
