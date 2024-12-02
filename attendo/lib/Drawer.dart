import 'package:attendo/Constants.dart';
import 'package:attendo/Pages/AttendanceLogs.dart';
import 'package:attendo/Pages/DailyRecordsPage.dart';
import 'package:attendo/Pages/FAQsPage.dart';
import 'package:attendo/Pages/HelpPage.dart';
// import 'package:attendo/Pages/MyProfilePage.dart';
import 'package:attendo/Pages/RequestAttendance.dart';
import 'package:attendo/Pages/SetGeofenceArea.dart';
import 'package:attendo/Pages/ShiftManagementPage.dart';
import 'package:attendo/Pages/SignInPage.dart';
import 'package:attendo/Pages/Verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer(
      {super.key,
      required this.isAdmin,
      required this.userName,
      required this.userEmail});

  final bool isAdmin;
  final String userName;
  final String userEmail;

  @override
  State<AppDrawer> createState() =>
      _AppDrawerState(this.isAdmin, this.userName, this.userEmail);
}

class _AppDrawerState extends State<AppDrawer> {
  final bool isAdmin;
  String userPic = '';
  final String userName;
  final String userEmail;

  _AppDrawerState(this.isAdmin, this.userName, this.userEmail);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
            accountName: InkWell(
              child: Text(
                userName,
                style: GoogleFonts.poppins(color: secondaryColor),
              ),
            ),
            accountEmail: Text(userEmail,
                style: GoogleFonts.poppins(color: secondaryColor)),
            currentAccountPicture: userPic != ''
                ? ClipOval(
                    child: Image.network(
                      userPic,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              color: secondaryColor,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        }
                      },
                    ),
                  )
                : CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryColor,
                    child: Text(
                      userName[0],
                      style: GoogleFonts.poppins(fontSize: 25),
                    ),
                  ),
          ),
          isAdmin ? 
          ListTile(
            leading: const Icon(
              Icons.event_available,
              color: secondaryColor,
            ),
            title: Text('Daily Attendance',
                style: GoogleFonts.poppins(
                  color: secondaryColor,
                )),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyRecordsPage(userEmail: userEmail,),
                )),
          ) : Container(),
          ListTile(
            leading: const Icon(
              Icons.event,
              color: secondaryColor,
            ),
            title: Text('Attendance Logs',
                style: GoogleFonts.poppins(
                  color: secondaryColor,
                )),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceLogs(userEmail: userEmail,),
                )),
          ),
          ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: secondaryColor,
              ),
              title: Text('Request Attendance',
                  style: GoogleFonts.poppins(
                    color: secondaryColor,
                  )),
              onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestAttendance(userName: userName,userEmail: userEmail),
                      ))),
          isAdmin
              ? ListTile(
                  leading: const Icon(
                    Icons.check,
                    color: secondaryColor,
                  ),
                  title: Text('Verification',
                      style: GoogleFonts.poppins(
                        color: secondaryColor,
                      )),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerificationPage(userEmail: userEmail,),
                      )),
                )
              : Container(),
          isAdmin
              ? ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: secondaryColor,
                  ),
                  title: Text('Set Geofence Area',
                      style: GoogleFonts.poppins(
                        color: secondaryColor,
                      )),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetGeofenceArea(),
                      )),
                )
              : Container(),
              isAdmin
              ? ListTile(
                  leading: const Icon(
                    Icons.schedule,
                    color: secondaryColor,
                  ),
                  title: Text('Set Shift Time',
                      style: GoogleFonts.poppins(
                        color: secondaryColor,
                      )),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShiftManagementPage(),
                      )),
                )
              : Container(),
          // const Divider(),
          ListTile(
            leading: const Icon(
              Icons.help,
              color: secondaryColor,
            ),
            title: Text('FAQs',
                style: GoogleFonts.poppins(
                  color: secondaryColor,
                )),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FAQsPage(),
                  ))
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: secondaryColor,
            ),
            title: Text('Help',
                style: GoogleFonts.poppins(
                  color: secondaryColor,
                )),
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpPage(),
                  ))
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: Text(
              'Sign Out',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
            onTap: () async {
              // Handle navigation
              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
