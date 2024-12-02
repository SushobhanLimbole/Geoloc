import 'dart:async';
import 'package:attendo/Constants.dart';
import 'package:attendo/Drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class AttendanceMap extends StatefulWidget {
  AttendanceMap({
    required this.isAdmin,
    required this.userName,
    required this.userEmail,
  });

  final bool isAdmin;
  final String userName;
  final String userEmail;

  @override
  _AttendanceMapState createState() =>
      _AttendanceMapState(this.isAdmin, this.userName, this.userEmail);
}

class _AttendanceMapState extends State<AttendanceMap> {
  LatLng? _currentLocation;
  Timer? _locationCheckTimer;
  final bool isAdmin;
  final String userName;
  final String userEmail;

  final requiredTimeInMinutes = 2;

  static const double geofenceRadius = 200; // 200 meters

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _AttendanceMapState(this.isAdmin, this.userName, this.userEmail);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _locationCheckTimer?.cancel(); // Stop timer on dispose
    super.dispose();
  }

  // Method to get the current location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Start periodic location checks every 10 seconds
      _locationCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) {
        _checkUserLocation();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Location permission is required to use the map.')),
      );
    }
  }

  Future<void> _checkUserLocation() async {
  
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  LatLng userLocation = LatLng(position.latitude, position.longitude);

  
  final geofenceDocs =
      await FirebaseFirestore.instance.collection('geofencing').get();

 
  final shiftDoc = await FirebaseFirestore.instance
      .collection('shifts')
      .doc('test_slot') 
      .get();

  if (!shiftDoc.exists) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shift data not found.')),
    );
    return;
  }

  final shiftData = shiftDoc.data()!;
  final startTime = DateFormat('HH:mm').parse(shiftData['start']);
  final endTime = DateFormat('HH:mm').parse(shiftData['end']);

  bool isInsideGeofence = false;

  for (var doc in geofenceDocs.docs) {
    double latitude = doc['fence']['latitude'];
    double longitude = doc['fence']['longitude'];
    LatLng geofenceLocation = LatLng(latitude, longitude);

    
    final distance =
        Distance().as(LengthUnit.Meter, geofenceLocation, userLocation);

    if (distance <= geofenceRadius) {
      isInsideGeofence = true;

      final monthKey = DateFormat('yyyy_MM').format(DateTime.now());
      final dayKey = DateFormat('dd').format(DateTime.now());

      final monthDocRef = FirebaseFirestore.instance
          .collection('attendanceRecords')
          .doc('$userEmail-$monthKey');

      await monthDocRef.set({'month': monthKey}, SetOptions(merge: true));

      final attendanceRef = monthDocRef.collection('dailyRecords').doc(dayKey);
      final attendanceDoc = await attendanceRef.get();

      if (!attendanceDoc.exists || attendanceDoc['checkInTime'] == null) {
        final checkInTime = DateTime.now();

        // Check if user is late
        final isLate = checkInTime.isAfter(startTime.add(Duration(minutes: 15)));

        await attendanceRef.set({
          'attendanceId': attendanceRef.id,
          'userName': userName,
          'userEmail': userEmail,
          'checkInTime': DateFormat('HH:mm').format(checkInTime).toString(),
          'checkOutTime': null,
          'geoPoint': userLocation.toString(),
          'status': isLate ? 'Absent' : 'Checked In',
          'validAttendance': !isLate,
          'isManualEntry': false,
          'isPendingVerification': false,
          'verifiedBy': '',
          'reason': '',
          'totalTimeInGeofence': 0,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User checked in successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are within the geofence area.')),
        );
      }
      break;
    }
  }

  if (!isInsideGeofence) {
    final monthKey = DateFormat('yyyy_MM').format(DateTime.now());
    final dayKey = DateFormat('dd').format(DateTime.now());

    final monthDocRef = FirebaseFirestore.instance
        .collection('attendanceRecords')
        .doc('$userEmail-$monthKey');
    
    await monthDocRef.set({'month': monthKey}, SetOptions(merge: true));
    
    final attendanceRef = monthDocRef.collection('dailyRecords').doc(dayKey);
    final attendanceDoc = await attendanceRef.get();

    if (attendanceDoc.exists &&
        attendanceDoc['checkInTime'] != null &&
        attendanceDoc['checkOutTime'] == null) {
      final checkInTimeStr = attendanceDoc['checkInTime'];
      final checkOutTime = DateTime.now();

      final checkInTime = DateFormat('HH:mm').parse(checkInTimeStr);

      // Check if the user checked out after the shift end time
      final isOnTime = checkOutTime.isAfter(endTime);

      final sessionDuration = checkOutTime.difference(checkInTime);
      final totalTimeInGeofence =
          (attendanceDoc['totalTimeInGeofence'] ?? 0) + sessionDuration.inMinutes;

      await attendanceRef.update({
        'checkOutTime': DateFormat('HH:mm').format(checkOutTime).toString(),
        'status': isOnTime ? 'Present' : 'Absent',
        'totalTimeInGeofence': totalTimeInGeofence,
        'validAttendance': isOnTime,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOnTime
                ? 'Checked out after shift end. Attendance marked as Present.'
                : 'Checked out early. Attendance marked as Absent.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are outside the geofence area.')),
      );
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
          icon: Icon(Icons.sort),
        ),
      ),
      drawer: AppDrawer(
        isAdmin: isAdmin,
        userName: userName,
        userEmail: userEmail,
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator(color: secondaryColor))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('geofencing')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Collect markers and circles for each geofence
                List<Marker> markers = [];
                List<CircleMarker> circles = [];

                markers.add(
                  Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentLocation!,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.lightBlue.withOpacity(0.2),
                            shape: BoxShape.circle),
                        child: Center(
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3)),
                          ),
                        ),
                      )),
                );

                for (var doc in snapshot.data!.docs) {
                  double latitude = doc['fence']['latitude'];
                  double longitude = doc['fence']['longitude'];
                  double radius = geofenceRadius;

                  markers.add(
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(latitude, longitude),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  );

                  circles.add(
                    CircleMarker(
                      point: LatLng(latitude, longitude),
                      color: Colors.lightGreenAccent.withOpacity(0.3),
                      useRadiusInMeter: true,
                      radius: radius,
                    ),
                  );
                }

                return Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: _currentLocation!,
                        initialZoom: 17,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        if (_currentLocation != null)
                          MarkerLayer(markers: markers),
                        CircleLayer(circles: circles),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
