import 'package:attendo/Pages/AttendanceLogs.dart';
import 'package:attendo/Pages/Search.dart';
import 'package:attendo/Pages/SignUpPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AttendanceLogs(),
    );
  }
}
