import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hoteldineflutter/pages/UserPage/availablefoods.dart';
// Import Paynow screen
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hoteldineflutter/pages/UserPage/restaurantpayment.dart';

class Mycart extends StatefulWidget {
  @override
  MycartState createState() => MycartState();
}

class MycartState extends State<Mycart> {
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;
  bool isLoading = false;

  late Client client;
  late Databases database;

  @override
  void initState() {
    super.initState();

    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('676506150033480a87c5');

    database = Databases(client);

    fetchCartData(); // Fetch cart data when the screen loads
  }

  Future<void> fetchCartData() async {
    setState(() {
      isLoading = true;
    });

    try {
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (user == null) {
        Fluttertoast.showToast(msg: 'Please log in to view cart data');
        return;
      }

      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '679e8489002cd468bb6b',
      );

      setState(() {
        cartItems = response.documents.where((doc) {
          return doc.data['Email'] == user.email;
        }).map((doc) {
          return {
            'documentId': doc.$id,
            'cartItemName': doc.data['cartItemName'] ?? 'Unknown Item',
            'price': (doc.data['Price'] as num?)?.toDouble() ?? 0.0,
            'quantity': (doc.data['Quantity'] as num?)?.toInt() ?? 1,
            'Email': doc.data['Email'],
          };
        }).toList();

        // Recalculate the total amount
        totalAmount = cartItems.fold(
          0.0,
          (sum, item) => sum + (item['price'] * item['quantity']),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching cart: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]['quantity'] += change;
      if (cartItems[index]['quantity'] < 1) {
        cartItems[index]['quantity'] = 1;
      }
      totalAmount = cartItems.fold(
        0.0,
        (sum, item) => sum + (item['price'] * item['quantity']),
      );
    });
  }

  void showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to delete this item from the cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                removeItemFromCart(index); // Proceed with removal
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void removeItemFromCart(int index) async {
    try {
      String documentId = cartItems[index]['documentId'];

      await database.deleteDocument(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '679e8489002cd468bb6b',
        documentId: documentId,
      );

      setState(() {
        totalAmount -= cartItems[index]['price'] * cartItems[index]['quantity'];
        cartItems.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              )
            else if (cartItems.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("You haven’t added anything to your cart!",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Availablefoods()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFBB8506),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: Text("Browse",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
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
                      title: Text(item['cartItemName'],
                          style: TextStyle(color: Colors.black)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BDT ${item['price']}'),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  updateQuantity(index, -1);
                                },
                              ),
                              Text('${item['quantity']}',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.red)),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  updateQuantity(index, 1);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => showDeleteConfirmationDialog(index)),
                    );
                  },
                ),
              ),
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
                        Text('Total Amount',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('BDT ${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Paynow(
                              cartItems:
                                  cartItems, // Pass the updated cart items
                              totalAmount: totalAmount, // Pass the total amount
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBB8506),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Pay Now",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
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
