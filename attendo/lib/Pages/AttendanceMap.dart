import 'dart:async';
import 'package:attendo/Constants.dart';
import 'package:attendo/Drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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

  final requiredTimeInMinutes = 15;

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

      // Start periodic location checks every 15 seconds
      _locationCheckTimer = Timer.periodic(Duration(seconds: 15), (timer) {
        _checkUserLocation();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Location permission is required to use the map.')),
      );
    }
  }

  // Method to check if user is within geofencing area
  Future<void> _checkUserLocation() async {
    // Get user's current location with high accuracy
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng userLocation = LatLng(position.latitude, position.longitude);

    // Fetch geofences from Firestore
    final geofenceDocs =
        await FirebaseFirestore.instance.collection('geofencing').get();

    bool isInsideGeofence = false;
    for (var doc in geofenceDocs.docs) {
      double latitude = doc['fence']['latitude'];
      double longitude = doc['fence']['longitude'];
      LatLng geofenceLocation = LatLng(latitude, longitude);

      // Calculate distance between user location and geofence location
      final distance =
          Distance().as(LengthUnit.Meter, geofenceLocation, userLocation);

      if (distance <= geofenceRadius) {
        isInsideGeofence = true;

        // Reference to attendanceRecords collection for the specific attendance record
        final attendanceRef = FirebaseFirestore.instance
            .collection('attendanceRecords')
            .doc(userEmail);

        final attendanceDoc = await attendanceRef.get();

        if (!attendanceDoc.exists || attendanceDoc['checkInTime'] == null) {
          // Check-in: No check-in record, so create a new entry
          await attendanceRef.set({
            'attendanceId': attendanceRef.id,
            'userName': userName,
            'userEmail': userEmail,
            'checkInTime': Timestamp.now(),
            'checkOutTime': null,
            'geoPoint': GeoPoint(position.latitude, position.longitude),
            'status': 'Checked In',
            'validAttendance': false,
            'isManualEntry': false,
            'isPendingVerification': false,
            'verifiedBy': '',
            'reason':'',
            'totalTimeInGeofence': 0, // Initialize total time in geofence
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Checked in at geofence area.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are within the geofence area.')),
          );
        }
        break; // Exit loop as user is inside at least one geofence
      }
    }

    if (!isInsideGeofence) {
      // User is outside the geofenced area
      final attendanceRef = FirebaseFirestore.instance
          .collection('attendanceRecords')
          .doc(userEmail);

      final attendanceDoc = await attendanceRef.get();
      if (attendanceDoc.exists &&
          attendanceDoc['checkInTime'] != null &&
          attendanceDoc['checkOutTime'] == null) {
        // Check-out: Record check-out time
        final checkInTime =
            (attendanceDoc['checkInTime'] as Timestamp).toDate();
        final checkOutTime = DateTime.now();

        // Calculate session duration
        final sessionDuration = checkOutTime.difference(checkInTime);

        // Accumulate total time in geofence
        final totalTimeInGeofence =
            (attendanceDoc['totalTimeInGeofence'] ?? 0) +
                sessionDuration.inMinutes;

        if (totalTimeInGeofence >= requiredTimeInMinutes) {
          await attendanceRef.update({
            'checkOutTime': Timestamp.fromDate(checkOutTime),
            'status': 'Present',
            'totalTimeInGeofence': totalTimeInGeofence,
            'validAttendance': true,
          });
        } else {
          await attendanceRef.update({
            'checkOutTime': Timestamp.fromDate(checkOutTime),
            'status': 'Absent',
            'totalTimeInGeofence': totalTimeInGeofence,
            'validAttendance': false,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Checked out from geofence area. Total time in geofence: ${totalTimeInGeofence} minutes.')),
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
        title: Text('Attendance Map'),
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
