import 'package:flutter/material.dart';
import 'guardian_registration_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pediatric Analysis System',
      debugShowCheckedModeBanner: false,
      initialRoute: '/register',
      routes: {
        '/register': (context) => GuardianRegistrationScreen(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
