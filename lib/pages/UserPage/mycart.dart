import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/UserPage/availablefoods.dart';
import 'package:hoteldineflutter/pages/UserPage/restaurantpayment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mycart extends StatefulWidget {
  final String itemName;
  final String price;
  final String imageUrl;

  // Constructor to receive data from the previous screen
  Mycart({
    required this.itemName,
    required this.price,
    required this.imageUrl,
  });

  @override
  MycartState createState() => MycartState();
}

class MycartState extends State<Mycart> {
  List<Map<String, dynamic>> cartItems =
      []; // Empty list for now, simulate an empty cart
  double totalAmount = 0.0;

  late Client client;
  late Databases database;
  late Storage storage;

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

    // Add the received item to the cart on initialization
    addItemToCart();
  }

  // Function to add an item to the cart
  void addItemToCart() {
    setState(() {
      cartItems.add({
        'itemName': widget.itemName,
        'price': double.parse(widget.price),
        'image': widget.imageUrl,
        'quantity': 1, // Initial quantity is 1
      });
      totalAmount += double.parse(widget.price); // Add price of the item
    });
  }

  // Function to update the quantity and total price
  void updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]['quantity'] += change;
      if (cartItems[index]['quantity'] < 1) {
        cartItems[index]['quantity'] = 1; // Prevent negative quantity
      }
      totalAmount = 0.0;
      for (var item in cartItems) {
        totalAmount += item['price'] * item['quantity'];
      }
    });
  }

  // Function to remove an item from the cart
  void removeItemFromCart(int index) {
    setState(() {
      totalAmount -= cartItems[index]['price'] * cartItems[index]['quantity'];
      cartItems.removeAt(index);
    });
  }

  // Function to save cart data to Appwrite Database
  void saveCartToDatabase() async {
    try {
      // Insert into database
      for (var item in cartItems) {
        await database.createDocument(
          databaseId: '67650e170015d7a01bc8', // Replace with your database ID
          collectionId:
              '679d386f000950a1c082', // Replace with your collection ID
          documentId: ID.unique(),
          data: {
            'ItemName': item['itemName'],
            'Price': item['price'],
            'Quantity': item['quantity'],
          },
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving cart: $e')),
      );
    }
  }

  // Function to clear cart data from both UI and Appwrite database
  void _reloadRooms() async {
    try {
      // Clear the cart items in the Appwrite database if they exist
      for (var item in cartItems) {
        // Assuming each cart item has a unique 'documentId' to delete from the database
        await database.deleteDocument(
          databaseId: '67650e170015d7a01bc8', // Your database ID
          collectionId: '679d386f000950a1c082', // Your collection ID
          documentId: item[
              'documentId'], // Assuming you have a 'documentId' for each cart item
        );
      }

      // Clear local cart data
      setState(() {
        cartItems.clear();
        totalAmount = 0.0;
      });

      // Optionally, clear shared preferences or any other persistent storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('cart_items'); // Clear stored cart items if needed

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart data has been cleared.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing cart data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F1F1), // Custom color for app bar
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.black), // Adjust the title style
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _reloadRooms, // Calls the reload function
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16), // Add padding to the page
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // If cart is empty, show the message and button
            if (cartItems.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You haven’t added anything to your cart!",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30), // Space between text and button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Availablefoods()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Color(0xFFBB8506), // Custom button color
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Browse",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    return ListTile(
                      leading: Image.network(
                        item['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item['itemName'],
                          style: TextStyle(color: Colors.black)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BDT ${item['price']}'),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () => updateQuantity(
                                    index, -1), // Decrease quantity
                              ),
                              Text('${item['quantity']}',
                                  style: TextStyle(fontSize: 18)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,
                                    color: Colors.green),
                                onPressed: () => updateQuantity(
                                    index, 1), // Increase quantity
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItemFromCart(index),
                      ),
                    );
                  },
                ),
              ),

            // If cart is not empty, show total amount and Pay Now button
            if (cartItems.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'BDT ${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Save cart to database before navigating
                        saveCartToDatabase();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Paynow()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFFBB8506), // Custom button color
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Pay Now",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
