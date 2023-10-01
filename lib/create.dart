import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_end/scrum_site.dart';


class Create extends StatefulWidget {
  @override
  _Create createState() => _Create();
  final User? user; 
  Create({required this.user});
}

class _Create extends State<Create> {

  DateTime _dateTime = DateTime.now();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


// hämta datum samt setstate för att sätta ett slutdatum
void _showDatePicker(){
  showDatePicker(
    context: context, 
    initialDate: DateTime.now(), 
    firstDate: DateTime(2000), 
    lastDate: DateTime(3000)
    ).then((value){
      setState(() {
        _dateTime = value!;
      });
    });
}

//avbryt och gå tillbaka
Future<void> _cancel() async {
  Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Scrum_site(user: widget.user)));
}
// skapa projekt och skicka in till firestore
Future<void> _createScrum() async {
  String projectName = titleController.text;
  String priceText = descriptionController.text;
  int? price = int.tryParse(priceText);

  var userProjectData = {
    "Projekt_namn": projectName,
    "tim_pris": price,
    "slut_datum": _dateTime,
    "total": 0
  };

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot querySnapshot = await firestore
      .collection("users")
      .where("email", isEqualTo: widget.user?.email)
      .get();

  String userId = querySnapshot.docs[0].id;
  DocumentReference userDocument = firestore.collection("users").doc(userId);
  CollectionReference projectCollection = userDocument.collection("project");

  projectCollection.add(userProjectData).then((value) {
    print("Projektdatan har lagts till i Firestore med ID: ${value.id}");
  }).catchError((error) {
    print("Ett fel inträffade: $error");
  });
  Navigator.push(context, MaterialPageRoute(builder: (context) => Scrum_site(
      user: widget.user,
    )));

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 255, 157),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Skapa projekt",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 150.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Namn på projekt:"),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Ange titel här",
                  ),
                ),
                SizedBox(height: 16.0),
                Text("Timpris:"),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: "Ange timpris här",
                  ),
                ),
                MaterialButton(
                  onPressed: _showDatePicker, 
                  child: 
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Välj slutdatum"),
                  ),
                                    ),
                  Text("Valt datum: "+_dateTime.year.toString()+"-"+_dateTime.month.toString() + "-" + _dateTime.day.toString()),
                MaterialButton(
                    onPressed: _createScrum, 
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Skapa projekt"),
                    ),
                  ),
                MaterialButton(
                  onPressed: _cancel,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Avbryt"),
                  ), 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
