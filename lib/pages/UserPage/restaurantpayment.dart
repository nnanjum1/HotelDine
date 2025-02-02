import 'dart:ffi';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fluttertoast/fluttertoast.dart';
import '../Database/appwriteConfig.dart';

class Paynow extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const Paynow({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<Paynow> createState() => _PaynowState();
}

class _PaynowState extends State<Paynow> {
  String? _selectedPaymentMethod;
  late Client client;
  late Databases database;
  bool isRoomDeliveryChecked = false;
  TextEditingController roomNumberController = TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();

  bool isLoading = false;
  List<Map<String, dynamic>> updatedCartItems = [];

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
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (user == null) {
        Fluttertoast.showToast(msg: 'Please log in to view cart data');
        return;
      }

      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '679e8489002cd468bb6b', // Replace with your collection ID
      );

      List<Map<String, dynamic>> updatedCartItems = [];
      for (var doc in response.documents) {
        if (doc.data['Email'] == user.email) {
          updatedCartItems.add({
            'documentId': doc.$id,
            'cartItemName': doc.data['cartItemName'] ?? 'Unknown Item',
            'price': (doc.data['Price'] as num?)?.toDouble() ?? 0.0,
            'imageUrl': doc.data['ImageUrl'] ?? '',
            'quantity': (doc.data['Quantity'] as num?)?.toInt() ?? 1,
            'Email': doc.data['Email'],
          });
        }
      }

      List<Map<String, dynamic>> mergedCartItems = [];
      for (var item in updatedCartItems) {
        int existingIndex = mergedCartItems.indexWhere((existingItem) =>
            existingItem['cartItemName'] == item['cartItemName']);
        if (existingIndex == -1) {
          mergedCartItems.add(item);
        } else {
          mergedCartItems[existingIndex]['quantity'] += item['quantity'];
        }
      }

      setState(() {
        this.updatedCartItems = mergedCartItems;
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

  Future<void> saveOrderHistory(String transactionId, String roomNumber) async {
    try {
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (user == null) {
        Fluttertoast.showToast(msg: 'Please log in to complete payment');
        return;
      }

      // Extracting item names, quantities, and prices from the cart
      List<String> orderItemsNames = updatedCartItems.map((item) {
        return item['cartItemName'] as String;
      }).toList();

      List<int> orderItemsQuantity = updatedCartItems.map((item) {
        return item['quantity'] as int;
      }).toList();

      // Handle null values for price, converting to string (default to '0.0' if null)
      List<String> orderItemsPrices = updatedCartItems.map((item) {
        var price = item['price']; // Get the price
        return price != null
            ? price.toString()
            : '0.0'; // If null, default to '0.0'
      }).toList();

      // Prepare order data
      final orderData = {
        'paymentMethod': _selectedPaymentMethod,
        'TnxId': transactionId,
        'RoomNumber': roomNumber,
        'TotalAmount': widget.totalAmount,
        'Email': user.email,
        'OrderItemsList': orderItemsNames, // Storing only item names
        'orderItemsQuantity': orderItemsQuantity, // Storing quantities
        'orderItemsPrices': orderItemsPrices, // Storing prices as strings
      };

      // Save to database
      await database.createDocument(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '679fb9fb0004c6321d63', // Replace with your collection ID
        documentId: ID.unique(),
        data: orderData,
      );

      Fluttertoast.showToast(msg: 'Payment confirmed and order saved!');
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  Future<void> deleteAllCartItems() async {
    try {
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (user == null) {
        Fluttertoast.showToast(msg: 'Please log in to delete cart items');
        return;
      }

      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '679e8489002cd468bb6b',
      );

      for (var doc in response.documents) {
        if (doc.data['Email'] == user.email) {
          await database.deleteDocument(
            databaseId: '67650e170015d7a01bc8',
            collectionId: '679e8489002cd468bb6b',
            documentId: doc.$id,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting cart items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = updatedCartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );

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
          'Pay now',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment methods',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              paymentOption('Bkash'),
              paymentOption('Nagad'),
              paymentOption('Rocket'),
              SizedBox(height: 20),
              ...updatedCartItems.map((item) {
                return ListTile(
                  title: Text(item['cartItemName']),
                  subtitle: Text('BDT ${item['price']} x ${item['quantity']}'),
                  trailing: Text('BDT ${item['price'] * item['quantity']}'),
                );
              }).toList(),
              SizedBox(height: 20),
              Text(
                'Total Amount: BDT ${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _transactionIdController,
                decoration: InputDecoration(
                  labelText: 'Transaction ID',
                  labelStyle: TextStyle(color: Color(0xFFC1C1CE)),
                  filled: true,
                  fillColor: Color(0xFFFEF7F7),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB9B1B1)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB9B1B1)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB9B1B1)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              CheckboxListTile(
                title: Text('Room Delivery'),
                value: isRoomDeliveryChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isRoomDeliveryChecked = value ?? false;
                  });
                },
              ),
              TextFormField(
                controller: roomNumberController,
                enabled: isRoomDeliveryChecked,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Room number eg. 1001',
                  labelStyle: TextStyle(color: Color(0xFFC1C1CE)),
                  filled: true,
                  fillColor: Color(0xFFFEF7F7),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB9B1B1)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB9B1B1)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFB9B1B1)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    String transactionId = _transactionIdController.text;
                    String roomNumber = roomNumberController.text;

                    if (isRoomDeliveryChecked && roomNumber.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Please enter a room number for delivery'),
                        ),
                      );
                    } else if (_selectedPaymentMethod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a payment method'),
                        ),
                      );
                    } else if (transactionId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a Transaction ID'),
                        ),
                      );
                    } else {
                      await saveOrderHistory(transactionId, roomNumber);
                      await deleteAllCartItems();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment completed successfully!'),
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBB8506),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Complete Payment',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentOption(String method) {
    return Row(
      children: [
        Radio<String>(
          value: method,
          groupValue: _selectedPaymentMethod,
          onChanged: (String? value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          },
        ),
        Image.asset(
          'assets/images/${method.toLowerCase()}_logo.png',
          width: 30,
          height: 30,
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
