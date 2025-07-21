import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookAppointmentPage extends StatefulWidget {
  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  String reason = '';
  DateTime? selectedDate;
  String? selectedTimeSlot;
  bool isLoading = true;
  String? appointmentDocId;
  String? bookedAppointment;
  bool showCancelledMessage = false;

  final Map<String, int> reasonDurations = {
    'Check-up': 60,
    'Vaccination': 20,
    'Follow-up': 30,
    'Consultation': 30,
    'Medical Certificate': 10,
  };

  final TimeOfDay clinicStart = TimeOfDay(hour: 8, minute: 0);
  final TimeOfDay clinicEnd = TimeOfDay(hour: 14, minute: 0);
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _checkExistingAppointment();
  }

  Future<void> _checkExistingAppointment() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'Pending') // ✅ Only block if Pending
        .limit(1)
        .get();

    if (!mounted) return;

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();

      setState(() {
        appointmentDocId = doc.id;
        bookedAppointment =
            "Reason: ${data['reason']}\nDate: ${DateTime.parse(data['date']).toLocal()}\nTime: ${data['timeSlot']}";
      });
    } else {
      setState(() {
        appointmentDocId = null;
        bookedAppointment = null;
        showCancelledMessage = false;
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedTimeSlot != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Appointment'),
          content: Text(
              'Book $reason on ${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year} at $selectedTimeSlot?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Book')),
          ],
        ),
      );

      if (confirm != true) return;

      int duration = reasonDurations[reason]!;

      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user!.uid,
        'reason': reason,
        'duration': duration,
        'date': selectedDate!.toIso8601String(),
        'timeSlot': selectedTimeSlot,
        'createdAt': Timestamp.now(),
        'status': 'Pending',
      });

      if (mounted) {
        setState(() {
          bookedAppointment = null;
          appointmentDocId = null;
          showCancelledMessage = false;
          isLoading = true;
        });
      }

      await _checkExistingAppointment();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Appointment booked!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please complete all fields")));
    }
  }

  Future<void> _cancelAppointment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Cancel Appointment"),
        content: Text("Are you sure?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("No")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Yes, Cancel"),
          )
        ],
      ),
    );

    if (confirm == true && appointmentDocId != null) {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentDocId)
          .delete();

      if (mounted) {
        setState(() {
          appointmentDocId = null;
          bookedAppointment = null;
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Appointment canceled")));
    }
  }

  List<String> get timeSlots {
    if (reason.isEmpty) return [];
    int duration = reasonDurations[reason]!;
    List<String> slots = [];
    TimeOfDay current = clinicStart;

    while (_timeOfDayToMinutes(current) + duration <=
        _timeOfDayToMinutes(clinicEnd)) {
      slots.add(_formatTime(current));
      current = _addMinutes(current, duration);
    }

    return slots;
  }

  int _timeOfDayToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _addMinutes(TimeOfDay t, int mins) {
    int total = _timeOfDayToMinutes(t) + mins;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 2)),
      firstDate: DateTime.now().add(Duration(days: 2)),
      lastDate: DateTime(2100),
      selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildTimeSlot(String time) {
    final isSelected = time == selectedTimeSlot;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimeSlot = time;
        });
      },
      child: Container(
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.teal.shade100,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? Colors.teal.shade700 : Colors.teal),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.teal[900],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
            extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Text(
                    "APPOINTMENTS",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 25),
                if (bookedAppointment != null)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Appointment",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text(bookedAppointment!),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _cancelAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Cancel Appointment",
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  ),
                if (bookedAppointment == null)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Reason for Visit",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: reason.isEmpty ? null : reason,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          hint: Text("Select Reason"),
                          items: reasonDurations.keys.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              reason = value!;
                              selectedTimeSlot = null;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a reason'
                              : null,
                        ),
                        SizedBox(height: 20),
                        Text("Choose a Date",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.teal),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate == null
                                      ? 'Tap to select date'
                                      : '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        if (reason.isNotEmpty) ...[
                          SizedBox(height: 20),
                          Text("Choose Time Slot",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            physics: NeverScrollableScrollPhysics(),
                            children: timeSlots.map(_buildTimeSlot).toList(),
                          ),
                        ],
                        SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Text("BOOK NOW",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 221, 226, 116),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ),
                      ],
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
