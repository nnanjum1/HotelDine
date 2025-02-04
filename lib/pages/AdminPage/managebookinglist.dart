import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

class UserBookingList extends StatefulWidget {
  const UserBookingList({super.key});

  @override
  State<UserBookingList> createState() => _UserBookingListState();
}

class _UserBookingListState extends State<UserBookingList> {
  late Client client;
  late Databases database;
  bool isLoading = false;
  List<Map<String, dynamic>> bookingList = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();

    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('676506150033480a87c5');

    database = Databases(client);
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '67a066880000448ec129',
      );

      List<Map<String, dynamic>> allBookings = [];
      double total = 0.0;

      for (var doc in response.documents) {
        allBookings.add({
          'documentId': doc.$id,
          'Name': doc.data['Name'] ?? 'Unknown',
          'Phone': doc.data['Phone'],
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

      setState(() {
        bookingList = allBookings;
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

  Future<void> confirmBooking(String documentId) async {
    try {
      await database.updateDocument(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '67a066880000448ec129',
        documentId: documentId,
        data: {'Status': 'Confirmed'},
      );
      fetchAllBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Confirmed Successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bookings'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingList.isEmpty
              ? const Center(
                  child: Text(
                    'No bookings found!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: bookingList.length,
                        itemBuilder: (context, index) {
                          final item = bookingList[index];
                          bool isConfirmed = item['Status'] == 'Confirmed';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${item['Name']}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
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
                                      const SizedBox(height: 15),
                                      ElevatedButton(
                                        onPressed: isConfirmed
                                            ? null
                                            : () => confirmBooking(
                                                item['documentId']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isConfirmed
                                              ? Colors.grey
                                              : Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Text(
                                          'Confirm Booking',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isConfirmed
                                          ? Colors.green
                                          : Colors.brown,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      item['Status'],
                                      style: const TextStyle(
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
