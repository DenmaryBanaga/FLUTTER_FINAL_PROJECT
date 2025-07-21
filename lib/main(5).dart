<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_application_2/home.dart';
import 'login_screen.dart';
import 'guardian_registration_screen.dart';
import 'dashboard.dart';

void main() {
  runApp(PediatricAnalysisApp());
}

class PediatricAnalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pediatric Analysis System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => GuardianRegistrationScreen(),
        '/dashboard': (context) => HomePage(),
      },
    );
  }
=======
import 'package:flutter/material.dart';
import 'package:flutter_application_2/home.dart';
import 'login_screen.dart';
import 'guardian_registration_screen.dart';
import 'dashboard.dart';

void main() {
  runApp(PediatricAnalysisApp());
}

class PediatricAnalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pediatric Analysis System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => GuardianRegistrationScreen(),
        '/dashboard': (context) => HomePage(),
      },
    );
  }
>>>>>>> 620764e6df497e63a84a668a58ae0571dc0913c9
}