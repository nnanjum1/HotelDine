import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/Database/appwriteConfig.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Database/appwriteConfig.dart';
class EditRoom extends StatefulWidget {
  final Map<String, dynamic> roomData; // Pass the room data as a map

  EditRoom({required this.roomData, required roomNumber, required roomName, required description, required category, required price});

  @override
  State<EditRoom> createState() => _EditRoom();
}



class _EditRoom extends State<EditRoom> {
  late TextEditingController roomNumber;
  late TextEditingController roomName;
  late TextEditingController roomDescription;
  late TextEditingController roomCategory;
  late TextEditingController roomPrice;
  late Databases databases;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  void initializeAppwrite() {
    // Initialize Appwrite Client
    Client client = Client();
    client
        .setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
        .setProject('676506150033480a87c5'); // Your Appwrite project ID
    databases = Databases(client);
    storage = Storage(client);
  }
  late Client client;
  late Databases database;
  late Storage storage;



  @override
  void initState() {
    super.initState();

    // Initialize Appwrite Client
    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
      ..setProject('676506150033480a87c5'); // Replace with your Appwrite project ID

    database = Databases(client);
    storage = Storage(client);

    // Initialize controllers with existing room data
    roomNumber = TextEditingController(text: widget.roomData['RoomNumber']);
    roomName = TextEditingController(text: widget.roomData['RoomName']);
    roomDescription = TextEditingController(text: widget.roomData['RoomDescription']);
    roomCategory = TextEditingController(text: widget.roomData['RoomCategory']);
    roomPrice = TextEditingController(text: widget.roomData['price'].toString());
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateRoom() async {
    try {
      String fileId = widget.roomData['ImageUrl'];

      // If a new image is selected, upload it to Appwrite
      if (_image != null) {
        fileId = ID.unique();
        await storage.createFile(
          bucketId: '6784cf9d002262613d60', // Replace with your storage bucket ID
          fileId: fileId,
          file: InputFile.fromPath(path: _image!.path),
        );
      }

      // Update room data in the database
      await database.updateDocument(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '6784c4dd00332fc62aeb', // Replace with your collection ID
        documentId: widget.roomData['\$id'], // Use the room's document ID
        data: {
          'RoomNumber': roomNumber.text,
          'RoomName': roomName.text,
          'RoomDescription': roomDescription.text,
          'RoomCategory': roomCategory.text,
          'price': double.tryParse(roomPrice.text) ?? 0.0,
          'ImageUrl': fileId,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room updated successfully')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating room: $e')),
      );
    }
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
          'Edit Room',
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
                filled: true,
                fillColor: Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: roomName,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Room name',
                filled: true,
                fillColor: Color(0xFFDCDCDC),
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
                filled: true,
                fillColor: Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: roomCategory.text,
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
                filled: true,
                fillColor: Color(0xFFDCDCDC),
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
                filled: true,
                fillColor: Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 24),
            _image != null
                ? Image.file(_image!, height: 200, fit: BoxFit.cover)
                : widget.roomData['ImageUrl'] != null
                ? Image.network(
              'https://cloud.appwrite.io/v1/storage/buckets/6784cf9d002262613d60/files/${widget.roomData['ImageUrl']}/view?project=676506150033480a87c5',
              height: 200,
              fit: BoxFit.cover,
            )
                : Container(
              height: 200,
              color: Colors.grey[300],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Change Image'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateRoom,
              child: Text('Update Room'),
            ),
          ],
        ),
      ),
    );
  }
}
