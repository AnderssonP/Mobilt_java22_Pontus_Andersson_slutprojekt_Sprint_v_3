import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_end/firebase_options.dart';
import './start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'scrumMaster',
      home: StartScreen(),
      theme: ThemeData(primarySwatch: Colors.brown),
    );
  }
}

