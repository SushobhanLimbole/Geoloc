import 'package:attendo/Pages/Demo.dart';
import 'package:attendo/Pages/MapDemoPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  // Key for the form
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final List<String> roles = ['Admin', 'Employee'];

  String? selectedRole;

  bool _isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Assign form key
            child: Column(
              children: [
                // logo
                Container(
                  height: 200,
                  width: 200,
                  margin: const EdgeInsets.only(top: 70, bottom: 15),
                  decoration: const BoxDecoration(
                      // shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/login.jpg'))),
                ),

                Text(
                  'Hello Again!',
                  style: GoogleFonts.poppins(
                      fontSize: 30, fontWeight: FontWeight.w700),
                ),

                Text(
                  'Log into your account',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 30.0),
                // Email TextField
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.email),
                    ),
                  ),
                  validator: (value) {
                    // Basic email validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailPattern = r'^[^@]+@[^@]+\.[^@]+$';
                    if (!RegExp(emailPattern).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Password TextField
                TextFormField(
                  controller: passwordController,
                  obscureText: _isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.password),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: _isPasswordVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(
                                Icons.visibility_off,
                              ),
                      ),
                    ),
                  ),
                  validator: (value) {
                    // Basic password validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Role',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.person),
                    ),
                  ),
                  validator: (value) {
                    // Validate if a role is selected
                    if (value == null) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25.0),

                // Sign In Button
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 74, 108, 89))),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, print the values
                      print('Email: ${emailController.text}');
                      print('Password: ${passwordController.text}');
                      // Add your sign-in logic here
                    }

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapDemoPage(),
                        ));
                  },
                  child: Text('Sign In',
                      style: GoogleFonts.notoSans(
                        color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
