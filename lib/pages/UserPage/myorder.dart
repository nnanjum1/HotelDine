import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fluttertoast/fluttertoast.dart';

class Myorder extends StatefulWidget {
  @override
  MyorderState createState() => MyorderState();
}

class MyorderState extends State<Myorder> {
  late Client client;
  late Databases database;
  late Account account;

  List<Map<String, dynamic>> cartItems = [];
  Map<String, dynamic> userDetails = {};
  bool isLoading = false;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();

    client = Client()
      ..setEndpoint(
          'https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
      ..setProject('676506150033480a87c5'); // Replace with your project ID

    database = Databases(client);
    account = Account(client);

    fetchCartData();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      firebase_auth.User? firebaseUser =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        Fluttertoast.showToast(msg: 'Please log in to view user details');
        return;
      }

      // Fetch user details from Appwrite
      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId:
            '67650e290037f19f628f', // Replace with your user collection ID
      );

      // Find the user document that matches the Firebase user's email
      var userDoc = response.documents.firstWhere(
        (doc) => doc.data['Email'] == firebaseUser.email,
      );

      if (userDoc != null) {
        setState(() {
          userDetails = {
            'name': userDoc.data['fullName'],
          };
        });
      } else {
        Fluttertoast.showToast(msg: 'User details not found in Appwrite');
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCartData() async {
    setState(() {
      isLoading = true; // Show the progress bar when data is being fetched
    });

    try {
      // Get the current user from Firebase
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (user == null) {
        Fluttertoast.showToast(msg: 'Please log in to view cart data');
        return;
      }

      // Fetch all documents from Appwrite
      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '679fb9fb0004c6321d63', // Replace with your collection ID
      );

      // Filter documents based on the current user's email
      setState(() {
        cartItems = response.documents.where((doc) {
          return doc.data['Email'] ==
              user.email; // Match email field in Appwrite with Firebase email
        }).map((doc) {
          return {
            'documentId': doc.$id,
            'paymentMethod': doc.data['paymentMethod'],
            'TotalAmount': doc.data['TotalAmount'],
            'name': doc.data['Name'] ?? 'No Name', // Add the 'Name' field here
            'TnxId': doc.data['TnxId'],
            'RoomNumber': doc.data['RoomNumber'] ?? 'Given Nothing',
            'OrderItemsList': doc.data['OrderItemsList'] ?? [],
            'orderItemsQuantity': doc.data['orderItemsQuantity'] ?? [],
            'orderItemsPrices': doc.data['orderItemsPrices'] ?? [],
          };
        }).toList();

        // Recalculate the total amount
        totalAmount = cartItems.fold(
          0.0,
          (sum, item) =>
              sum + (item['TotalAmount'] ?? 0.0), // Use the 'TotalAmount' field
        );
      });
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false; // Hide the progress bar after the data is fetched
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Display user details
            if (userDetails.isNotEmpty)
              Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Name: ${userDetails['name']}'),
                      Text('Email: ${userDetails['email']}'),
                      Text('Phone: ${userDetails['phone']}'),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final order = cartItems[index];
                        final List orderItems = order['OrderItemsList'] ?? [];
                        final List orderItemsQuantity =
                            order['orderItemsQuantity'] ?? [];
                        final List orderItemsPrices =
                            order['orderItemsPrices'] ?? [];

                        double orderTotalCost =
                            orderItems.fold(0.0, (sum, item) {
                          int itemIndex = orderItems.indexOf(item);
                          // Convert price and quantity to double before multiplication
                          double price = double.tryParse(
                                  orderItemsPrices[itemIndex].toString()) ??
                              0.0;
                          int quantity = int.tryParse(
                                  orderItemsQuantity[itemIndex].toString()) ??
                              1;
                          double itemTotalPrice = price * quantity;
                          return sum + itemTotalPrice;
                        });

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Room: ${order['RoomNumber']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Order ID: ${order['documentId']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Payment Method: ${order['paymentMethod']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Transaction ID: ${order['TnxId']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Divider(),
                                Text(
                                  'Items:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: orderItems.length,
                                  itemBuilder: (context, itemIndex) {
                                    final item = orderItems[itemIndex];
                                    // Convert price and quantity to double before multiplication
                                    double price = double.tryParse(
                                            orderItemsPrices[itemIndex]
                                                .toString()) ??
                                        0.0;
                                    int quantity = int.tryParse(
                                            orderItemsQuantity[itemIndex]
                                                .toString()) ??
                                        1;
                                    double itemTotalPrice = price * quantity;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Text(
                                        '• ${item} (${quantity}) = BDT (${price.toStringAsFixed(2)} x $quantity) = BDT ${itemTotalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    );
                                  },
                                ),
                                Divider(),
                                Text(
                                  'Total Price: BDT ${orderTotalCost.toStringAsFixed(2)}', // Use orderTotalCost here
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
