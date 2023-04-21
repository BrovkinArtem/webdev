import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tiatia/utils/colors.dart';
import 'package:tiatia/pages/home.dart';
import 'package:tiatia/pages/home2.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCj6ymQTZE92t4jRlPK7RAUDJTOueuDKig", 
      appId: "1:810169758957:web:bfba0186943ec1505d48e4", 
      messagingSenderId: "810169758957", 
      projectId: "turtleinvestadvisor-65982"
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TIA',
      theme: ThemeData(
        fontFamily: 'Bitter',
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
      ),
      home: StreamBuilder(  
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Home2();
          } else {
            return Home();
          }
        }
      ),
    );
  }
}