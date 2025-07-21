import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'records.dart';
import 'appointment.dart';
import 'login.dart';
import 'profile.dart'; // ✅ Ensure this file is named correctly

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCDB7iavXzVsE7058vh39ekNWpw1royIws",
      authDomain: "pediatric-4957d.firebaseapp.com",
      projectId: "pediatric-4957d",
      storageBucket: "pediatric-4957d.firebasestorage.app",
      messagingSenderId: "704016901012",
      appId: "1:704016901012:web:a6d5aa6df7221225926581",
      measurementId: "G-LZWLMXL3C5"
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pediatric Analysis System",
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color.fromARGB(255, 68, 182, 231),
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 235, 198),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const LoginPage(), // You can replace with MyHomePage() after login
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const MedicalRecordsPage(),
      BookAppointmentPage(),
      const ProfileScreen(), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Pediatric Analysis System')),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromRGBO(240, 235, 198, 1),
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Records",
            icon: Icon(Icons.folder),
          ),
          BottomNavigationBarItem(
            label: "Appointment",
            icon: Icon(Icons.date_range),
          ),
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(Icons.person),
          ),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
