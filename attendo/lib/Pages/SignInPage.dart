import 'package:attendo/Pages/AttendanceMap.dart';
import 'package:attendo/Pages/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final List<String> roles = ['admin', 'employee'];

  String? selectedRole;

  bool _isPasswordVisible = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _trySubmit() async {
  final isValid = _formKey.currentState?.validate();
  if (isValid ?? false) {
    _formKey.currentState?.save();

    // Show loading SnackBar
    final loadingSnackBar = SnackBar(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Checking user role, please wait...'),
        ],
      ),
      duration: Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(loadingSnackBar);

    try {
      // Fetch the user document from Firestore based on the email
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (userSnapshot.docs.isNotEmpty) {
        // Retrieve the first user document
        DocumentSnapshot userDoc = userSnapshot.docs.first;
        String userRole = userDoc['role'] ?? 'employee';

        if (userRole == selectedRole) {
          // Role is valid, proceed with login
          User? user = await _auth
              .signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              )
              .then((value) => value.user);

          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User logged in successfully.')),
            );

            // Navigate to the MapDemoPage after successful login
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceMap(
                  isAdmin: userRole == 'admin',
                  userName: userDoc['userName'],
                  userEmail: emailController.text.trim(),
                ),
              ),
            );
          }
        } else {
          // If the role doesn't match, show an error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role does not match.')),
          );
        }
      } else {
        // If no user is found with the provided email
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      String message = 'An error occurred, please check your credentials!';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}


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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),),
                    GestureDetector(
                      onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => SignUpPage(),)),
                      child: Text('Sign Up',style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w500),))
                  ],
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

                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => MapDemoPage(),
                    //     ));
                    _trySubmit();
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
