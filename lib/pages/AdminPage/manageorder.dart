import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserorderList extends StatefulWidget {
  @override
  MyorderState createState() => MyorderState();
}

class MyorderState extends State<UserorderList> {
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
      // Fetch all documents from Appwrite
      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8', // Replace with your database ID
        collectionId: '679fb9fb0004c6321d63', // Replace with your collection ID
      );

      setState(() {
        cartItems = response.documents.map((doc) {
          return {
            'documentId': doc.$id,
            'paymentMethod': doc.data['paymentMethod'],
            'TotalAmount':
                double.tryParse(doc.data['TotalAmount'].toString()) ??
                    0.0, // Ensure it's a double
            'name': doc.data['Name'] ?? 'No Name', // Add the 'Name' field here
            'TnxId': doc.data['TnxId'],
            'Email': doc.data['Email'],
            'OrderItemsList': doc.data['OrderItemsList'] ?? [],
            'orderItemsQuantity': doc.data['orderItemsQuantity'] ?? [],
            'orderItemsPrices': doc.data['orderItemsPrices'] ?? [],
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'My Orders',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : cartItems.isEmpty
                      ? Center(child: Text('No Orders Available'))
                      : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final order = cartItems[index];
                            final List orderItems =
                                order['OrderItemsList'] ?? [];
                            final List orderItemsQuantity =
                                order['orderItemsQuantity'] ?? [];
                            final List orderItemsPrices =
                                order['orderItemsPrices'] ?? [];

                            double orderTotalCost = 0.0;
                            for (int i = 0; i < orderItems.length; i++) {
                              double itemPrice = double.tryParse(
                                      orderItemsPrices[i].toString()) ??
                                  0.0;
                              int itemQuantity = orderItemsQuantity[i] ?? 0;
                              double itemTotalPrice = itemPrice * itemQuantity;
                              orderTotalCost += itemTotalPrice;
                            }

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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        'Payment Method: ${order['paymentMethod']}'),
                                    SizedBox(height: 10),
                                    Text('Customer Name: ${order['name']}'),
                                    SizedBox(height: 10),
                                    Divider(),
                                    Text('',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Divider(),
                                    Text(
                                      'Total Price: BDT ${order['TotalAmount'].toStringAsFixed(2)}', // Ensure TotalAmount is a double
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Text(
              'Total Amount: BDT ${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
