import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snake_game_firebase/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC_fvhRVku2Dl3eZakEZ6emiY7E21mjBHE",
        appId: "1:581643453965:web:9b39868ce72a1e7198b744",
        messagingSenderId: "581643453965",
        projectId: "snake-b4851",
        storageBucket: "snake-b4851.appspot.com",
        authDomain: "snake-b4851.firebaseapp.com",
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
