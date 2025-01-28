import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditRoom extends StatefulWidget {
  final int roomNumber;
  final String roomName;
  final String description;
  final String category;
  final double price;
  final String imagePath;

  EditRoom({
    required this.roomNumber,
    required this.roomName,
    required this.description,
    required this.category,
    required this.price,
    required this.imagePath,
  });

  @override
  State<EditRoom> createState() => _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  late TextEditingController edRoomNumber;
  late TextEditingController edRoomName;
  late TextEditingController edRoomDescription;
  late TextEditingController edRoomCategory;
  late TextEditingController edRoomPrice;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    edRoomNumber = TextEditingController(text: widget.roomNumber.toString());
    edRoomName = TextEditingController(text: widget.roomName);
    edRoomDescription = TextEditingController(text: widget.description);
    edRoomCategory = TextEditingController(text: widget.category);
    edRoomPrice = TextEditingController(text: widget.price.toString());
  }

  @override
  void dispose() {
    edRoomNumber.dispose();
    edRoomName.dispose();
    edRoomDescription.dispose();
    edRoomCategory.dispose();
    edRoomPrice.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveRoom() {
    final updatedRoom = {
      'roomNumber': int.tryParse(edRoomNumber.text) ?? widget.roomNumber,
      'roomName': edRoomName.text,
      'description': edRoomDescription.text,
      'category': edRoomCategory.text,
      'price': double.tryParse(edRoomPrice.text) ?? widget.price.toDouble(),
      'imagePath': _image?.path ?? widget.imagePath,  // Correctly passing image path
    };

    Navigator.pop(context, updatedRoom); // Pass updated data back
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Edit Room',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Room Number
            TextFormField(
              controller: edRoomNumber,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Room number',
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

            // Room Name
            TextFormField(
              controller: edRoomName,
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

            // Room Description
            TextFormField(
              controller: edRoomDescription,
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

            // Room Category
            DropdownButtonFormField<String>(
              value: edRoomCategory.text.isNotEmpty ? edRoomCategory.text : null,
              items: ['Air Conditioning', 'Non Air Conditioning']
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  edRoomCategory.text = value ?? '';
                });
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

            // Room Price
            TextFormField(
              controller: edRoomPrice,
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

            // Room Image Container
            Container(
              width: 137,
              height: 120,
              decoration: BoxDecoration(
                image: _image != null
                    ? DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.cover,
                )
                    : widget.imagePath.isNotEmpty
                    ? DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
            ),
            SizedBox(height: 24),

            // Select Image Button
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

            // Update Room Button
            ElevatedButton(
              onPressed: _saveRoom,
              child: Text(
                'Update Room',
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
}
