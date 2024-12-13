import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HotelDine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

      ),
      home: const signup(),
    );
  }
}
