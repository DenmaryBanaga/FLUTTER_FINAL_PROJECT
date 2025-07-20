import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;

  static String? savedEmail;
  static String? savedPassword;

  void _login() {
    // You can check against stored data here if needed
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Success"),
        content: Text("You have successfully logged in!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // If "remember me" was used in the same session
    if (savedEmail != null && savedPassword != null) {
      emailController.text = savedEmail!;
      passwordController.text = savedPassword!;
      rememberMe = true;
    }
  }

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
                Icon(Icons.login, size: 80, color: Colors.blue),
                SizedBox(height: 10),
                Text(
                  "Guardian Login",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth > 400 ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 30),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your email 📧' : null,
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Minimum 6 characters 🔐' : null,
                ),

                // Remember Me
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                          if (rememberMe) {
                            savedEmail = emailController.text;
                            savedPassword = passwordController.text;
                          } else {
                            savedEmail = null;
                            savedPassword = null;
                          }
                        });
                      },
                    ),
                    Text(
                      "Remember Me",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 10),

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
                      if (rememberMe) {
                        savedEmail = emailController.text;
                        savedPassword = passwordController.text;
                      }
                      _login();
                    }
                  },
                  child: Text("Login"),
                ),
                SizedBox(height: 20),

                Text(
                  "Don't have an account?",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),

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
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Register'),
                ),

                SizedBox(height: 20),

                // Social Logins
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Google login logic
                      },
                      icon: Icon(Icons.g_mobiledata, color: Colors.red),
                      label: Text("Google", style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Facebook login logic
                      },
                      icon: Icon(Icons.facebook, color: Colors.blue),
                      label: Text("Facebook", style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
