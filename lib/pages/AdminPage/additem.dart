import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:appwrite/appwrite.dart'; // Import Appwrite SDK
import 'package:appwrite/models.dart' as models; // For Appwrite models
import 'package:uuid/uuid.dart';

import '../Database/database.dart'; // For generating unique filenames

class AddItem extends StatefulWidget {
  @override
  State<AddItem> createState() => _AddItem();
}
class _AddItem extends State<AddItem> {
  final itemName = TextEditingController();
  final itemDescription = TextEditingController();
  final itemCategory = TextEditingController();
  final itemPrice = TextEditingController();


  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
          'Add Item',
          style: TextStyle(color: Colors.black),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFE4E4E4),
        currentIndex: 2,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Hotel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Restaurant',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: itemName,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Item name',
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
              controller: itemDescription,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Item description',
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
              items: ['Drinks', 'Soup','Fast food']
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                itemCategory.text = value ?? '';
              },
              decoration: InputDecoration(
                hintText: 'Item category',
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
              controller: itemPrice,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Item price',
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
              onPressed:(){},
              child: Text(
                'Insert Item',
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
    itemName.dispose();
    itemDescription.dispose();
    itemPrice.dispose();
    super.dispose();
  }
}