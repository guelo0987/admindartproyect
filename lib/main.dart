
import 'package:admindartproyect/views/main_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(AdminApp());

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: MyApp(),
    );
  }
}
