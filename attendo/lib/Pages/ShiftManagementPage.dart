import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftManagementPage extends StatefulWidget {
  const ShiftManagementPage({super.key});

  @override
  _ShiftManagementPageState createState() => _ShiftManagementPageState();
}

class _ShiftManagementPageState extends State<ShiftManagementPage> {
  Map<String, String> shift = {};
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController shiftNameController = TextEditingController();
  final String shiftDocName = "test_slot";

  /// Upload shift to Firestore
  Future<void> uploadShiftToFirestore(Map<String, String> shiftData) async {
    try {
      await FirebaseFirestore.instance
          .collection('shifts')
          .doc(shiftDocName)
          .set(shiftData, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Shift uploaded successfully!",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      fetchShiftFromFirestore();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to upload shift: $e",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  /// Delete the shift from Firestore
  Future<void> deleteShiftFromFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('shifts')
          .doc(shiftDocName)
          .delete();
      setState(() {
        shift.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Shift deleted successfully!",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to delete shift: $e",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  /// Fetch shift from Firestore
  Future<void> fetchShiftFromFirestore() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('shifts')
          .doc(shiftDocName)
          .get();
      if (docSnapshot.exists) {
        setState(() {
          shift = Map<String, String>.from(docSnapshot.data() ?? {});
        });
      } else {
        setState(() {
          shift.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to fetch shift: $e",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  void showAddShiftModal(BuildContext context) {
    startTime = null;
    endTime = null;
    shiftNameController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      TextField(
                        controller: shiftNameController,
                        decoration: InputDecoration(
                          labelText: "Shift Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setModalState(() {
                              startTime = selectedTime;
                            });
                          }
                        },
                        child: Text(
                          startTime == null
                              ? "Select Start Time"
                              : "Start Time: ${startTime!.format(context)}",
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setModalState(() {
                              endTime = selectedTime;
                            });
                          }
                        },
                        child: Text(
                          endTime == null
                              ? "Select End Time"
                              : "End Time: ${endTime!.format(context)}",
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (shiftNameController.text.isNotEmpty &&
                              startTime != null &&
                              endTime != null) {
                            setState(() {
                              shift = {
                                "name": shiftNameController.text,
                                "start": startTime!.format(context),
                                "end": endTime!.format(context),
                              };
                            });
                            uploadShiftToFirestore(shift);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please fill in all fields",
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text("Add Shift",
                            style: GoogleFonts.poppins(color: Colors.white)),
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
  }

  @override
  void initState() {
    super.initState();
    fetchShiftFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shift Management"),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddShiftModal(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: shift.isNotEmpty
            ? GestureDetector(
                onLongPress: () {
                  deleteShiftFromFirestore();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${shift["name"]}: ${shift["start"]} - ${shift["end"]}",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const Icon(
                        Icons.schedule,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              )
            : const Center(
                child: Text(
                  "No shift added yet",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
      ),
    );
  }
}
