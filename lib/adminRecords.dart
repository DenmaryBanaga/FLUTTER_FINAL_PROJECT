import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMedicalRecordsPage extends StatefulWidget {
  const AdminMedicalRecordsPage({super.key});

  @override
  State<AdminMedicalRecordsPage> createState() => _AdminMedicalRecordsPageState();
}

class _AdminMedicalRecordsPageState extends State<AdminMedicalRecordsPage> {
  String searchQuery = "";
  String sortBy = "Name";

  void _showRecordDetails(Map<String, dynamic> record, String docId) {
    final nameController = TextEditingController(text: record['patientName']);
    final heightController = TextEditingController(text: record['height']);
    final weightController = TextEditingController(text: record['weight']);
    final allergiesController = TextEditingController(text: record['allergies']);
    final conditionsController = TextEditingController(text: record['conditions']);
    final addressController = TextEditingController(text: record['address']);
    final phoneController = TextEditingController(text: record['phone']);
    String selectedBloodType = record['bloodType'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit: ${record['patientName']}"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Patient Name")),
              DropdownButtonFormField<String>(
                value: selectedBloodType,
                decoration: const InputDecoration(labelText: "Blood Type"),
                items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedBloodType = value;
                },
              ),
              TextField(controller: heightController, decoration: const InputDecoration(labelText: "Height")),
              TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight")),
              TextField(controller: allergiesController, decoration: const InputDecoration(labelText: "Allergies")),
              TextField(controller: conditionsController, decoration: const InputDecoration(labelText: "Conditions")),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('medicalRecords').doc(docId).update({
                'patientName': nameController.text.trim(),
                'bloodType': selectedBloodType,
                'height': heightController.text.trim(),
                'weight': weightController.text.trim(),
                'allergies': allergiesController.text.trim(),
                'conditions': conditionsController.text.trim(),
                'address': addressController.text.trim(),
                'phone': phoneController.text.trim(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Medical record updated successfully")),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ extend behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // ✅ transparent app bar
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text("Admin: Medical Records"),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground Content with SafeArea
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sort Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: sortBy,
                    decoration: const InputDecoration(
                      labelText: "Sort By",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    items: ["Name", "Height", "Weight"]
                        .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => sortBy = value);
                    },
                  ),
                ),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name or email...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white70,
                    ),
                    onChanged: (value) => setState(() => searchQuery = value.trim().toLowerCase()),
                  ),
                ),
                // Records List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('medicalRecords')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                      List<Map<String, dynamic>> records = docs
                          .map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            data['docId'] = doc.id;
                            return data;
                          })
                          .where((record) =>
                              record['patientName'].toString().toLowerCase().contains(searchQuery) ||
                              record['email'].toString().toLowerCase().contains(searchQuery))
                          .toList();

                      // Sorting
                      if (sortBy == "Name") {
                        records.sort((a, b) => a['patientName'].compareTo(b['patientName']));
                      } else if (sortBy == "Height") {
                        records.sort((a, b) =>
                            int.tryParse(a['height'].toString())?.compareTo(int.tryParse(b['height'].toString()) ?? 0) ??
                            0);
                      } else if (sortBy == "Weight") {
                        records.sort((a, b) =>
                            int.tryParse(a['weight'].toString())?.compareTo(int.tryParse(b['weight'].toString()) ?? 0) ??
                            0);
                      }

                      if (records.isEmpty) {
                        return const Center(child: Text("No medical records found."));
                      }

                      return ListView.builder(
                        itemCount: records.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text("${record['patientName']} - ${record['bloodType']}"),
                              subtitle: Text("Phone: ${record['phone'] ?? 'N/A'}"),
                              onTap: () => _showRecordDetails(record, record['docId']),
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
        ],
      ),
    );
  }
}
