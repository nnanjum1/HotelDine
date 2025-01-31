import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;

class RoomSelected extends StatefulWidget {
  final Map<String, dynamic> room;
  final String checkInDate;
  final String checkOutDate;
  final int totalGuests;

  const RoomSelected({
    Key? key,
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalGuests,
  }) : super(key: key);

  @override
  _RoomSelectedState createState() => _RoomSelectedState();
}

class _RoomSelectedState extends State<RoomSelected> {
  late Client client;
  late Databases database;
  firebase_auth.User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeAppwrite();
    getCurrentUser();
  }

  void initializeAppwrite() {
    client = Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('676506150033480a87c5');

    database = Databases(client);
  }

  void getCurrentUser() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    setState(() {
      currentUser = auth.currentUser;
    });

    if (currentUser != null) {
      fetchUserData(currentUser!.email);
    }
  }

  Future<void> fetchUserData(String? email) async {
    if (email == null) return;

    try {
      setState(() {
        isLoading = true;
      });

      final result = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '67650e290037f19f628f',
      );

      for (var doc in result.documents) {
        if (doc.data['email'] == email) {
          setState(() {
            userData = doc.data;
            isLoading = false;
          });
          break;
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Room'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              getCurrentUser();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading) ...[
              Center(child: CircularProgressIndicator()),
            ] else if (userData != null) ...[
              Text(
                'Selected Room: ${widget.room['roomNumber'] ?? 'N/A'}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Card(
                elevation: 10,
                shadowColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${userData!['fullName'] ?? 'N/A'}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Phone: ${userData!['phone'] ?? 'N/A'}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Date of birth: ${userData!['dob'] ?? 'N/A'}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Check-in Date: ${widget.checkInDate}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Check-out Date: ${widget.checkOutDate}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Total Amount: ${widget.room['price'] ?? 'N/A'}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Total Guests: ${widget.totalGuests}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
            Container(
              margin: const EdgeInsets.only(
                  top: 16), // Adjust the value for the desired margin
              child: ElevatedButton(
                onPressed: () {
                  // Implement payment logic
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
