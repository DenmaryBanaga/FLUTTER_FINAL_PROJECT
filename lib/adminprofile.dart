import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String adminName = 'admin'; // ✅ Predefined as "admin"

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                              backgroundImage: AssetImage('assets/profile.jpg'),
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
                        adminName, // ✅ Displays "admin"
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1.5),
                    _buildClickableTile(Icons.dashboard, 'Admin Dashboard'),
                    _buildClickableTile(Icons.supervised_user_circle, 'Manage Users'),
                    _buildClickableTile(Icons.medical_services, 'Medical Records'),
                    _buildClickableTile(Icons.calendar_today, 'Manage Appointments'),
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
