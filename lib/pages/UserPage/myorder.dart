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
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('676506150033480a87c5');

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

      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '67650e290037f19f628f',
      );

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
        collectionId: '679fb9fb0004c6321d63',
      );

      setState(() {
        cartItems = response.documents.where((doc) {
          return doc.data['Email'] == user.email;
        }).map((doc) {
          return {
            'documentId': doc.$id,
            'paymentMethod': doc.data['paymentMethod'],
            'TotalAmount': doc.data['TotalAmount'],
            'name': doc.data['Name'] ?? 'No Name',
            'TnxId': doc.data['TnxId'],
            'RoomNumber': doc.data['RoomNumber'] ?? 'Given Nothing',
            'OrderItemsList': doc.data['OrderItemsList'] ?? [],
            'orderItemsQuantity': doc.data['orderItemsQuantity'] ?? [],
            'orderItemsPrices': doc.data['orderItemsPrices'] ?? [],
            'Status': doc.data['Status'],
          };
        }).toList();

        totalAmount = cartItems.fold(
          0.0,
          (sum, item) => sum + (item['TotalAmount'] ?? 0.0),
        );
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching cart data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'You have no bookings history!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text('Name: ${userDetails['name']}'),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final order = cartItems[index];
                            final List orderItems =
                                order['OrderItemsList'] ?? [];
                            final List orderItemsQuantity =
                                order['orderItemsQuantity'] ?? [];
                            final List orderItemsPrices =
                                order['orderItemsPrices'] ?? [];

                            double orderTotalCost =
                                orderItems.fold(0.0, (sum, item) {
                              int itemIndex = orderItems.indexOf(item);
                              double price = double.tryParse(
                                      orderItemsPrices[itemIndex].toString()) ??
                                  0.0;
                              int quantity = int.tryParse(
                                      orderItemsQuantity[itemIndex]
                                          .toString()) ??
                                  1;
                              double itemTotalPrice = price * quantity;
                              return sum + itemTotalPrice;
                            });

                            Color statusColor =
                                order['Status'] == 'Order is ready!!'
                                    ? Colors.green
                                    : order['Status'] == 'Order cancelled'
                                        ? Colors.red
                                        : Colors.brown;

                            return Card(
                              elevation: 5,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Text(
                                          'Room: ${order['RoomNumber']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Order ID: ${order['documentId']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Payment Method: ${order['paymentMethod']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Transaction ID: ${order['TnxId']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10),
                                        Divider(),
                                        Text(
                                          'Items:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: orderItems.length,
                                          itemBuilder: (context, itemIndex) {
                                            final item = orderItems[itemIndex];
                                            double price = double.tryParse(
                                                    orderItemsPrices[itemIndex]
                                                        .toString()) ??
                                                0.0;
                                            int quantity = int.tryParse(
                                                    orderItemsQuantity[
                                                            itemIndex]
                                                        .toString()) ??
                                                1;
                                            double itemTotalPrice =
                                                price * quantity;

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: Text(
                                                '• $item (${quantity}) = BDT ${itemTotalPrice.toStringAsFixed(2)}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            );
                                          },
                                        ),
                                        Divider(),
                                        Text(
                                          'Total Price: BDT ${orderTotalCost.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        order['Status'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
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
