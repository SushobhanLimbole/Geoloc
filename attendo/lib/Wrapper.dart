import 'package:attendo/Constants.dart';
import 'package:attendo/Pages/AttendanceMap.dart';
import 'package:attendo/Pages/SignInPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  // Function to check the user's role
  Future<Map<String, String>?> _getUserDetails(User user) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Assuming the role and userName are stored in the 'role' and 'userName' fields
        String userName = userDoc['userName'] ?? 'Unknown';
        String userRole =
            userDoc['role'] ?? 'employee'; // Default to 'employee'
        String userEmail = user.email ?? 'Unknown';
        return {
          'role': userRole,
          'userName': userName,
          'userEmail': userEmail,
        };
      } else {
        return null; // No user data found
      }
    } catch (e) {
      // Handle error if fetching user data fails
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          } else {
            if (snapshot.data == null) {
              return SignInPage(); // User is not logged in, show sign-in page
            } else {
              // User is logged in, check role from Firestore
              return FutureBuilder<Map<String, String>?>(
                future: _getUserDetails(snapshot.data!),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: secondaryColor,
                      ),
                    );
                  } else if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                    return const Center(
                      child: Text("Error retrieving role"),
                    );
                  } else {
                    // Get user details and role
                    Map<String, String> userDetails = roleSnapshot.data!;
                    String role = userDetails['role']!;
                    String userName = userDetails['userName']!;
                    String userEmail = userDetails['userEmail']!;

                    // Check role and navigate accordingly
                    if (role == 'admin') {
                      // Navigate to AttendanceMap for admin
                      return AttendanceMap(
                        isAdmin: true,
                        userName: userName,
                        userEmail: userEmail,
                      );
                    } else {
                      // Default user, navigate to AttendanceMap or other pages
                      return AttendanceMap(
                        isAdmin: false,
                        userName: userName,
                        userEmail: userEmail,
                      );
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }
}
