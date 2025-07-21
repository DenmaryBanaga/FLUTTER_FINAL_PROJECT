<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  String filterReason = "All";
  Map<String, dynamic>? medicalData;
  List<Map<String, dynamic>> visitHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMedicalData();
    fetchVisitHistory();
  }

  Future<void> fetchMedicalData() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('medicalRecords')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          medicalData = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching medical data: $e");
    }
  }

  Future<void> fetchVisitHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Successful')
          .get();

      setState(() {
        visitHistory = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'reason': data['reason'],
            'date': data['date'],
            'status': data['status'],
            'timeSlot': data['timeSlot'],
          };
        }).toList();

        visitHistory.sort((a, b) {
          final dateA = DateTime.tryParse(a['date']) ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['date']) ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
      });
    } catch (e) {
      debugPrint("Error fetching visit history: $e");
    }
  }

  void showMedicalInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Patient Medical Information"),
        content: medicalData == null
            ? const Text("No data available.")
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👤 Name: ${medicalData!['patientName'] ?? 'Unknown'}"),
                  Text("💉 Blood Type: ${medicalData!['bloodType'] ?? 'N/A'}"),
                  Text("📏 Height: ${medicalData!['height'] ?? 'N/A'}"),
                  Text("⚖️ Weight: ${medicalData!['weight'] ?? 'N/A'}"),
                  Text("💊 Allergies: ${medicalData!['allergies'] ?? 'N/A'}"),
                  Text("🏥 Conditions: ${medicalData!['conditions'] ?? 'N/A'}"),
                ],
              ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (medicalData == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color:Colors.black),
      ),
        body: Center(child: Text("No medical record found for this user.")),
      );
    }

    final filteredVisits = filterReason == "All"
        ? visitHistory
        : visitHistory.where((v) => v['reason'] == filterReason).toList();

    final int totalSuccessfulVisits = visitHistory.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color:Colors.black),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
            children: [
              Center(
                child: Text(
                  "Medical Records",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: showMedicalInfo,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal[100],
                          child: const Icon(Icons.person, size: 40, color: Colors.teal),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicalData!['patientName'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text("Patient", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Contact Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("📍 Address: ${medicalData!['address'] ?? 'N/A'}"),
                      Text("📞 Phone: ${medicalData!['phone'] ?? 'N/A'}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text("Number of Visits"),
                  trailing: Text(
                    "$totalSuccessfulVisits",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("History of Visits", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: filterReason,
                    items: const ["All", "Check-up", "Consultation", "Vaccination", "Follow-up"]
                        .map((reason) => DropdownMenuItem(value: reason, child: Text(reason)))
                        .toList(),
                    onChanged: (value) => setState(() => filterReason = value!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...filteredVisits.map((visit) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.teal),
                      title: Text("${visit['reason']}"),
                      subtitle: Text("📅 ${visit['date']}\n🕒 ${visit['timeSlot']}"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Visit Details"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("📝 Reason: ${visit['reason']}"),
                                Text("📅 Date: ${visit['date']}"),
                                Text("🕒 Time: ${visit['timeSlot']}"),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Close"),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  String filterReason = "All";
  Map<String, dynamic>? medicalData;
  List<Map<String, dynamic>> visitHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMedicalData();
    fetchVisitHistory();
  }

  Future<void> fetchMedicalData() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('medicalRecords')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          medicalData = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching medical data: $e");
    }
  }

  Future<void> fetchVisitHistory() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'Successful')
          .get();

      setState(() {
        visitHistory = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'reason': data['reason'],
            'date': data['date'],
            'status': data['status'],
            'timeSlot': data['timeSlot'],
          };
        }).toList();

        visitHistory.sort((a, b) {
          final dateA = DateTime.tryParse(a['date']) ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['date']) ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
      });
    } catch (e) {
      debugPrint("Error fetching visit history: $e");
    }
  }

  void showMedicalInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Patient Medical Information"),
        content: medicalData == null
            ? const Text("No data available.")
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👤 Name: ${medicalData!['patientName'] ?? 'Unknown'}"),
                  Text("💉 Blood Type: ${medicalData!['bloodType'] ?? 'N/A'}"),
                  Text("📏 Height: ${medicalData!['height'] ?? 'N/A'}"),
                  Text("⚖️ Weight: ${medicalData!['weight'] ?? 'N/A'}"),
                  Text("💊 Allergies: ${medicalData!['allergies'] ?? 'N/A'}"),
                  Text("🏥 Conditions: ${medicalData!['conditions'] ?? 'N/A'}"),
                ],
              ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (medicalData == null) {
      return const Scaffold(
        body: Center(child: Text("No medical record found for this user.")),
      );
    }

    final filteredVisits = filterReason == "All"
        ? visitHistory
        : visitHistory.where((v) => v['reason'] == filterReason).toList();

    final int totalSuccessfulVisits = visitHistory.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
            children: [
              Center(
                child: Text(
                  "Medical Records",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: showMedicalInfo,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal[100],
                          child: const Icon(Icons.person, size: 40, color: Colors.teal),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicalData!['patientName'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text("Patient", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Contact Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("📍 Address: ${medicalData!['address'] ?? 'N/A'}"),
                      Text("📞 Phone: ${medicalData!['phone'] ?? 'N/A'}"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text("Number of Visits"),
                  trailing: Text(
                    "$totalSuccessfulVisits",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("History of Visits", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: filterReason,
                    items: const ["All", "Check-up", "Consultation", "Vaccination", "Follow-up"]
                        .map((reason) => DropdownMenuItem(value: reason, child: Text(reason)))
                        .toList(),
                    onChanged: (value) => setState(() => filterReason = value!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...filteredVisits.map((visit) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.teal),
                      title: Text("${visit['reason']}"),
                      subtitle: Text("📅 ${visit['date']}\n🕒 ${visit['timeSlot']}"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Visit Details"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("📝 Reason: ${visit['reason']}"),
                                Text("📅 Date: ${visit['date']}"),
                                Text("🕒 Time: ${visit['timeSlot']}"),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Close"),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
>>>>>>> 620764e6df497e63a84a668a58ae0571dc0913c9
