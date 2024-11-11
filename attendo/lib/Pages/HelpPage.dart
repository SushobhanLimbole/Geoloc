import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HelpPage extends StatelessWidget {
  // Developer contact information
  final List<Map<String, String>> developers = [
    {
      'name': 'Sushobhan Limbole',
      'email': 'sushobhanlimbole17@gmail.com',
      'linkedin': 'www.google.com',
    },
    {
      'name': 'Parnika Pise',
      'email': 'parnikapise08@gmail.com',
      'linkedin': 'www.linkedin.com/in/parnika-pise-9a9876243',
    },
    // Add more developers as needed
  ];

  // Method to launch URLs
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
  final String fullUrl = uri.isScheme('http') || uri.isScheme('https') ? url : 'https://$url';
  // final Uri uri = Uri.parse(url);

  try {
    if (await canLaunchUrl(Uri.parse(fullUrl))) {
      await launchUrl(
        Uri.parse(fullUrl),
        mode: LaunchMode.externalApplication,  // Specify the launch mode if needed
      );
    } else {
      throw 'Could not launch ${Uri.parse(fullUrl)}';
    }
  } catch (e) {
    print('Error launching URL: $e');
  }
}

  // Method to launch email client
  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Contact'),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: developers.length,
          itemBuilder: (context, index) {
            final developer = developers[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      developer['name']!,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.blue),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _sendEmail(developer['email']!),
                          child: Text(
                            developer['email']!,
                            style: GoogleFonts.poppins(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     Icon(Icons.phone, color: Colors.green),
                    //     SizedBox(width: 8),
                    //     GestureDetector(
                    //       onTap: () => _makePhoneCall(developer['phone']!),
                    //       child: Text(
                    //         developer['phone']!,
                    //         style: GoogleFonts.poppins(color: Colors.green),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.link, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _launchURL(developer['linkedin']!),
                          child: Text(
                            'LinkedIn Profile',
                            style: GoogleFonts.poppins(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
