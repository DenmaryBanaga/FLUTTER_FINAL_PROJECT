<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'adminhome.dart';
import 'adminAppointment.dart';
import 'adminRecords.dart';
import 'adminprofile.dart'; // ✅ Import your Admin Profile page

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  _AdminMainPageState createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboardPage(),
      const AdminMedicalRecordsPage(),
      AdminAppointmentPage(),
      const AdminProfileScreen(), // ✅ Correct widget class used here
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Admin Panel - Pediatric System')),
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
            label: "Dashboard",
            icon: Icon(Icons.dashboard),
          ),
          BottomNavigationBarItem(
            label: "Records",
            icon: Icon(Icons.folder_shared),
          ),
          BottomNavigationBarItem(
            label: "Appointments",
            icon: Icon(Icons.calendar_today),
          ),
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(Icons.admin_panel_settings),
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
=======
import 'package:flutter/material.dart';
import 'adminhome.dart';
import 'adminAppointment.dart';
import 'adminRecords.dart';
import 'adminprofile.dart'; // ✅ Import your Admin Profile page

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  _AdminMainPageState createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboardPage(),
      const AdminMedicalRecordsPage(),
      AdminAppointmentPage(),
      const AdminProfileScreen(), // ✅ Correct widget class used here
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Admin Panel - Pediatric System')),
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
            label: "Dashboard",
            icon: Icon(Icons.dashboard),
          ),
          BottomNavigationBarItem(
            label: "Records",
            icon: Icon(Icons.folder_shared),
          ),
          BottomNavigationBarItem(
            label: "Appointments",
            icon: Icon(Icons.calendar_today),
          ),
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(Icons.admin_panel_settings),
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
>>>>>>> 620764e6df497e63a84a668a58ae0571dc0913c9
