import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:hoteldineflutter/pages/UserPage/myorder.dart';
import 'dart:typed_data';
import 'package:hoteldineflutter/pages/UserPage/myprofile.dart';
import 'package:hoteldineflutter/pages/UserPage/mycart.dart';


class Availablefoods extends StatefulWidget {
  @override
  AvailablefoodsState createState() => AvailablefoodsState();
}

class AvailablefoodsState extends State<Availablefoods> {
  int currentIndex = 0;

  late Client client;
  late Databases database;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;

  List<String> categories = ['All', 'Platter', 'Drinks', 'Appetizers', 'Dessert', 'Beverages'];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
      ..setProject('676506150033480a87c5'); // Replace with your project ID

    database = Databases(client);

    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true; // Show loading indicator before fetching
    });
    try {
      final result = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '679914b6002ca53ab39b', // Replace with your collection ID
      );

      setState(() {
        items = result.documents.map((doc) {
          return {
            'documentId': doc.$id, // Store the document ID
            'itemName': doc.data['FoodItemName'],
            'itemDescription': doc.data['Description'],
            'category': doc.data['Category'],
            'price': doc.data['Price'],
            'image': doc.data['ImageUrl'], // Use the stored image URL
          };
        }).toList();

        filteredItems = items;
        isLoading = false; // Hide loading indicator after fetching
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading indicator if there's an error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = items.where((item) {
        bool matchesSearch = item['itemName']
            .toLowerCase()
            .contains(query.toLowerCase());
        bool matchesCategory = selectedCategory == 'All' ||
            item['category'] == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> body = [
      _homePage(),
      Mycart(),
     Myorder(),
      myprofile(),
    ];

    final List<String> appBarTitles = [
      'Available Food',
      'Cart',
      'Order History',
      'Profile',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          appBarTitles[currentIndex],
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Reload icon
            onPressed: fetchItems, // Call reload function
          ),
        ],
      ),
      body: body[currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Order'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _homePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while data is being fetched
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search Field
                  Flexible(
                    flex: 3,
                    child: TextField(
                      onChanged: _filterItems,
                      decoration: InputDecoration(
                        hintText: 'Item name',
                        hintStyle: TextStyle(color: Color(0xFFC8BEBE)),
                        filled: true,
                        fillColor: const Color(0x4EE4ECDD),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Space between search and dropdown
                  // Dropdown with fixed width
                  SizedBox(
                    width: 130, // Adjust as needed
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                          _filterItems('');
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0x4EE4ECDD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.5,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            'https://cloud.appwrite.io/v1/storage/buckets/6784cf9d002262613d60/files/${item['image']}/view?project=676506150033480a87c5',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['itemName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item['itemDescription'],
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item['category'],
                                  style: TextStyle(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'BDT ${item['price']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end, // Aligns the child to the right
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Handle the click action here
                                        print('Text clicked');
                                      },
                                      child: Text(
                                        'ADD TO CART',
                                        style: TextStyle(
                                          color: Color(0xFFBB8506),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                )


                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
