import 'package:attendo/Pages/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final TextEditingController eventNameController = TextEditingController();

  void eventRequestBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      // builder: (context) {
      //   return Container(
      //     height: MediaQuery.of(context).size.height - 80,
      //     width: MediaQuery.of(context).size.width,
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: SingleChildScrollView(
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             SizedBox(height: 5),
      //             Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Text(
      //                   'Event Request',
      //                   style: GoogleFonts.poppins(fontSize: 25),
      //                 ),
      //               ],
      //             ),
      //             SizedBox(height: 15),
      //             TextFormField(
      //               controller: eventNameController,
      //               decoration: InputDecoration(
      //                 fillColor: const Color.fromARGB(255, 230, 164, 186),
      //                 hintText: 'Event Name',
      //                 hintStyle: GoogleFonts.poppins(),
      //                 border: OutlineInputBorder(
      //                     borderSide: BorderSide(),
      //                     borderRadius: BorderRadius.all(Radius.circular(15))),
      //               ),
      //               validator: (value) {
      //                 if (value == null || value.isEmpty) {
      //                   return 'Please enter the event name';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             SizedBox(height: 15),
      //             Text(   
      //               'From',
      //               style: GoogleFonts.poppins(),
      //             ),
      //             SizedBox(height: 15),
      //             TimePickerDialog(
      //               initialTime: TimeOfDay.now(),
      //               initialEntryMode: TimePickerEntryMode.inputOnly,
                    
      //             )
      //           ],
      //         ),
      //       ),
      //     ),
      //   );
      // },
      builder: (context) => BottomSheetContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  eventRequestBottomSheet();
                },
                child: Text('Bottom'))
          ],
        ),
      ),
    );
  }
}
