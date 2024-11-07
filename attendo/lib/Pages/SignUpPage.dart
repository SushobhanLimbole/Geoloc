import 'package:attendo/Pages/SignInPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = true;
  bool _isConfirmPasswordVisible = true;
  String? selectedRole; // This will hold the selected role from the dropdown

  final List<String> roles = ['Admin', 'Employee']; // Roles list

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
                  height: 150,
                  width: 200,
                  margin: const EdgeInsets.only(top: 50, bottom: 15),
                  decoration: const BoxDecoration(
                      // shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/signup.jpg'))),
                ),

                Text(
                  'Nice to Meet You!',
                  style: GoogleFonts.poppins(
                      fontSize: 30, fontWeight: FontWeight.w700),
                ),

                Text(
                  'Create Your Account',
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

                // Confirm Password TextField
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.password),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() {
                        _isPasswordVisible = !_isConfirmPasswordVisible;
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
                      return 'Please confirm your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      return 'Password mismatch';
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
                const SizedBox(height: 30.0),

                // Sign Up Button
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          const Color.fromRGBO(74, 108, 89, 1))),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // If all validations pass
                      debugPrint('Email: ${emailController.text}');
                      debugPrint('Password: ${passwordController.text}');
                      debugPrint('Role: $selectedRole');

                      // Handle successful sign-up logic
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  child: Text(
                    'Create My Account',
                    style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
