import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class DeleteRoom extends StatefulWidget {
  final String roomNumber;

  DeleteRoom({required this.roomNumber});

  @override
  _DeleteRoomState createState() => _DeleteRoomState();
}

class _DeleteRoomState extends State<DeleteRoom> {
  late Databases databases;
  late Client client;

  final String databaseId = '67650e170015d7a01bc8';
  final String collectionId = '6784c4dd00332fc62aeb';

  Map<String, dynamic>? roomData; // Holds room details
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeAppwrite();
    fetchRoomData();
  }

  void initializeAppwrite() {
    client = Client();
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('676506150033480a87c5');
    databases = Databases(client);
  }

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
          roomData = documentList.documents.first.data;
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

      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error deleting room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting room: $e')),
      );
    }
  }

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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteRoom();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                      Card(
                        color: Color(0xFFCFDFEF),
                        margin: const EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        // Shadow
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room Number: ${roomData!['RoomNumber']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Room Name: ${roomData!['RoomName']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Description: ${roomData!['RoomDescription']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Price: BDT ${roomData!['price']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: showDeleteConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Delete Room',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
