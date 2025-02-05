import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Learflutter extends StatefulWidget {
  const Learflutter({super.key});

  @override
  State<Learflutter> createState() => _LearflutterState();
}

class _LearflutterState extends State<Learflutter> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      color: Color(0xFFFF0000),
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            'Hlw world',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
            width: 20,
          ),
          ElevatedButton(onPressed: () {}, child: Text('Click me'))
        ],
      ),
    ));
  }
}
