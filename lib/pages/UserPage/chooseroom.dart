import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'dart:typed_data';
import 'package:hoteldineflutter/pages/UserPage/detailsofroom.dart';
import 'package:hoteldineflutter/pages/UserPage/myprofile.dart';
import 'package:hoteldineflutter/pages/UserPage/roomselected.dart';

class ChooseRoom extends StatefulWidget {
  @override
  ChooseRoomState createState() => ChooseRoomState();
}

class ChooseRoomState extends State<ChooseRoom> {
  int currentIndex = 0;
  TextEditingController _dateRangeController = TextEditingController();
  bool _isGuestSectionExpanded = false;
  int _adults = 1;
  int _children = 0;

  int get totalGuest => _adults + _children;

  final List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> filteredRooms = [];
  late Databases databases;
  late Storage storage;
  bool isLoading = true; // Add this flag to track the loading state
  final String databaseId =
      '67650e170015d7a01bc8'; // Replace with your database ID
  final String collectionId = '6784c4dd00332fc62aeb';

  @override
  void initState() {
    super.initState();
    initializeAppwrite();
    fetchRooms();
  }

  void initializeAppwrite() {
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('676506150033480a87c5');
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

  Future<void> _reloadRooms() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    await fetchRooms(); // Reload data
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> body = [
      _homePage(),
      Center(child: Text('Booked Page')),
      Center(child: Text('Saved Page')),
      myprofile(),
    ];

    final List<String> appBarTitles = [
      'Choose Room',
      'Booked Rooms',
      'Saved',
      'Profile',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          appBarTitles[currentIndex],
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _reloadRooms,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loader while fetching data
          : body[currentIndex], // Show page content once data is loaded
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Booked'),
          NavigationDestination(icon: Icon(Icons.save), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _homePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check-in and Check-out
          TextField(
            controller: _dateRangeController,
            decoration: InputDecoration(
              labelText: 'Check-in - Check-out',
              filled: true,
              prefixIcon: Icon(Icons.calendar_today),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            readOnly: true,
            onTap: _selectDateRange,
          ),
          SizedBox(height: 20),
          // Guests Section
          GestureDetector(
            onTap: () {
              setState(() {
                _isGuestSectionExpanded = !_isGuestSectionExpanded;
                _updateSearchButtonState();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Guests: $_adults Adults, $_children Children",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Icon(
                    _isGuestSectionExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (_isGuestSectionExpanded) ...[
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Adults", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _adults > 1
                          ? () {
                              setState(() {
                                _adults--;
                                _updateSearchButtonState();
                              });
                            }
                          : null,
                      icon: Icon(Icons.remove),
                    ),
                    Text("$_adults", style: TextStyle(fontSize: 16)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _adults++;
                          _updateSearchButtonState();
                        });
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Children", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _children > 0
                          ? () {
                              setState(() {
                                _children--;
                              });
                            }
                          : null,
                      icon: Icon(Icons.remove),
                    ),
                    Text("$_children", style: TextStyle(fontSize: 16)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _children++;
                        });
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ],
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _isSearchButtonEnabled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const detailsofroom()),
                      );
                    }
                  : null, // Disable button if not enabled
              child: Text(
                'Search',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRooms.length,
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                return Card(
                  color: Color(0xFFE9FBFF),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First Column: Room details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Room no. ${room['roomNumber']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    room['roomName'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Non-refundable',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    room['description'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.free_breakfast,
                                        color: Colors.green,
                                        size: 16,
                                      ), // Breakfast icon
                                      SizedBox(
                                          width:
                                              8), // Space between icon and text
                                      Text(
                                        'Breakfast included',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.bathtub,
                                        color: Colors.green,
                                        size: 16,
                                      ), // Bathroom icon
                                      SizedBox(
                                          width:
                                              8), // Space between icon and text
                                      Text(
                                        'Private Bathroom',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.wifi,
                                        color: Colors.green,
                                        size: 16,
                                      ), // WiFi icon
                                      SizedBox(
                                          width:
                                              8), // Space between icon and text
                                      Text(
                                        'Free WiFi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    room['category'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'BDT ${room['price']}/Night',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  Text(
                                    '*Price includes VAT and tax',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Second Column: Edit and Delete buttons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.favorite_border_outlined),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: FutureBuilder<Uint8List>(
                                    future: storage.getFileDownload(
                                      bucketId: '6784cf9d002262613d60',
                                      fileId: room['image'],
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Icon(Icons.error);
                                      } else if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        );
                                      } else {
                                        return Icon(Icons.image_not_supported);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        // Image below the row
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Pass the room details to the RoomSeleted screen
                              if (_dateRangeController.text.contains(" - ")) {
                                List<String> dates =
                                    _dateRangeController.text.split(" - ");
                                String checkInDate =
                                    dates.isNotEmpty ? dates[0] : "";
                                String checkOutDate =
                                    dates.length > 1 ? dates[1] : "";

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RoomSelected(
                                      room: room,
                                      checkInDate: checkInDate,
                                      checkOutDate: checkOutDate,
                                      totalGuests: totalGuest,
                                    ),
                                  ),
                                );
                              } else {
                                // Show an error or handle the case where no date is selected
                                print(
                                    "Error: Check-in and Check-out dates are not selected.");
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.blueAccent,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: Color(0xFFE9FBFF),
                            ),
                            child: const Text(
                              'Select',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSearchButtonEnabled = false;

  // Date Range Picker
  Future<void> _selectDateRange() async {
    DateTime today = DateTime.now();
    DateTime firstSelectableDate = DateTime(today.year, today.month, today.day);

    DateTime? checkInDate = await showDatePicker(
      context: context,
      initialDate: firstSelectableDate,
      firstDate: firstSelectableDate, // Restrict past dates
      lastDate: DateTime(2100),
    );

    if (checkInDate != null) {
      DateTime? checkOutDate = await showDatePicker(
        context: context,
        initialDate: checkInDate.add(Duration(days: 1)),
        firstDate: checkInDate
            .add(Duration(days: 1)), // Checkout must be after check-in
        lastDate: DateTime(2100),
      );

      if (checkOutDate != null) {
        setState(() {
          _dateRangeController.text =
              "${checkInDate.toString().split(" ")[0]} - ${checkOutDate.toString().split(" ")[0]}";
          _updateSearchButtonState();
        });
      }
    }
  }

  void _updateSearchButtonState() {
    // Enable button only if both date range and guest numbers are valid
    setState(() {
      _isSearchButtonEnabled =
          _dateRangeController.text.isNotEmpty && _adults > 0 && _children >= 0;
    });
  }
}
