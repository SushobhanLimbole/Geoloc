import 'dart:async';
import 'package:attendo/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class SetGeofenceArea extends StatefulWidget {
  @override
  _SetGeofenceAreaState createState() => _SetGeofenceAreaState();
}

class _SetGeofenceAreaState extends State<SetGeofenceArea> {
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _pickedLocations = [];
  bool _showGeofences = false;

  static const double geofenceRadius = 200; // 200 meters

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Location permission is required to use the map.')),
      );
    }
  }

  Future<void> _toggleGeofence() async {
    setState(() {
      _showGeofences = !_showGeofences;
    });

    if (_showGeofences && _pickedLocations.isNotEmpty) {
      // Upload picked locations as geofences to Firestore
      for (var location in _pickedLocations) {
        await FirebaseFirestore.instance
            .collection('geofencing')
            .doc(location['id'])
            .set({
          'fence': {
            'latitude': location['fence'].latitude,
            'longitude': location['fence'].longitude,
          },
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geofences Set')),
      );
    } else if (!_showGeofences) {
      // Remove geofences from Firestore without clearing _pickedLocations
      for (var location in _pickedLocations) {
        await FirebaseFirestore.instance
            .collection('geofencing')
            .doc(location['id'])
            .delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geofences Removed')),
      );
    }
  }

  void _addPickedLocation(LatLng latLng) async {
    final String geofenceId = DateTime.now().millisecondsSinceEpoch.toString();

    // setState(() async {

      await FirebaseFirestore.instance
            .collection('geofencing')
            .doc(geofenceId)
            .set({
          'fence': {
            'latitude': latLng.latitude,
            'longitude': latLng.longitude,
          },
        });

      // _pickedLocations.add({
      //   'id': geofenceId,
      //   'fence': latLng,
      // });
    // });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Picked Location: (${latLng.latitude}, ${latLng.longitude}) with ID: $geofenceId',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removePickedLocation(String geofenceId) async {
    // Remove from the local picked locations list
    setState(() {
      _pickedLocations.removeWhere((location) => location['id'] == geofenceId);
    });

    // Check if the location exists in Firestore and delete if necessary
    final DocumentReference geofenceRef =
        FirebaseFirestore.instance.collection('geofencing').doc(geofenceId);

    try {
      final snapshot = await geofenceRef.get();

      if (snapshot.exists) {
        await geofenceRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geofence location removed from Firestore.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geofence location removed locally.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove geofence: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Geofence Area'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Add Location',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: _toggleGeofence,
            tooltip: 'Toggle Geofences',
          ),
        ],
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator(color: secondaryColor))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('geofencing')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: secondaryColor,
                  ));
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  // Clear _pickedLocations to prevent duplicates
                  _pickedLocations.clear();

                  // Update _pickedLocations with data from snapshot
                  snapshot.data!.docs.forEach((doc) {
                    var locationData = doc.data() as Map<String, dynamic>;
                    _pickedLocations.add({
                      'id': doc.id,
                      'fence': LatLng(locationData['fence']['latitude'],
                          locationData['fence']['longitude']),
                    });
                  });
                }

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

                for (var location in _pickedLocations) {
                  markers.add(
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: location['fence'],
                      child: GestureDetector(
                        onLongPress: () =>
                            _removePickedLocation(location['id']),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                  );

                  circles.add(
                    CircleMarker(
                      point: location['fence'],
                      color: Colors.lightGreenAccent.withOpacity(0.3),
                      useRadiusInMeter: true,
                      radius: geofenceRadius,
                    ),
                  );
                }

                return Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: _currentLocation!,
                        initialZoom: 17,
                        onTap: (tapPosition, latLng) {
                          _addPickedLocation(latLng);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        if (_currentLocation != null)
                          MarkerLayer(markers: markers),
                        if (_showGeofences) CircleLayer(circles: circles),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
