import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RequestAttendance extends StatefulWidget {
  const RequestAttendance(
      {super.key, required this.userEmail, required this.userName});

  final String userName;
  final String userEmail;

  @override
  State<RequestAttendance> createState() =>
      _RequestAttendanceState(this.userName, this.userEmail);
}

class _RequestAttendanceState extends State<RequestAttendance> {
  final List<String> reasons = [
    "Network Issues",
    "GPS Not Working",
    "Battery Low",
    "App Error or Crash",
    "Working Outside Office Location",
    "Device Not Available",
    "Other (Specify)"
  ];

  _RequestAttendanceState(this.userName, this.userEmail);

  final String userName;
  final String userEmail;
  String? selectedReason;
  bool showOtherTextField = false;
  final TextEditingController otherReasonController = TextEditingController();

  Future<void> submitAttendanceRequest(BuildContext context) async {
    try {
      // Define the current month and day keys
      final monthKey = DateFormat('yyyy_MM').format(DateTime.now());
      final dayKey = DateFormat('dd').format(DateTime.now());

      // Unique ID for the attendance request within the dailyRequests collection
      String attendanceId =
          FirebaseFirestore.instance.collection('attendanceRecords').doc().id;

      String reason = selectedReason == "Other (Specify)"
          ? otherReasonController.text
          : selectedReason ?? '';

      // Define attendance data
      Map<String, dynamic> attendanceData = {
        'attendanceId': attendanceId,
        'userEmail': userEmail,
        'userName': userName,
        'checkInTime': null, // For requests, check-in time is initially empty
        'checkOutTime': null, // For requests, check-out time is initially empty
        'geoPoint': '', // Not needed for requests
        'status': 'Pending', // Set status to "Pending" for manual requests
        'validAttendance': false,
        'isManualEntry': true,
        'isPendingVerification': true,
        'verifiedBy': '',
        'reason': reason,
        'totalTimeInGeofence': '',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() // Current date
      };

      // Reference to the correct monthly document and dailyRequests subcollection
      await FirebaseFirestore.instance
          .collection('attendanceRecords')
          .doc('$userEmail-$monthKey')
          .collection('dailyRecords')
          .doc(dayKey)
          .set(attendanceData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance request submitted successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Attendance'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Reason",
              ),
              value: selectedReason,
              items: reasons.map((reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReason = value;
                  showOtherTextField = value == "Other (Specify)";
                });
              },
            ),
            if (showOtherTextField) ...[
              const SizedBox(height: 20),
              TextField(
                controller: otherReasonController,
                maxLines: 2,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Specify Reason',
                ),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final reason = selectedReason == "Other (Specify)"
                        ? otherReasonController.text
                        : selectedReason;
                    print("Submitted Reason: $reason");
                    submitAttendanceRequest(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
