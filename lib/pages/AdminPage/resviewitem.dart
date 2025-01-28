import 'package:flutter/material.dart';

class ViewItem extends StatefulWidget {
  @override
  _ViewItemState createState() => _ViewItemState();
}

class _ViewItemState extends State<ViewItem> {
  final List<Map<String, dynamic>> items = [
    {
      'itemName': 'Mango juice',
      'itemDescription': 'Made with fresh mango',
      'category': 'Drinks', // Fixed the category field name
      'price': 340,
      'image': 'assets/images/room1.png',
    },
    {
      'itemName': 'Apple Juice',
      'itemDescription': 'Made with fresh apples',
      'category': 'Drinks', // Fixed the category field name
      'price': 290,
      'image': 'assets/images/room1.png',
    },
    {
      'itemName': 'Orange Juice',
      'itemDescription': 'Made with fresh oranges',
      'category': 'Fastfood', // Fixed the category field name
      'price': 300,
      'image': 'assets/images/room1.png',
    },
    {
      'itemName': 'Burger',
      'itemDescription': 'Vegetable',
      'category': 'Fastfood', // Fixed the category field name
      'price': 300,
      'image': 'assets/images/room1.png',
    },

    {
      'itemName': 'Orange Juice',
      'itemDescription': 'Made with fresh oranges',
      'category': 'Fastfood', // Fixed the category field name
      'price': 300,
      'image': 'assets/images/room1.png',
    },
    {
      'itemName': 'Burger',
      'itemDescription': 'Vegetable',
      'category': 'Fastfood', // Fixed the category field name
      'price': 300,
      'image': 'assets/images/room1.png',
    },

  ];

  List<Map<String, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = items; // Initially, display all items.
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = items;
      } else {
        filteredItems = items.where((item) {
          return item['category'].toLowerCase().contains(query.toLowerCase()) ||
              item['itemName'].toString().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('View Item'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: _filterItems, // Trigger search on text input
                decoration: InputDecoration(
                  hintText: 'Search by item name or category',
                  filled: true,
                  fillColor: const Color(0xFFDCDCDC),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // GridView
            GridView.builder(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.6, // Adjust the aspect ratio as needed
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: SingleChildScrollView( // Added scroll view to the card
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            item['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 80,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {},
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {},
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  item['category'], // Corrected from itemCategory to category
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
