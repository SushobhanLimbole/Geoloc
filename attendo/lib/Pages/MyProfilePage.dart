import 'package:attendo/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class MyProfilePage extends StatefulWidget {
  final String userName;

  MyProfilePage({super.key, required this.userName});

  @override
  _MyProfilePageState createState() => _MyProfilePageState(this.userName);
}

class _MyProfilePageState extends State<MyProfilePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditing = false;
  final String userName;

  _MyProfilePageState(this.userName);

  @override
  void initState() {
    super.initState();
    _usernameController.text = userName; // Initialize username
  }

  Future<void> _pickImage() async {
    var permissionStatus = await Permission.photos.request();

    if (permissionStatus.isGranted) {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = pickedImage;
      });
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission to access gallery denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                // Save action
                String username = _usernameController.text;
                print('Username: $username');
                if (_image != null) {
                  print('Profile Photo: ${_image!.path}');
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage:
                        _image != null ? FileImage(File(_image!.path)) : null,
                    backgroundColor: primaryColor,
                    child: _image == null
                        ? Text(userName[0],style: GoogleFonts.poppins(fontSize: 50,color: secondaryColor))
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add_a_photo,
                              color: Colors.white, size: 30),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _isEditing
                    ? TextField(
                        key: ValueKey('editTextField'),
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Icon(Icons.person, size: 30),
                          ),
                        ),
                        style: TextStyle(fontSize: 24),
                      )
                    : Text(
                        _usernameController.text,
                        key: ValueKey('displayText'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
