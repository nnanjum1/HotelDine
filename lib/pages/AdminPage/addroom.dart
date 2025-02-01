import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:appwrite/appwrite.dart'; // Import Appwrite SDK
import 'package:appwrite/models.dart' as models; // For Appwrite models
import 'package:uuid/uuid.dart';

import '../Database/database.dart'; // For generating unique filenames

class AddRoom extends StatefulWidget {
  @override
  State<AddRoom> createState() => _AddRoom();
}

class _AddRoom extends State<AddRoom> {
  final roomNumber = TextEditingController();
  final roomName = TextEditingController();
  final roomDescription = TextEditingController();
  final roomCategory = TextEditingController();
  final roomPrice = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  late Client client;
  late Databases database;
  late Storage storage;

  String? roomNumberError;

  @override
  void initState() {
    super.initState();

    // Initialize Appwrite Client
    client = Client()
      ..setEndpoint(
          'https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
      ..setProject(
          '676506150033480a87c5'); // Replace with your Appwrite project ID

    database = Databases(client);
    storage = Storage(client);
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void InsertedRoom() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    // Check if the room number is already taken
    try {
      final existingRooms = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '6784c4dd00332fc62aeb', // Replace with your collection ID
        queries: [
          Query.equal('RoomNumber', roomNumber.text),
        ],
      );

      if (existingRooms.documents.isNotEmpty) {
        setState(() {
          // Show error below the room number field
          roomNumberError =
              'Room number is already used. Please choose a different one.';
        });
        return;
      }

      setState(() {
        roomNumberError = null; // Clear error message if valid
      });

      final String fileId = ID.unique();

      try {
        // Upload the file to Appwrite Storage
        models.File uploadedFile = await storage.createFile(
          bucketId:
              '6784cf9d002262613d60', // Replace with your storage bucket ID
          fileId: fileId,
          file: InputFile.fromPath(path: _image!.path),
        );

        try {
          final addRoomCollection =
              databaseService.getCollection('AddRoomContainer');
          await addRoomCollection['create'](
            payload: {
              'RoomNumber': roomNumber.text,
              'RoomName': roomName.text,
              'RoomDescription': roomDescription.text,
              'RoomCategory': roomCategory.text,
              'price':
                  double.tryParse(roomPrice.text) ?? 0.0, // Convert to double
              'ImageUrl': fileId // Ensure it's a valid URL
            },
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room added successfully')),
          );
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding room 1: $e')),
          );
        }
      } catch (e) {
        print('Error uploading file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding room 2: $e')),
        );
      }
    } catch (e) {
      print('Error checking room number uniqueness: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking room number uniqueness: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Add room',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: roomNumber,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Room number eg.1001',
                hintStyle: TextStyle(color: Color(0xFFA2A2A2)),
                filled: true,
                fillColor: Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                errorText: roomNumberError,
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: roomName,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Room name',
                hintStyle: TextStyle(color: Color(0xFFA2A2A2)),
                filled: true,
                fillColor: const Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: roomDescription,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Room description',
                hintStyle: TextStyle(color: Color(0xFFA2A2A2)),
                filled: true,
                fillColor: const Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              items: ['Air Conditioning', 'Non Air Conditioning']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                roomCategory.text = value ?? '';
              },
              decoration: InputDecoration(
                hintText: 'Room category',
                hintStyle: TextStyle(color: Color(0xFFA2A2A2)),
                filled: true,
                fillColor: const Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: roomPrice,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Room price',
                hintStyle: TextStyle(color: Color(0xFFA2A2A2)),
                filled: true,
                fillColor: const Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: 137,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: _image != null
                    ? DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text(
                'Select Image',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF19A7FE),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: InsertedRoom,
              child: Text(
                'Insert Room',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5870E8),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    roomNumber.dispose();
    roomName.dispose();
    roomDescription.dispose();
    roomCategory.dispose();
    roomPrice.dispose();
    super.dispose();
  }
}
