import 'package:attendo/Pages/Verification.dart';
import 'package:flutter/material.dart';

class BottomSheetContent extends StatefulWidget {
  const BottomSheetContent({super.key});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final List<String> reasons = [
    "Network Issues",
    "GPS Not Working",
    "Battery Low",
    "App Error or Crash",
    "Working Outside Office Location",
    "Device Not Available",
    "Other (Specify)"
  ];

  String? selectedReason;
  bool showOtherTextField = false;
  final TextEditingController otherReasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        // padding: const EdgeInsets.all(20),
        // height: MediaQuery.of(context).size.height - 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reason For Manual Attendance',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: "Select Reason",
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder()),
              value: selectedReason,
              items: reasons.map((reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
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
              const SizedBox(height: 40),
              TextField(
                controller: otherReasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Specify Reason',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle submit action
                    final reason = selectedReason == "Other (Specify)"
                        ? otherReasonController.text
                        : selectedReason;
                    print("Submitted Reason: $reason");
                    Navigator.pop(context); // Close the bottom sheet
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerificationPage(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      // fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                   
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      // fontSize: 16,
                    ),
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
