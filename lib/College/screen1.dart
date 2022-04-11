import 'package:flutter/material.dart';

class screenFlag1 extends StatefulWidget {
  const screenFlag1({Key? key}) : super(key: key);

  @override
  State<screenFlag1> createState() => _screenFlag1State();
}

class _screenFlag1State extends State<screenFlag1> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Container(child: Text('Hi'),),
    ),);
  }
}
