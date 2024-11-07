import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<Map<String, String>> employeeRequests = const [
    {
      "name": "Rohit Sharma",
      "email": "rohit@gmail.com",
      "timestamp": "2024-10-27 09:45:32",
      "date": "2024-10-27",
      "reason": "Working Outside Office Location Working Outside Office Location Working Outside Office Location Working Outside Office Location Working Outside Office Location Working Outside Office Location Working Outside Office Location Working Outside Office Location Working Outside Office Location Working Outside Office Location",
    },
    {
      "name": "JP",
      "email": "hehe@gmail.com",
      "timestamp": "2024-10-26 15:30:10",
      "date": "2024-10-26",
      "reason": "Network Issues",
    },
  ];

  late List<Map<String, String>> filteredRequests;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredRequests = employeeRequests;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredRequests = employeeRequests
          .where((request) =>
              request["name"]!.toLowerCase().contains(query.toLowerCase()) ||
              request["email"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Employee Requests",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[800],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar with rounded corners
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search employee by name',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Displaying list of employee requests
              Expanded(
                child: filteredRequests.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          final request = filteredRequests[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                showRequestDetails(context, request);
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
                                    // Profile icon placeholder
                                    CircleAvatar(
                                      backgroundColor: const Color.fromARGB(
                                          255, 169, 236, 164),
                                      child: const Icon(Icons.person,
                                          color: Colors.green),
                                      radius: 28,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request["name"]!,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF388E3C),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            request["email"]!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Timestamp: ${request["timestamp"]}",
                                            style: const TextStyle(
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
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "No matching requests found",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
              ),
            ],
          ),
        ));
  }
}

void showRequestDetails(BuildContext context, Map<String, String> request) {
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
                // Drag handle at the top
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

                // Display Name
                Text(
                  request["name"] ?? "N/A",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF388E3C),
                  ),
                ),
                const SizedBox(height: 10),

                // Detail tiles with icons
                _detailTile(Icons.email_outlined, "Email",
                    request["email"] ?? "Not provided"),
                _detailTile(Icons.calendar_today_outlined, "Date",
                    request["date"] ?? "Not provided"),
                _detailTile(Icons.info_outline, "Reason",
                    request["reason"] ?? "No reason given"),

                const SizedBox(height: 20),

                // Accept and Decline Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Request Accepted')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showConfirmationDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Decline",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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

void _showConfirmationDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
              'Are you sure you want to decline this manual attendance request?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request Declined')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "No",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
}



// Detail tile for a clean, card-like look
Widget _detailTile(IconData icon, String label, String content) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 5),
    leading: Icon(icon, color: Colors.green[700]),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(content, style: const TextStyle(color: Colors.black54)),
  );
}
