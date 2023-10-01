import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_end/scrum_site.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 255, 157),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _signInGoogle(context);
                },
                child: const Text("Logga in med Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//skapar möjlighet för inloggning med google
_signInGoogle(BuildContext context) async {
  GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
        if(kIsWeb){Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Scrum_site(
            user: userCredential.user)));}
print(userCredential.user?.displayName);
    // ignore: unnecessary_null_comparison
    if (userCredential != null) {
      String userEmail = userCredential.user?.email ?? '';
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();
      if (snapshot.docs.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Scrum_site(
            user: userCredential.user, // Skicka användarobjektet till ScrumSite-widgeten
          ),
        ));
        print("Skickades utan att lägga till");
      } else {
        var new_user = <String, dynamic>{
          'Name': userCredential.user?.displayName,
          'email': userEmail,
        };
        await firestore.collection("users").add(new_user);
        print("Data har lagts till i Firestore");
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Scrum_site(
            user: userCredential.user, // Skicka användarobjektet till ScrumSite-widgeten
          ),
        ));
      }
    } else {
      print("Inloggning misslyckades");
    }
  } catch (e) {
    print("Inloggning misslyckades");
  }
}




