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

  List<Map<String, dynamic>> cartItems = [];
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

    fetchCartData();
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
          };
        }).toList();

        // Recalculate the total amount
        totalAmount = cartItems.fold(
            0.0,
            (sum, item) =>
                sum +
                (item['TotalAmount'] ?? 0.0)); // Use the 'TotalAmount' field
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching cart: $e')));
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
                          double itemTotalPrice =
                              (orderItemsPrices[itemIndex] ?? 0.0) *
                                  (orderItemsQuantity[itemIndex] ?? 1);
                          return sum + itemTotalPrice;
                        });

                        return Card(
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
                                  'Transaction ID: ${order['TnxId']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    'Payment Method: ${order['paymentMethod']}'),
                                SizedBox(height: 10),
                                Text('Customer Name: ${order['name']}'),
                                SizedBox(height: 10),
                                Text(
                                    'Total Amount: BDT ${order['TotalAmount']}'),
                                Divider(),
                                Text('Items:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: orderItems.length,
                                  itemBuilder: (context, itemIndex) {
                                    final item = orderItems[itemIndex];
                                    final quantity =
                                        orderItemsQuantity[itemIndex];
                                    final price = orderItemsPrices[itemIndex];
                                    double itemTotalPrice =
                                        (price ?? 0.0) * (quantity ?? 1);

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
                                  'Total Price: BDT ${order['TotalAmount']}',
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
