import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: Icon(Icons.leave_bags_at_home)),
              IconButton(
              icon: Icon(Icons.account_circle), // замените на нужный вам логотип
      onPressed: () {},
    ),
        ],
        title: Text('TIA'),
      ),
    );
  }
}