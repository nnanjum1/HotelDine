import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:hoteldineflutter/pages/AdminPage/editroom.dart';

import 'dart:io';
import 'dart:typed_data';

import 'deleteroom.dart';

class ViewRoom extends StatefulWidget {
  @override
  _ViewRoomState createState() => _ViewRoomState();
}

class _ViewRoomState extends State<ViewRoom> {
  final List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> filteredRooms = [];
  late Databases databases;
  late Storage storage;
  bool isLoading = true; // Add this flag to track the loading state
  final String databaseId =
      '67650e170015d7a01bc8'; // Replace with your database ID
  final String collectionId =
      '6784c4dd00332fc62aeb'; // Replace with your collection ID

  @override
  void initState() {
    super.initState();
    initializeAppwrite();
    fetchRooms();
  }

  void initializeAppwrite() {
    // Initialize Appwrite Client
    Client client = Client();
    client
        .setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
        .setProject('676506150033480a87c5'); // Your Appwrite project ID
    databases = Databases(client);
    storage = Storage(client);
  }

  Future<void> fetchRooms() async {
    try {
      DocumentList documentList = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      );

      setState(() {
        rooms.clear();
        for (var doc in documentList.documents) {
          rooms.add({
            'roomNumber': doc.data['RoomNumber'],
            'roomName': doc.data['RoomName'],
            'description': doc.data['RoomDescription'],
            'category': doc.data['RoomCategory'],
            'price': doc.data['price'],
            'image': doc.data['ImageUrl'], // Ensure the URL is valid
            'documentId': doc.$id, // Store document ID for deletion
          });
        }
        filteredRooms = rooms; // Initialize filtered rooms
        isLoading = false; // Set isLoading to false after data is fetched
      });
    } catch (e) {
      print('Error fetching rooms: $e');
      setState(() {
        isLoading = false; // Set isLoading to false in case of an error
      });
    }
  }

  void _filterRooms(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRooms = rooms;
      } else {
        filteredRooms = rooms.where((room) {
          return room['category'].toLowerCase().contains(query.toLowerCase()) ||
              room['roomNumber'].toString().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _reloadRooms() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    await fetchRooms(); // Reload data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Room'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Reload icon
            onPressed: _reloadRooms, // Call reload function
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _reloadRooms, // Trigger reload on pull-to-refresh
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        onChanged: _filterRooms,
                        decoration: InputDecoration(
                          hintText: 'Search by room number or category',
                          filled: true,
                          fillColor: const Color(0xFFDCDCDC),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];
                        return Card(
                          child: ListTile(
                            leading: FutureBuilder<Uint8List>(
                              future: storage.getFileDownload(
                                bucketId: '6784cf9d002262613d60',
                                fileId: room['image'],
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Icon(Icons.error);
                                } else if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Icon(Icons.image_not_supported);
                                }
                              },
                            ),
                            title: Text(
                                'Room ${room['roomNumber']} - ${room['roomName']}'),
                            subtitle: Text(
                                '${room['description']}\n${room['category']}\nBDT ${room['price']}/Night'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditRoom(
                                          roomNumber: room['roomNumber'],
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _reloadRooms(); // Reload rooms after editing
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DeleteRoom(
                                          roomNumber: room['roomNumber'],
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _reloadRooms(); // Reload rooms after deletion
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
