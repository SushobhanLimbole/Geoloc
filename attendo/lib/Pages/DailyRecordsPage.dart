import 'package:attendo/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DailyRecordsPage extends StatefulWidget {
  const DailyRecordsPage({super.key, required this.userEmail});

  final String userEmail;

  @override
  State<DailyRecordsPage> createState() => _DailyRecordsPageState();
}

class _DailyRecordsPageState extends State<DailyRecordsPage> {
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Daily Attendance",
          style: GoogleFonts.poppins(),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          // ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: secondaryColor,
          //     ),
          //     onPressed: () => _pickDate(),
          //     child: Text(
          //       DateFormat('yyyy-MM-dd').format(selectedDate),
          //       style: GoogleFonts.poppins(color: Colors.white),
          //     )),
              Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => _pickDate(),
        icon: const Icon(
          Icons.calendar_today,
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          DateFormat('yyyy-MM-dd').format(selectedDate),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: secondaryColor),
            );
          }
          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final allUsers = userSnapshot.data!.docs;

          return FutureBuilder(
            future: _fetchDailyAttendance(allUsers),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: secondaryColor),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text("No attendance records found."));
              }

              final dailyAttendanceList = snapshot.data!;

              return ListView.builder(
                itemCount: dailyAttendanceList.length,
                itemBuilder: (context, index) {
                  final dayRecord = dailyAttendanceList[index];

                  return GestureDetector(
                    onTap: () => _showAttendanceDetails(context, dayRecord),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: primaryColor,
                              child: const Icon(Icons.person,
                                  color: secondaryColor),
                              radius: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dayRecord["userName"] ?? "N/A",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayRecord["userEmail"] ?? "N/A",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Date: ${dayRecord["date"]}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Status: ${dayRecord["status"]}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: DateTime.now(), // Latest selectable date
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Widget _detailTile(
      IconData icon, String title, String subtitle, Color color) {
    debugPrint('sub ==== $subtitle');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDetails(
      BuildContext context, Map<String, dynamic> attendanceData) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    attendanceData["userName"] ?? "N/A",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _detailTile(Icons.login, 'Check-in Time',
                  attendanceData['checkInTime'] ?? 'N/A', Colors.green),
              _detailTile(Icons.logout, 'Check-out Time',
                  attendanceData['checkOutTime'] ?? 'N/A', Colors.red),
              _detailTile(
                  Icons.check_circle_rounded,
                  'Status',
                  attendanceData['status'] ?? 'N/A',
                  attendanceData['status'] == "Absent"
                      ? Colors.red
                      : Colors.green),
              _detailTile(
                  Icons.work,
                  'Mode',
                  attendanceData['isManualEntry'] ? 'Manual' : 'Auto',
                  Colors.green),
              _detailTile(
                  Icons.schedule,
                  'Total Geofence Time',
                  "${attendanceData['totalTimeInGeofence']} mins",
                  Colors.green),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final shouldToggle = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: attendanceData['status'] == 'Absent'
                              ? Text(
                                  "Mark Present",
                                  style: GoogleFonts.poppins(),
                                )
                              : Text(
                                  'Mark Absent',
                                  style: GoogleFonts.poppins(),
                                ),
                          content: Text(
                              "Are you sure you want to toggle attendance?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                "Confirm",
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (shouldToggle == true) {
                        await _toggleAttendance(attendanceData);
                        setState(() {
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: attendanceData['status'] == 'Absent'
                        ? Text(
                            "Mark Present",
                            style: GoogleFonts.poppins(),
                          )
                        : Text(
                            'Mark Absent',
                            style: GoogleFonts.poppins(),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleAttendance(Map<String, dynamic> attendanceData) async {
    final email = attendanceData['userEmail'];
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final monthKey = DateFormat('yyyy_MM').format(DateTime.now());
    final dayKey = DateFormat('dd').format(DateTime.now());

    final monthDocRef = FirebaseFirestore.instance
        .collection('attendanceRecords')
        .doc('$email-$monthKey');
    final dayDocRef = monthDocRef.collection('dailyRecords').doc(dayKey);

    final newStatus =
        attendanceData['status'] == 'Absent' ? 'Present' : 'Absent';

    Map<String, dynamic> updatedData = {
      'status': newStatus,
    };

    await dayDocRef.set(updatedData, SetOptions(merge: true));
  }

  Future _markAbsent(String userEmail, String userName) async {
    final monthKey = DateFormat('yyyy_MM').format(DateTime.now());
    final dayKey = DateFormat('dd').format(DateTime.now());

    final monthDocRef = FirebaseFirestore.instance
        .collection('attendanceRecords')
        .doc('$userEmail-$monthKey');

    await monthDocRef.set({'month': monthKey}, SetOptions(merge: true));

    final attendanceRef = monthDocRef.collection('dailyRecords').doc(dayKey);

    Map<String, dynamic> attendanceData = {
      'attendanceId': DateFormat('dd').format(DateTime.now()).toString(),
      'userEmail': userEmail,
      'userName': userName,
      'checkInTime': null, // For requests, check-in time is initially empty
      'checkOutTime': null, // For requests, check-out time is initially empty
      'geoPoint': null,
      'status': 'Absent', // Set status to "Pending" for manual requests
      'validAttendance': false,
      'isManualEntry': false,
      'isPendingVerification': false,
      'verifiedBy': '',
      'reason': '',
      'totalTimeInGeofence': 0,
      'date': DateFormat('yyyy-MM-dd')
          .format(DateTime.now())
          .toString() // Current date
    };
    await attendanceRef.set(attendanceData, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> _fetchDailyAttendance(
      List<QueryDocumentSnapshot> allUsers) async {
    final attendanceRecordsSnapshot =
        await FirebaseFirestore.instance.collection('attendanceRecords').get();

    final dailyAttendanceList = <Map<String, dynamic>>[];

    for (var user in allUsers) {
      var userData = user.data() as Map<String, dynamic>;

      bool isPresent = false;

      for (var monthRecord in attendanceRecordsSnapshot.docs) {
        final dailyRecordsSnapshot = await monthRecord.reference
            .collection('dailyRecords')
            .where('date',
                isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
            .get();

        for (var record in dailyRecordsSnapshot.docs) {
          var data = record.data() as Map<String, dynamic>;
          if (data['userEmail'] == userData['email']) {
            dailyAttendanceList.add({
              'userName': userData['userName'],
              'userEmail': userData['email'],
              'date': data['date'],
              'status': data['status'],
              'checkInTime': data['checkInTime'],
              'checkOutTime': data['checkOutTime'],
              'totalTimeInGeofence': data['totalTimeInGeofence'],
              'isManualEntry': data['isManualEntry'],
            });
            isPresent = true;
          }
        }
      }

      if (!isPresent) {
        dailyAttendanceList.add({
          'userName': userData['userName'],
          'userEmail': userData['email'],
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'status': 'Absent',
          'checkInTime': null,
          'checkOutTime': null,
          'totalTimeInGeofence': 0,
          'isManualEntry': false,
        });
        await _markAbsent(userData['email'], userData['userName']);
      }
    }

    return dailyAttendanceList;
  }
}
