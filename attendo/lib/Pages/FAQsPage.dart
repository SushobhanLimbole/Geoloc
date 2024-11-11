import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQsPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How does the geolocation-based attendance feature work?',
      'answer':
          'The app uses the geolocator package to track an employee’s location when they enter or exit a predefined geofenced area around the workplace. If the employee is within this area, the system automatically registers their check-in or check-out time. Location updates are periodically checked to ensure they are within the area for at least 90% of their shift time.'
    },
    {
      'question': 'Can employees manually check in if they are working offsite?',
      'answer':
          'Yes, if employees are working remotely or offsite, they can submit a manual attendance request. This request goes to the HR or Admin panel, where they can verify the location and approve it before it is recorded as attendance in the system.'
    },
    {
      'question': 'How is the attendance data protected?',
      'answer':
          'To ensure data security, the app uses encryption and JWT (JSON Web Tokens) for user authentication and data protection. Each attendance record is securely stored in a database with restricted access to authorized personnel.'
    },
    {
      'question': 'Who can access the attendance records?',
      'answer':
          'Access to attendance records is limited based on roles. An admin can view and manage attendance records for their specific branch, while a super admin has access to all records across branches. The CEO or company owner can assign these roles using the admin panel.'
    },
    {
      'question': 'Can the app support multiple shifts?',
      'answer':
          'Yes, the application can handle multiple shifts by allowing admins to set different time slots for various employee groups. Each shift is treated independently, and the geolocation feature checks attendance based on shift timings.'
    },
    {
      'question': 'How is attendance verified if an employee is at a different location?',
      'answer':
          'When an employee checks in from an offsite location, they can submit a manual attendance request. HR or the manager reviews the request and verifies the location before approving it as attendance.'
    },
    {
      'question': "What happens if there's a technical issue with location tracking?",
      'answer':
          'If there are issues with geolocation tracking, employees can request manual attendance verification, allowing HR or the admin to verify attendance based on the employee’s explanation or other supporting data.'
    },
    {
      'question': 'How is the data stored and retrieved for the application?',
      'answer':
          'The app stores data such as user information, attendance records, and verification requests in a secure database. The database structure includes fields for user identification , attendance specifics , and manual verification records. These records are accessible only to authorized roles.'
    },
    {
      'question': 'How does the admin interface differ from the employee interface?',
      'answer':
          'The employee interface allows for geolocation-based check-ins, manual attendance requests, and shift information. The admin interface includes additional features such as approving manual attendance requests, viewing attendance reports, and managing employee roles and access permissions.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios
            )),
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqs[index]['question']!,style: GoogleFonts.poppins(),),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(faqs[index]['answer']!,style: GoogleFonts.poppins(),),
              ),
            ],
          );
        },
      ),
    );
  }
}