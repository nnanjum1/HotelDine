import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class DeleteRoom extends StatefulWidget {
  final String roomNumber; // Room number to be deleted

  DeleteRoom({required this.roomNumber});

  @override
  _DeleteRoomState createState() => _DeleteRoomState();
}

class _DeleteRoomState extends State<DeleteRoom> {
  late Databases databases;
  late Client client;

  final String databaseId = '67650e170015d7a01bc8'; // Your database ID
  final String collectionId = '6784c4dd00332fc62aeb'; // Your collection ID

  Map<String, dynamic>? roomData; // Holds room details
  bool isLoading = true; // Tracks loading state

  @override
  void initState() {
    super.initState();
    initializeAppwrite();
    fetchRoomData();
  }

  // Initialize Appwrite Client
  void initializeAppwrite() {
    client = Client();
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('676506150033480a87c5');
    databases = Databases(client);
  }

  // Fetch room data by room number
  Future<void> fetchRoomData() async {
    try {
      DocumentList documentList = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('RoomNumber', widget.roomNumber),
        ],
      );

      if (documentList.documents.isNotEmpty) {
        setState(() {
          roomData =
              documentList.documents.first.data; // First matching document
          isLoading = false;
        });
      } else {
        setState(() {
          roomData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching room data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete room data from the database
  Future<void> deleteRoom() async {
    try {
      String documentId = roomData!['\$id']; // Document ID

      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room deleted successfully!')),
      );

      Navigator.of(context).pop(true); // Return success to the previous screen
    } catch (e) {
      print('Error deleting room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting room: $e')),
      );
    }
  }

  // Show confirmation dialog before deleting
  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete room #${widget.roomNumber}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                deleteRoom(); // Proceed with deletion
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Room'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomData == null
              ? const Center(child: Text('Room not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Room Number: ${roomData!['RoomNumber']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Room Name: ${roomData!['RoomName']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description: ${roomData!['RoomDescription']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Price: ${roomData!['price']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: showDeleteConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete Room'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
