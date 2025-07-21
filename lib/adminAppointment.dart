<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAppointmentPage extends StatefulWidget {
  @override
  State<AdminAppointmentPage> createState() => _AdminAppointmentPageState();
}

class _AdminAppointmentPageState extends State<AdminAppointmentPage> {
  String filterStatus = "Pending";

  Future<void> updateStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ extend body behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ transparent app bar
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text("Admin - Appointments"),
        actions: [
          DropdownButton<String>(
            value: filterStatus,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            dropdownColor: Colors.white,
            items: ["Pending", "Successful", "Canceled"]
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => setState(() => filterStatus = val!),
          ),
        ],
      ),
      body: Container(
        // ✅ removes default top padding to let background fill under app bar
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png', // replace with your actual path
                fit: BoxFit.cover,
              ),
            ),
            // Foreground Content with SafeArea to avoid status bar overlap
            SafeArea(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('status', isEqualTo: filterStatus)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No appointments found."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text("${data['reason']}"),
                          subtitle: Text(
                            "UserID: ${data['userId']}\n"
                            "Date: ${DateTime.parse(data['date']).toLocal()}\n"
                            "Time: ${data['timeSlot']}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (data['status'] == 'Pending')
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () => updateStatus(
                                      docs[index].id, 'Successful'),
                                ),
                              if (data['status'] != 'Canceled')
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () => updateStatus(
                                      docs[index].id, 'Canceled'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
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

class AdminAppointmentPage extends StatefulWidget {
  @override
  State<AdminAppointmentPage> createState() => _AdminAppointmentPageState();
}

class _AdminAppointmentPageState extends State<AdminAppointmentPage> {
  String filterStatus = "Pending";

  Future<void> updateStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ extend body behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ transparent app bar
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text("Admin - Appointments"),
        actions: [
          DropdownButton<String>(
            value: filterStatus,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
            dropdownColor: Colors.white,
            items: ["Pending", "Successful", "Canceled"]
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => setState(() => filterStatus = val!),
          ),
        ],
      ),
      body: Container(
        // ✅ removes default top padding to let background fill under app bar
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png', // replace with your actual path
                fit: BoxFit.cover,
              ),
            ),
            // Foreground Content with SafeArea to avoid status bar overlap
            SafeArea(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('status', isEqualTo: filterStatus)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No appointments found."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;
                      return Card(
                        color: Colors.white.withOpacity(0.9),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text("${data['reason']}"),
                          subtitle: Text(
                            "UserID: ${data['userId']}\n"
                            "Date: ${DateTime.parse(data['date']).toLocal()}\n"
                            "Time: ${data['timeSlot']}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (data['status'] == 'Pending')
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () => updateStatus(
                                      docs[index].id, 'Successful'),
                                ),
                              if (data['status'] != 'Canceled')
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () => updateStatus(
                                      docs[index].id, 'Canceled'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 620764e6df497e63a84a668a58ae0571dc0913c9
