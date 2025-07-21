<<<<<<< HEAD
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'records.dart';
import 'appointment.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool hasNotification = false;
  String userId = '';
  int totalVisits = 0;
  late AnimationController _controller;
  StreamSubscription? visitSubscription;

  final List<Map<String, String>> visitTypes = [
    {
      'title': 'Check-Up',
      'description': 'Routine physical exams to monitor your child’s health.',
      'price': '₱300.00'
    },
    {
      'title': 'Vaccination',
      'description': 'Common vaccines: MMR, Polio, Hepatitis B, Flu.',
      'price': '₱1,200.00'
    },
    {
      'title': 'Consultation',
      'description': 'Medical advice sessions tailored to your concerns.',
      'price': '₱500.00'
    },
    {
      'title': 'Follow-Up',
      'description': 'Post-treatment check-ins and progress reviews.',
      'price': '₱400.00'
    },
    {
      'title': 'Medical Certificate',
      'description': 'Issuance of valid documents for school or travel.',
      'price': '₱150.00'
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkNotification();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _fetchVisitCount();
  }

  @override
  void dispose() {
    _controller.dispose();
    visitSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkNotification() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    userId = currentUser.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists && doc.data()?['hasNotification'] == true) {
      setState(() {
        hasNotification = true;
      });
    }
  }

  Future<void> _dismissNotification() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'hasNotification': false});

    setState(() {
      hasNotification = false;
    });
  }

  void _fetchVisitCount() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    userId = currentUser.uid;

    visitSubscription = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'Successful')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        totalVisits = snapshot.docs.length;
      });
    }, onError: (e) {
      print("Error fetching visits: $e");
    });
  }

  void _showRecentVisitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Recent Visit", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Most recent visit details will be shown here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MedicalRecordsPage()),
                  );
                },
            child: const Text("View Records", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                if (hasNotification)
                  Container(
                    width: double.infinity,
                    color: Colors.red[100]?.withOpacity(0.9),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.red),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Your appointment has been canceled by the clinic.",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _dismissNotification,
                        )
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Hello, Guardian 👋',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _showRecentVisitDialog,
                  child: Card(
                    color: Colors.lightBlueAccent,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: Tween(begin: 1.0, end: 1.2).animate(
                              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                            ),
                            child: const Icon(Icons.star, color: Colors.yellowAccent, size: 30),
                          ),
                          const SizedBox(height: 8),
                          Text('$totalVisits',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Text('Total Visits',
                              style: TextStyle(fontSize: 14, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Visit Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 10),
                ...visitTypes.map(
                  (type) => Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(type['description']!, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Price: ${type['price']}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BookAppointmentPage()),
                                );
                              },
                              child: const Text(
                                'Book Appointment',
                                style: TextStyle(color: Colors.white), // ✅ text color set to white
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const ListTile(
                    leading: CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/images/doctor.jpg')),
                    title: Text("Dr. Myra Castillo", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Attending Pediatrician"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
=======
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your AppointmentPage here
import 'appointment.dart'; // Adjust path if under different folder

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool hasNotification = false;
  String userId = '';
  int totalVisits = 0;
  late AnimationController _controller;
  StreamSubscription? visitSubscription;

  final List<Map<String, String>> visitTypes = [
    {
      'title': 'Check-Up',
      'description': 'Routine physical exams to monitor your child’s health.',
      'price': '₱300.00'
    },
    {
      'title': 'Vaccination',
      'description': 'Common vaccines: MMR, Polio, Hepatitis B, Flu.',
      'price': '₱1,200.00'
    },
    {
      'title': 'Consultation',
      'description': 'Medical advice sessions tailored to your concerns.',
      'price': '₱500.00'
    },
    {
      'title': 'Follow-Up',
      'description': 'Post-treatment check-ins and progress reviews.',
      'price': '₱400.00'
    },
    {
      'title': 'Medical Certificate',
      'description': 'Issuance of valid documents for school or travel.',
      'price': '₱150.00'
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkNotification();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _fetchVisitCount();
  }

  @override
  void dispose() {
    _controller.dispose();
    visitSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkNotification() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    userId = currentUser.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (doc.exists && doc.data()?['hasNotification'] == true) {
      setState(() {
        hasNotification = true;
      });
    }
  }

  Future<void> _dismissNotification() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'hasNotification': false});

    setState(() {
      hasNotification = false;
    });
  }

  void _fetchVisitCount() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    userId = currentUser.uid;

    visitSubscription = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'Successful')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        totalVisits = snapshot.docs.length;
      });
    }, onError: (e) {
      print("Error fetching visits: $e");
    });
  }

  void _showRecentVisitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Recent Visit", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Most recent visit details will be shown here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to records screen if available
            },
            child: const Text("View Records", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                if (hasNotification)
                  Container(
                    width: double.infinity,
                    color: Colors.red[100]?.withOpacity(0.9),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, color: Colors.red),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Your appointment has been canceled by the clinic.",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _dismissNotification,
                        )
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Hello, Guardian 👋',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _showRecentVisitDialog,
                  child: Card(
                    color: Colors.lightBlueAccent,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: Tween(begin: 1.0, end: 1.2).animate(
                              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                            ),
                            child: const Icon(Icons.star, color: Colors.yellowAccent, size: 30),
                          ),
                          const SizedBox(height: 8),
                          Text('$totalVisits',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Text('Total Visits',
                              style: TextStyle(fontSize: 14, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Visit Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 10),
                ...visitTypes.map(
                  (type) => Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(type['description']!, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Price: ${type['price']}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BookAppointmentPage()),
                                );
                              },
                              child: const Text(
                                'Book Appointment',
                                style: TextStyle(color: Colors.white), // ✅ text color set to white
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  color: Colors.white.withOpacity(0.9),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const ListTile(
                    leading: CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/images/doctor.jpg')),
                    title: Text("Dr. Myra Castillo", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Attending Pediatrician"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
>>>>>>> 620764e6df497e63a84a668a58ae0571dc0913c9
