import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String guardianName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();

    fetchGuardianName(); // Fetch name from Firestore on load
  }

  Future<void> fetchGuardianName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users') // your main collection
            .doc(user.uid) // get the document with the user's UID
            .get();

        if (snapshot.exists) {
          setState(() {
            guardianName = snapshot.data()?['username'] ?? 'No Username';
          });
        } else {
          setState(() {
            guardianName = 'No User Found';
          });
        }
      }
    } catch (e) {
      setState(() {
        guardianName = 'Error loading name';
      });
      print('Error fetching guardian name: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddChildForm() {
    final _formKey = GlobalKey<FormState>();
    String name = '', age = '', address = '', height = '', weight = '', bloodType = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Child Information'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Name', (val) => name = val),
                _buildTextField('Age', (val) => age = val),
                _buildTextField('Address', (val) => address = val),
                _buildTextField('Height', (val) => height = val),
                _buildTextField('Weight', (val) => weight = val),
                _buildTextField('Blood Type', (val) => bloodType = val),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Child $name added successfully!')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
        onChanged: onSaved,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  ListTile _buildClickableTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage('assets/images/profile.jpg'),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit Profile tapped')),
                                );
                              },
                              child: const CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        guardianName, // Display fetched username here
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1.5),
                    ListTile(
                      leading: const Icon(Icons.person_add_alt_1),
                      title: const Text('Add Children to Account'),
                      onTap: _showAddChildForm,
                    ),
                    _buildClickableTile(Icons.lock_reset, 'Change Password'),
                    _buildClickableTile(Icons.settings, 'App Settings'),
                    _buildClickableTile(Icons.language, 'Language'),
                    _buildClickableTile(Icons.info, 'About App'),
                    _buildClickableTile(Icons.description, 'Terms and Conditions'),
                    _buildClickableTile(Icons.privacy_tip, 'Privacy & Policy'),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                      onTap: _showLogoutDialog,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
