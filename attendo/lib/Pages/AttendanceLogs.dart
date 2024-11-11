import 'package:attendo/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AttendanceLogs extends StatefulWidget {
  const AttendanceLogs({super.key, required this.userEmail});

  final String userEmail;

  @override
  State<AttendanceLogs> createState() => _AttendanceLogsState(this.userEmail);
}

class _AttendanceLogsState extends State<AttendanceLogs> {
  PageController _pageController = PageController();
  int _selectedIndex = 0;
  // CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final String userEmail;
  final List<String> items = [
    'Apple',
    'Banana',
    'Grapes',
    'Orange',
    'Pineapple',
    'Strawberry'
  ];

  _AttendanceLogsState(this.userEmail);

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  Widget _logsCalendar() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('attendanceRecords')
          .where('userEmail',
              isEqualTo:
                  userEmail) // replace userEmail with the actual variable
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: secondaryColor,));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        //   return Center(child: Text('No attendance records found.'));
        // }

        // Extract attendance data from snapshot
        Map<DateTime, String> attendanceData = {};
        for (var doc in snapshot.data!.docs) {
          DateTime date = (doc['date'] as Timestamp).toDate();
          String status = doc['status'];
          attendanceData[date] = status;
        }

        // Calculate total attendance, present, and absent for the selected month
        Map<DateTime, String> filteredAttendance =
            _filterAttendanceByMonth(attendanceData, _focusedDay);
        int totalAttendance = filteredAttendance.length;
        int totalPresent = filteredAttendance.values
            .where((status) => status == 'Present')
            .length;
        int totalAbsent = filteredAttendance.values
            .where((status) => status == 'Absent')
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showAttendanceDetails(selectedDay);
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                isTodayHighlighted: false,
                outsideDaysVisible: true,
                outsideTextStyle:
                    GoogleFonts.poppins(color: Colors.grey.shade500),
                disabledTextStyle:
                    GoogleFonts.poppins(color: Colors.grey.shade300),
                selectedTextStyle: GoogleFonts.poppins(color: Colors.white),
                defaultTextStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                withinRangeTextStyle: GoogleFonts.poppins(color: Colors.teal),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: GoogleFonts.poppins(
                  color: secondaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: secondaryColor,
                  size: 28,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: secondaryColor,
                  size: 28,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  DateTime normalizedDay =
                      DateTime(day.year, day.month, day.day);
                  String status = attendanceData[normalizedDay] ?? '';
                  Color dayColor;

                  // Set the color based on the attendance status
                  switch (status) {
                    case 'Present':
                      dayColor = Colors.green;
                      break;
                    case 'half_day':
                      dayColor = Colors.amber;
                      break;
                    case 'Absent':
                      dayColor = Colors.red;
                      break;
                    default:
                      dayColor = Colors.transparent;
                  }

                  bool isSelected = isSameDay(_selectedDay, day);
                  bool isToday = isSameDay(DateTime.now(), day);

                  Color backgroundColor = dayColor == Colors.transparent
                      ? Colors.transparent
                      : dayColor;

                  if (isToday) {
                    backgroundColor = secondaryColor;
                  } else if (isSelected) {
                    backgroundColor = primaryColor;
                  }

                  return Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}', // Show the day number
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: backgroundColor == Colors.transparent
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Attendance stats display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _attendanceStatCard("Total Attendance", totalAttendance),
                      _attendanceStatCard("Total Present", totalPresent),
                      _attendanceStatCard("Total Absent", totalAbsent),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// A helper method to filter attendance data by the current month
  Map<DateTime, String> _filterAttendanceByMonth(
      Map<DateTime, String> attendanceData, DateTime month) {
    int year = month.year;
    int monthNumber = month.month;
    Map<DateTime, String> filteredData = {};

    attendanceData.forEach((date, status) {
      if (date.year == year && date.month == monthNumber) {
        filteredData[date] = status;
      }
    });

    return filteredData;
  }

// A helper method to create attendance stat cards
  Widget _attendanceStatCard(String label, int value) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '$value',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pendingLogs() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date header
              Text(
                'Oct 27, 2024',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 12),

              // Check-In and Check-Out row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Check-In Column
                  Column(
                    children: [
                      Text(
                        "Check-In",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '09:00 AM',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Check-Out Column
                  Column(
                    children: [
                      Text(
                        "Check-Out",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '05:00 PM',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Status and Type Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status
                  Column(
                    children: [
                      Text(
                        "Status",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Present',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: 'Present' == "Present"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  // Type
                  Column(
                    children: [
                      Text(
                        "Type",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manual',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAttendanceDetails(DateTime selectedDay) {
    String formattedDate = DateFormat('MMM dd, yyyy').format(selectedDay);
    String checkInTime = '09:00 AM'; // Replace with dynamic data
    String checkOutTime = '05:00 PM'; // Replace with dynamic data
    String status = 'Present'; // Replace with dynamic data
    String type = 'Manual'; // Replace with dynamic data

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date header with a background color
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [secondaryColor, secondaryColor.withOpacity(0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  formattedDate,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Check-In and Check-Out Row with Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailColumn(
                    icon: Icons.login,
                    label: 'Check-In',
                    value: checkInTime,
                    valueColor: Colors.green,
                  ),
                  _buildDetailColumn(
                    icon: Icons.logout,
                    label: 'Check-Out',
                    value: checkOutTime,
                    valueColor: Colors.redAccent,
                  ),
                ],
              ),
              Divider(height: 30, thickness: 1, color: Colors.grey[300]),

              // Status and Type Row with Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailColumn(
                    icon: Icons.check_circle,
                    label: 'Status',
                    value: status,
                    valueColor: status == 'Present' ? Colors.green : Colors.red,
                  ),
                  _buildDetailColumn(
                    icon: Icons.work,
                    label: 'Type',
                    value: type,
                    valueColor: Colors.blueAccent,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, size: 30, color: valueColor),
        SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Logs'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
            )),
        actions: [
          SearchAnchor(
            builder: (context, controller) => IconButton(
                onPressed: () {
                  controller.openView();
                },
                icon: Icon(Icons.search)),
            suggestionsBuilder: (context, controller) {
              // Filter items based on controller's query
              final query = controller.value.text;
              final suggestions = items
                  .where((item) =>
                      item.toLowerCase().contains(query.toLowerCase()))
                  .toList();

              // Map each suggestion to a ListTile
              return suggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    setState(() {
                      // selectedQuery = suggestion;
                    });
                    controller.clear(); // Close search on selection
                  },
                );
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 15,
                          color: Colors.grey.shade400,
                          blurStyle: BlurStyle.outer)
                    ],
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _onTabChanged(0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          width: screenWidth * (44 / 100),
                          decoration: BoxDecoration(
                            color: _selectedIndex == 0
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              'Logs',
                              style: GoogleFonts.poppins(
                                color: _selectedIndex == 0
                                    ? secondaryColor
                                    : primaryColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _onTabChanged(1),
                        child: Container(
                          width: screenWidth * (44 / 100),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                              color: _selectedIndex == 1
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                            child: Text(
                              'Pending',
                              style: GoogleFonts.poppins(
                                color: _selectedIndex == 1
                                    ? secondaryColor
                                    : primaryColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 600,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: [_logsCalendar(), _pendingLogs()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
