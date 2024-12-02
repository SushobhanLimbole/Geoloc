import 'package:attendo/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key, required this.userEmail});

  final String userEmail;

  @override
  _VerificationPageState createState() =>
      _VerificationPageState(this.userEmail);
}

class _VerificationPageState extends State<VerificationPage> {
  // String searchQuery = "";

  final String userEmail;
  _VerificationPageState(this.userEmail);

  // void updateSearchQuery(String query) {
  //   setState(() {
  //     searchQuery = query;
  //   });
  // }

  Future<void> updateAttendanceStatus(
    String empEmail,
      String yearMonth, String day, bool isAccepted) async {
    debugPrint('yearmonth ====== $yearMonth');
    // Reference to the main document
    DocumentReference mainDocRef = FirebaseFirestore.instance
        .collection('attendanceRecords')
        .doc('${empEmail}-${yearMonth}');

    // Update the main document to include the month field
    await mainDocRef.set({
      'month': yearMonth, // Adding the month field in the main document
    }, SetOptions(merge: true));

    // Now update the specific day's attendance status within the nested 'dailyRecords' collection
    await mainDocRef.collection("dailyRecords").doc(day).update({
      'verifiedBy': userEmail,
      'isPendingVerification': false,
      'status': isAccepted ? 'Present' : 'Absent',
      'validAttendance': isAccepted,
    });

    // Display a confirmation message using a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAccepted ? 'Request Accepted' : 'Request Declined',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Verification"),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios)),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('attendanceRecords')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                color: secondaryColor,
              ));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No attendance records found"));
            }
        
            var attendanceRecords = snapshot.data!.docs;
            return ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                var userMonthRecord = attendanceRecords[index];
        
                return StreamBuilder(
                  stream: userMonthRecord.reference
                      .collection('dailyRecords')
                      .where('isManualEntry', isEqualTo: true)
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> dailySnapshot) {
                    if (dailySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!dailySnapshot.hasData ||
                        dailySnapshot.data!.docs.isEmpty) {
                      return SizedBox.shrink();
                    }
        
                    var dailyRecords = dailySnapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: dailyRecords.length,
                      itemBuilder: (context, dayIndex) {
                        var dayRecord = dailyRecords[dayIndex];
                        var data = dayRecord.data() as Map<String, dynamic>;
        
                        // Display the record if it requires verification
                        if (data['isPendingVerification']) {
                          debugPrint('entered');
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: InkWell(
                              onTap: () {
                                showRequestDetails(context, data);
                              },
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data["userName"] ?? "N/A",
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: secondaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            data["userEmail"] ?? "N/A",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Date: ${data["date"]}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: secondaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return SizedBox
                            .shrink(); // Skip records that do not need verification
                      },
                    );
                  },
                );
              },
            );
          },
        ));
  }

  String convertTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  String convertTimestampToYearMonth(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy_MM').format(dateTime);
  }

  String convertTimestampToDD(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('dd').format(dateTime);
  }

  void showRequestDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.8,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    data["userName"] ?? "N/A",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _detailTile(Icons.email_outlined, "Email",
                      data["userEmail"] ?? "Not provided"),
                  _detailTile(Icons.calendar_today_outlined, "Date",
                      data["date"] ?? "Not provided"),
                  _detailTile(Icons.info_outline, "Reason",
                      data["reason"] ?? "No reason given"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            updateAttendanceStatus(
                              data["userEmail"],
                                convertTimestampToYearMonth(data['date']),
                                convertTimestampToDD(data['date']),
                                true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            "Accept",
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeclineConfirmation(context, data['date'],data['userEmail']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            "Decline",
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeclineConfirmation(BuildContext context, String date,String empEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure?', style: GoogleFonts.poppins()),
          content: Text(
            'Are you sure you want to decline this manual attendance request?',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                updateAttendanceStatus(empEmail,convertTimestampToYearMonth(date),
                    convertTimestampToDD(date), false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child:
                  Text("Yes", style: GoogleFonts.poppins(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child:
                  Text("No", style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _detailTile(IconData icon, String title, String subtitle) {
    debugPrint('sub ==== $subtitle');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
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
}
