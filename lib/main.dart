import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snake_game_firebase/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "",
        appId: "",
        messagingSenderId: "",
        projectId: "",
        storageBucket: "",
        authDomain: "",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
    );
  }
}
