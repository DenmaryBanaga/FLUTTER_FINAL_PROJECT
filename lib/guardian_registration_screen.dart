import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuardianRegistrationScreen extends StatefulWidget {
  static final List<Map<String, String>> registeredUsers = [];

  const GuardianRegistrationScreen({super.key});

  @override
  _GuardianRegistrationScreenState createState() => _GuardianRegistrationScreenState();
}

class _GuardianRegistrationScreenState extends State<GuardianRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String age = '';
  String password = '';
  String address = '';
  String contactNumber = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.yellow.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.family_restroom, size: 80, color: Colors.blue[800]),
                SizedBox(height: 10),
                Text(
                  "Register as Guardian",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth > 400 ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 30),

                _buildTextField(
                  label: 'Full Name',
                  icon: Icons.person,
                  onSaved: (value) => fullName = value!,
                  validator: (value) => value!.trim().isEmpty ? 'Please enter your full name 😊' : null,
                ),
                SizedBox(height: 20),

                _buildTextField(
                  label: 'Age',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  onSaved: (value) => age = value!,
                  validator: (value) => value!.trim().isEmpty ? 'Enter your age please 🧓' : null,
                ),
                SizedBox(height: 20),

                _buildTextField(
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  helperText: 'Minimum 6 characters',
                  onSaved: (value) => password = value!,
                  validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters 🔐' : null,
                ),
                SizedBox(height: 20),

                _buildTextField(
                  label: 'Address',
                  icon: Icons.home,
                  onSaved: (value) => address = value!,
                  validator: (value) => value!.trim().isEmpty ? 'Please enter your address 🏠' : null,
                ),
                SizedBox(height: 20),

                _buildTextField(
                  label: 'Contact Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => contactNumber = value!,
                  validator: (value) => value!.trim().isEmpty ? 'Contact number is required ☎️' : null,
                ),
                SizedBox(height: 20),

                _buildTextField(
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => email = value!,
                  validator: (value) => value!.trim().isEmpty ? 'Email is required 📧' : null,
                ),
                SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 50),
                    textStyle: GoogleFonts.poppins(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      GuardianRegistrationScreen.registeredUsers.add({
                        'email': email,
                        'password': password,
                      });

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Success"),
                          content: Text("Registered successfully. Go to Login."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: Text('Register'),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 50),
                    textStyle: GoogleFonts.poppins(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text("Go to Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? helperText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
