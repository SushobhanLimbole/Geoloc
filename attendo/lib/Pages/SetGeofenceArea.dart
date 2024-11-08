import 'dart:async';
import 'package:attendo/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class SetGeofenceArea extends StatefulWidget {
  SetGeofenceArea({required this.isAdmin,required this.userName,required this.userEmail});

  final bool isAdmin;
  final String userName;
  final String userEmail;
  @override
  _SetGeofenceAreaState createState() => _SetGeofenceAreaState(this.isAdmin,this.userName,this.userEmail);
}

class _SetGeofenceAreaState extends State<SetGeofenceArea> {
  LatLng? _currentLocation;
  LatLng? _pickedLocation;
  bool _showGeofence = false;
  Timer? _locationCheckTimer;
  final bool isAdmin;
  final String userName;
  final String userEmail;

  static const double geofenceRadius = 200; // 200 meters

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _SetGeofenceAreaState(this.isAdmin,this.userName,this.userEmail);

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
      // _locationCheckTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      //   _checkUserLocation();
      // });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Location permission is required to use the map.')),
      );
    }
  }

  // Method to toggle geofence display
  void _toggleGeofence() {
    if (_pickedLocation != null) {
      setState(() {
        _showGeofence = !_showGeofence;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_showGeofence ? 'Geofence Set' : 'Geofence Removed')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please pick a location on the map first.')),
      );
    }
  }

  // Method to check if user is within geofencing area
  // Future<void> _checkUserLocation() async {
  //   if (_pickedLocation != null) {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     LatLng userLocation = LatLng(position.latitude, position.longitude);

  //     // Calculate distance between user location and picked location
  //     final distance =
  //         Distance().as(LengthUnit.Meter, _pickedLocation!, userLocation);

  //     if (distance <= geofenceRadius) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('You are within the geofence area.')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('You are outside the geofence area.')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Set Geofence Area'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState!
              .openDrawer(), // Open drawer on icon tap
          icon: Icon(Icons.sort),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: _toggleGeofence,
            tooltip: 'Set Geofence',
          ),
        ],
      ),
      drawer: AppDrawer(
        isAdmin: isAdmin,
        userName: userName,
        userEmail: userEmail,
      ),
      body: Stack(
        children: [
          if (_currentLocation != null)
            FlutterMap(
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 17.5,
                onTap: (tapPosition, latLng) {
                  setState(() {
                    _pickedLocation = latLng;
                    _showGeofence = false; // Reset geofence display on new pick
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Picked Location: (${latLng.latitude}, ${latLng.longitude})',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentLocation!,
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                    if (_pickedLocation != null)
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _pickedLocation!,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                  ],
                ),
                if (_showGeofence && _pickedLocation != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _pickedLocation!,
                        color: Colors.lightGreen.withOpacity(0.3),
                        borderStrokeWidth: 2.0,
                        useRadiusInMeter: true,
                        radius: geofenceRadius,
                      ),
                    ],
                  ),
              ],
            ),
          if (_currentLocation == null)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
