<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adminRecords.dart';
import 'adminAppointment.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<int> weeklyAppointments;
  late Future<int> todayAppointments;
  late Future<String> mostCommonReason;

  @override
  void initState() {
    super.initState();
    weeklyAppointments = fetchWeeklySuccessfulAppointments();
    todayAppointments = fetchTodaySuccessfulAppointments();
    mostCommonReason = fetchMostCommonReason();
  }

  Future<int> fetchWeeklySuccessfulAppointments() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'Successful')
          .get();

      int count = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['date'] != null) {
          String dateString = data['date'];
          try {
            DateTime date = DateTime.parse(dateString);
            if (date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
                date.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
              count++;
            }
          } catch (e) {
            print("Error parsing date string: $dateString. Error: $e");
          }
        }
      }
      return count;
    } catch (e) {
      print("Error fetching weekly appointments: $e");
      return 0;
    }
  }

  Future<int> fetchTodaySuccessfulAppointments() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'Successful')
          .get();

      int count = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['date'] != null) {
          String dateString = data['date'];
          try {
            DateTime date = DateTime.parse(dateString);
            if (date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                date.isBefore(endOfDay.add(const Duration(seconds: 1)))) {
              count++;
            }
          } catch (e) {
            print("Error parsing date string: $dateString. Error: $e");
          }
        }
      }
      return count;
    } catch (e) {
      print("Error fetching today appointments: $e");
      return 0;
    }
  }

  Future<String> fetchMostCommonReason() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'Successful')
          .get();

      Map<String, int> reasonCount = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['reason'] != null) {
          String reason = data['reason'];
          reasonCount[reason] = (reasonCount[reason] ?? 0) + 1;
        }
      }

      if (reasonCount.isEmpty) return "No data";

      var sortedReasons = reasonCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedReasons.first.key;
    } catch (e) {
      print("Error fetching most common reason: $e");
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.white.withOpacity(0.5)),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Admin Dashboard",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    // Weekly Appointments Card
                    FutureBuilder<int>(
                      future: weeklyAppointments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading data: ${snapshot.error}"));
                        }
                        int count = snapshot.data ?? 0;
                        return _buildSummaryCard("📅", "This Week's Successful Appointments", count.toString());
                      },
                    ),
                    const SizedBox(height: 20),

                    // Today's Appointments Card
                    FutureBuilder<int>(
                      future: todayAppointments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading data: ${snapshot.error}"));
                        }
                        int count = snapshot.data ?? 0;
                        return _buildSummaryCard("✅", "Today's Successful Appointments", count.toString());
                      },
                    ),
                    const SizedBox(height: 20),

                    // Most Common Reason Card
                    FutureBuilder<String>(
                      future: mostCommonReason,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading data: ${snapshot.error}"));
                        }
                        String reason = snapshot.data ?? "No data";
                        return _buildSummaryCard("💬", "Most Common Reason", reason);
                      },
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Quick Actions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today, color: Colors.white), // icon color white
                          label: const Text(
                            "View All Appointments",
                            style: TextStyle(color: Colors.white), // text color white
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdminAppointmentPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.folder_shared, color: Colors.white), // icon color white
                          label: const Text(
                            "Manage Medical Records",
                            style: TextStyle(color: Colors.white), // text color white
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminMedicalRecordsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String emoji, String label, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        width: 250,
        height: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                content,
                style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adminRecords.dart';
import 'adminAppointment.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<int> weeklyAppointments;
  late Future<int> todayAppointments;
  late Future<String> mostCommonReason;

  @override
  void initState() {
    super.initState();
    weeklyAppointments = fetchWeeklySuccessfulAppointments();
    todayAppointments = fetchTodaySuccessfulAppointments();
    mostCommonReason = fetchMostCommonReason();
  }

  Future<int> fetchWeeklySuccessfulAppointments() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'Successful')
          .get();

      int count = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['date'] != null) {
          String dateString = data['date'];
          try {
            DateTime date = DateTime.parse(dateString);
            if (date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
                date.isBefore(endOfWeek.add(const Duration(seconds: 1)))) {
              count++;
            }
          } catch (e) {
            print("Error parsing date string: $dateString. Error: $e");
          }
        }
      }
      return count;
    } catch (e) {
      print("Error fetching weekly appointments: $e");
      return 0;
    }
  }

  Future<int> fetchTodaySuccessfulAppointments() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'Successful')
          .get();

      int count = 0;
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['date'] != null) {
          String dateString = data['date'];
          try {
            DateTime date = DateTime.parse(dateString);
            if (date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                date.isBefore(endOfDay.add(const Duration(seconds: 1)))) {
              count++;
            }
          } catch (e) {
            print("Error parsing date string: $dateString. Error: $e");
          }
        }
      }
      return count;
    } catch (e) {
      print("Error fetching today appointments: $e");
      return 0;
    }
  }

  Future<String> fetchMostCommonReason() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'Successful')
          .get();

      Map<String, int> reasonCount = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['reason'] != null) {
          String reason = data['reason'];
          reasonCount[reason] = (reasonCount[reason] ?? 0) + 1;
        }
      }

      if (reasonCount.isEmpty) return "No data";

      var sortedReasons = reasonCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedReasons.first.key;
    } catch (e) {
      print("Error fetching most common reason: $e");
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.white.withOpacity(0.5)),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Admin Dashboard",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    // Weekly Appointments Card
                    FutureBuilder<int>(
                      future: weeklyAppointments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading data: ${snapshot.error}"));
                        }
                        int count = snapshot.data ?? 0;
                        return _buildSummaryCard("📅", "This Week's Successful Appointments", count.toString());
                      },
                    ),
                    const SizedBox(height: 20),

                    // Today's Appointments Card
                    FutureBuilder<int>(
                      future: todayAppointments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading data: ${snapshot.error}"));
                        }
                        int count = snapshot.data ?? 0;
                        return _buildSummaryCard("✅", "Today's Successful Appointments", count.toString());
                      },
                    ),
                    const SizedBox(height: 20),

                    // Most Common Reason Card
                    FutureBuilder<String>(
                      future: mostCommonReason,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading data: ${snapshot.error}"));
                        }
                        String reason = snapshot.data ?? "No data";
                        return _buildSummaryCard("💬", "Most Common Reason", reason);
                      },
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Quick Actions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today, color: Colors.white), // icon color white
                          label: const Text(
                            "View All Appointments",
                            style: TextStyle(color: Colors.white), // text color white
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdminAppointmentPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.folder_shared, color: Colors.white), // icon color white
                          label: const Text(
                            "Manage Medical Records",
                            style: TextStyle(color: Colors.white), // text color white
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminMedicalRecordsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String emoji, String label, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        width: 250,
        height: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                content,
                style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 620764e6df497e63a84a668a58ae0571dc0913c9
