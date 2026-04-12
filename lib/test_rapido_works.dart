import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Text(
          'Rapido Works!',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
    ),
  ));
}
