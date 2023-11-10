import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
class amigos extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('agrega a un amigo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
            "agrega a tus amigos",
            style: TextStyle(
              color: Colors.black,
              fontSize: 44.0,
              fontWeight: FontWeight.bold,
            ),
          ),
            TextField(
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed:(){
                _crearAmigo();
              },
              child: Text('Buscar Amigo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _crearAmigo {
}