import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livelocation/main.dart';

class SingUp extends StatefulWidget {
  const SingUp({Key? key}) : super(key: key);

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static Future<User?> registerUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        print("The account already exists for that email.");
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Live location",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Register to Live Location Mobile App",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 44.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 44.0),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email",
                  prefix: Icon(Icons.email, color: Colors.black),
                ),
              ),
              const SizedBox(height: 26.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password minimo 6 caracteres",
                  prefix: Icon(Icons.lock, color: Colors.black),
                ),
              ),
              const SizedBox(height: 88.0),
              Container(
                width: double.infinity,
                child: RawMaterialButton(
                  fillColor: const Color.fromARGB(255, 222, 155, 236),
                  elevation: 0.0,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  onPressed: () async {
                    User? user = await registerUsingEmailPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                        context: context);
                    print(user);
                    if (user != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyApp()));
                    } else {
                      print("Registration failed");
                    }
                  },
                  child: const Text("Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
