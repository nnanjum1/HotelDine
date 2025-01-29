import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class FoodItemsEdit extends StatefulWidget {
  final String documentId;

  const FoodItemsEdit({Key? key, required this.documentId}) : super(key: key);

  @override
  State<FoodItemsEdit> createState() => _FoodItemsEditState();
}

class _FoodItemsEditState extends State<FoodItemsEdit> {
  late Client client;
  late Databases database;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool isLoading = true;
  String? _selectedCategory;
  final List<String> categories = [
    'Platter',
    'Drinks',
    'Appetizers',
    'Dessert',
    'Beverages'
  ];

  @override
  void initState() {
    super.initState();

    client = Client()
      ..setEndpoint(
          'https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
      ..setProject('676506150033480a87c5'); // Replace with your project ID

    database = Databases(client);
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    try {
      final document = await database.getDocument(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '679914b6002ca53ab39b', // Replace with your collection ID
        documentId: widget.documentId,
      );

      setState(() {
        _nameController.text = document.data['FoodItemName'];
        _descriptionController.text = document.data['Description'];
        _selectedCategory =

            document.data['Category']; // Set the selected category

        _priceController.text = document.data['Price'].toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching item details: $e')),
      );
    }
  }

  Future<void> updateItemDetails() async {
    try {
      await database.updateDocument(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '679914b6002ca53ab39b', // Replace with your collection ID
        documentId: widget.documentId,
        data: {
          'FoodItemName': _nameController.text,
          'Description': _descriptionController.text,
          'Category': _selectedCategory, // Pass selected category
          'Price': double.tryParse(_priceController.text) ?? 0.0,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully')),
      );

      Navigator.pop(context, true); // Return to previous screen and refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(

        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Item Name',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: _nameController),
            const SizedBox(height: 16),
            const Text('Description',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: _descriptionController),
            const SizedBox(height: 16),
            const Text('Category',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Price',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
                controller: _priceController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: updateItemDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                ),
                child: const Text('Save Changes',
                    style: TextStyle(color: Colors.white)),

              
              ),
            ),
          ],
        ),
      ),
    );
  }
}