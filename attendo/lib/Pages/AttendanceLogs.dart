import 'package:attendo/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceLogs extends StatefulWidget {
  const AttendanceLogs({super.key});

  @override
  State<AttendanceLogs> createState() => _AttendanceLogsState();
}

class _AttendanceLogsState extends State<AttendanceLogs> {
  PageController _pageController = PageController();
  int _selectedIndex = 0;
  // CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<String> items = [
    'Apple',
    'Banana',
    'Grapes',
    'Orange',
    'Pineapple',
    'Strawberry'
  ];

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
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      // calendarFormat: _calendarFormat,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      // onFormatChanged: (format) {
      //   if (_calendarFormat != format) {
      //     setState(() {
      //       _calendarFormat = format;
      //     });
      //   }
      // },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        selectedDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor, secondaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        weekendTextStyle: GoogleFonts.poppins(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
        holidayTextStyle: GoogleFonts.poppins(
          color: Colors.purple,
          fontWeight: FontWeight.bold,
        ),
        outsideDaysVisible: true,
        outsideTextStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
        disabledTextStyle: GoogleFonts.poppins(color: Colors.grey.shade300),
        selectedTextStyle: GoogleFonts.poppins(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        todayTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
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
        // formatButtonDecoration: BoxDecoration(
        //   color: primaryColor,
        //   borderRadius: BorderRadius.circular(20),
        // ),
        // formatButtonTextStyle: GoogleFonts.notoSans(
        //   color: Colors.white,
        //   fontSize: 16,
        //   fontWeight: FontWeight.w600,
        // ),
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
                height: 450,
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
