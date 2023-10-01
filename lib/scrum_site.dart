import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_end/create.dart';
import 'package:project_end/main.dart';
import 'package:project_end/start_screen.dart';

class Scrum_site extends StatefulWidget {
  @override
  _Scrum_siteState createState() => _Scrum_siteState();
  final User? user;
  Scrum_site({required this.user});
}

class _Scrum_siteState extends State<Scrum_site> {
  int Total = 0;
  int hourPay = 0;
  String name = "";
  String namnUppgift = "";
  String uppgift="";
  int timJobbade = 0;
  bool done = false;
  List<Map<String, dynamic>> taskData = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot? querySnapshot;

  void initState(){
    super.initState();
    fetchData();
   _displayWork();
   _updateTotal();
  }

//bytar till min create site
  void _changeSite() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Create(
                  user: widget.user,
                )));
  }

  // hämta data om projekt
  Future<void> fetchData() async {
    QuerySnapshot querySnapshot = await firestore
        .collection("users")
        .where("email", isEqualTo: widget.user?.email)
        .get();

    String userId = querySnapshot.docs[0].id;
    try {
      QuerySnapshot qSnap = await firestore
          .collection("users")
          .doc(userId)
          .collection("project")
          .get();

      if (qSnap.docs.isNotEmpty) {
        String projectName = qSnap.docs.isNotEmpty
            ? (qSnap.docs[0].data() as Map<String, dynamic>)["Projekt_namn"]
            : null;
        int totalInc = qSnap.docs.isNotEmpty
            ? (qSnap.docs[0].data() as Map<String, dynamic>)["total"]
            : null;
        int Pay = qSnap.docs.isNotEmpty ? (qSnap.docs[0].data() as Map<String, dynamic>)["tim_pris"] : null;   
        setState(() {
          name = projectName;
          Total = totalInc;
          hourPay = Pay;
        });
      }
    } catch (e) {
      print("Fail");
    }
  }
  
  //lägg till arbetsuppgifter
  void _addWork() {
    print("Addwork is called");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Lägg till arbete"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Namn på uppgift"),
                onChanged: (value) {
                  setState(() {
                    namnUppgift = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "beskrivning"),
                onChanged: (value) {
                  setState(() {
                    uppgift = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Avbryt"),
            ),
            TextButton(
              onPressed: () {
                _sendToDB(namnUppgift,uppgift, timJobbade, done, widget.user);
                print("Uppgift: $uppgift, Timmar jobbade: $timJobbade");
                Navigator.of(context).pop();
              },
              child: Text("Lägg till"),
            ),
          ],
        );
      },
    );
  }

  // visa arbetsuppgifterna
  void _displayWork() async {
  QuerySnapshot userSnapshot = await firestore
      .collection("users")
      .where("email", isEqualTo: widget.user?.email)
      .get();

  String userId = userSnapshot.docs[0].id;

  QuerySnapshot projectSnapshot = await firestore
      .collection("users")
      .doc(userId)
      .collection("project")
      .get();

  String projectId = projectSnapshot.docs[0].id;

  QuerySnapshot taskSnapshot = await firestore
      .collection("users")
      .doc(userId)
      .collection("project")
      .doc(projectId)
      .collection("ArbetsUppgifter")
      .get();

  for(int i = 0; i< taskSnapshot.docs.length; i++){
    QueryDocumentSnapshot document = taskSnapshot.docs[i];
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    setState(() {
      taskData.add({
        'Uppgift': data['Arbete'],
        'beskrivning': data['Beskrivning'],
        'Klar': data['Klar'],
        'timmar': data['Tim_jobbade']
      });
    });
  }
}

  // Uppdatera totala
  void _updateTotal() async{
    QuerySnapshot userSnapshot = await firestore
      .collection("users")
      .where("email", isEqualTo: widget.user?.email).get();

  String userId = userSnapshot.docs[0].id;

  QuerySnapshot projectSnapshot = await firestore
      .collection("users")
      .doc(userId)
      .collection("project")
      .get();

  String projectId = projectSnapshot.docs[0].id;

  QuerySnapshot taskSnapshot = await firestore
      .collection("users")
      .doc(userId)
      .collection("project")
      .doc(projectId)
      .collection("ArbetsUppgifter")
      .get();

  int totalHoursWorked = 0;

  // Loopa igenom arbetsuppgifter och beräkna totala arbetade timmar
  taskSnapshot.docs.forEach((taskDoc) {
    int hoursWorked = (taskDoc.data() as Map<String, dynamic>)['Tim_jobbade'];
    totalHoursWorked += hoursWorked;
    print(hoursWorked);
  });

  // Beräkna total kostnad
  int totalCost = totalHoursWorked * hourPay;

  // Uppdatera total i "project" -dokumentet
  await firestore
      .collection("users")
      .doc(userId)
      .collection("project")
      .doc(projectId)
      .update({"total": totalCost});
}

  Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => StartScreen()));
}
 
  void _addHours() async{
    // to be added
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color.fromARGB(255, 235, 255, 157),
    body: Stack(
      children: [
        Positioned(top: 25.0,
          left: 5.0, 
          child: ElevatedButton(
            onPressed: () { 
              _signOut();
             },
          child: Icon(Icons.logout))),
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Projektnamn: ${name}",
                  style: TextStyle(fontSize: 24),
                ),
                Text("Välkommen ${widget.user?.displayName} "),
                Text(
                  "Totala inkomsten: $Total kr ",
                  style: TextStyle(fontSize: 15),
                ),
                Text("Kostnad i timmen: ${hourPay}", style: TextStyle(fontSize: 15)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _changeSite();
                      },
                      child: Text("Starta projekt"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 150.0,
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
          child: ListView.builder(
            itemCount: taskData.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.brown,
                elevation: 9.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text("Arbetsuppgift: ${taskData[index]['Uppgift']}",style: TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Beskrivning: ${taskData[index]['beskrivning']}",style: TextStyle(color: Colors.white)),
                      Text("Timmar: ${taskData[index]['timmar']}",style: TextStyle(color: Colors.white)),
                      ElevatedButton(onPressed: (){
                        _addHours();
                      }, child: Icon(Icons.auto_fix_normal))
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: ElevatedButton(
            onPressed: () {
              _addWork();
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    ),
  );
}
}


void _sendToDB(String work,String workDescription, int hours, bool done, User? user) async {
  var sendInfo = {
    "Arbete": work,
    "Beskrivning": workDescription,
    "Tim_jobbade": hours,
    "Klar": done,
  };

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot querySnapshot = await firestore
      .collection("users")
      .where("email", isEqualTo: user?.email)
      .get();

  String userId = querySnapshot.docs[0].id;

  QuerySnapshot qSnap = await firestore
      .collection("users")
      .doc(userId)
      .collection("project")
      .get();

  String projectId = qSnap.docs[0].id;

  DocumentReference projectRef = firestore
      .collection("users")
      .doc(userId)
      .collection("project")
      .doc(projectId);

  await projectRef.collection("ArbetsUppgifter").add(sendInfo);
}




