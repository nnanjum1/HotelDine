import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fluttertoast/fluttertoast.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  late Client client;
  late Databases database;
  bool isLoading = false;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();

    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('676506150033480a87c5');

    database = Databases(client);
    fetchBookingData();
  }

  Future<void> fetchBookingData() async {
    setState(() {
      isLoading = true;
    });

    try {
      firebase_auth.User? user =
          firebase_auth.FirebaseAuth.instance.currentUser;

      if (user == null) {
        Fluttertoast.showToast(msg: 'Please log in to view bookings');
        return;
      }

      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '67a066880000448ec129',
      );

      List<Map<String, dynamic>> userBookings = [];
      double total = 0.0;

      for (var doc in response.documents) {
        if (doc.data['Email'] == user.email) {
          userBookings.add({
            'documentId': doc.$id,
            'Name': doc.data['Name'] ?? 'Unknown',
            'Phone': doc.data['Phone'],
            'DateOfBirth': doc.data['DateOfBirth'] ?? '',
            'Check_in_Date': doc.data['Check_in_Date'],
            'Check_out_date': doc.data['Check_out_date'],
            'TotalPrice':
                double.tryParse(doc.data['TotalPrice'].toString()) ?? 0.0,
            'RoomNumber': doc.data['RoomNumber'],
            'PaymentMethod': doc.data['PaymentMethod'],
            'TransactionID': doc.data['TransactionID'],
            'Status': doc.data['Status'],
            'Email': doc.data['Email'],
          });

          total += double.tryParse(doc.data['TotalPrice'].toString()) ?? 0.0;
        }
      }

      setState(() {
        cartItems = userBookings;
        totalAmount = total;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookings: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'You have no bookings yet!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];

                          Color statusColor = item['Status'] == 'Confirmed'
                              ? Colors.green
                              : item['Status'] == 'Cancelled'
                                  ? Colors.red
                                  : Colors.brown;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Name: ${item['Name']}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          item['Status'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Phone: ${item['Phone']}'),
                                  Text(
                                    'Check-in: ${item['Check_in_Date']}',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Text(
                                    'Check-out: ${item['Check_out_date']}',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Text('Room No: ${item['RoomNumber']}'),
                                  Text(
                                      'Payment: ${item['PaymentMethod']} (${item['TransactionID']})'),
                                  Text(
                                    'Total Price: ৳${item['TotalPrice'].toString()}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.blueGrey[50],
                      child: Text(
                        'Total Amount: ৳${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
    );
  }
}
