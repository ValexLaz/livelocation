import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livelocation/MapaLista.dart';

class LocationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Ubicaciones'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('locaciones').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              List<Widget> cards = [];
              int counter = 1;
              while (true) {
                String nameKey = 'nombre$counter';
                String coordinatesKey = 'coordenadas$counter';
                if (!data.containsKey(nameKey) || !data.containsKey(coordinatesKey)) {
                  break;
                }

                String title = data[nameKey].toString();
                String coordinates = data[coordinatesKey].toString();
                List<String> latLng = coordinates.split(",");
                LatLng position = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));

                cards.add(Card(
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text('Coordenadas: $coordinates'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapaLista(initialPosition: position),
                        ),
                      );
                    },
                  ),
                ));

                counter++;
              }

              return Column(children: cards);
            },
          );
        },
      ),
    );
  }
}