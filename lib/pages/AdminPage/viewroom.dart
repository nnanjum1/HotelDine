import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/AdminPage/editroom.dart'; // Import the EditRoom page

class ViewRoom extends StatefulWidget {
  @override
  _ViewRoomState createState() => _ViewRoomState();
}

class _ViewRoomState extends State<ViewRoom> {
  final List<Map<String, dynamic>> rooms = [
    {
      'roomNumber': 1101,
      'roomName': 'Deluxe King Room',
      'description': 'Room with a king size bed',
      'category': 'Air Conditioning',
      'price': 3400,
      'image': 'assets/images/room1.png',
    },
    {
      'roomNumber': 1102,
      'roomName': 'Single Bed Room',
      'description': 'Standard bed for one person',
      'category': 'Air Conditioning',
      'price': 2800,
      'image': 'assets/images/room3.png',
    },
    {
      'roomNumber': 1103,
      'roomName': 'Double Bed Room',
      'description': 'Large size bed',
      'category': 'Non-Air Conditioning',
      'price': 2800,
      'image': 'assets/images/room2.png',
    },
  ];

  List<Map<String, dynamic>> filteredRooms = [];

  @override
  void initState() {
    super.initState();
    filteredRooms = rooms; // Initially, display all rooms.
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

  void _deleteRoom(int roomNumber) {
    setState(() {
      rooms.removeWhere((room) => room['roomNumber'] == roomNumber);
      filteredRooms = rooms; // Update the filtered list after deletion.
    });
  }

  Future<void> _showDeleteDialog(int roomNumber) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Room'),
          content: Text('Are you sure you want to delete room number $roomNumber?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteRoom(roomNumber); // Perform the deletion
                Navigator.pop(context);
              },
              child: Text('Delete'),
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
        title: Text('View Room'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: _filterRooms, // Trigger search on text input
                decoration: InputDecoration(
                  hintText: 'Search by room number or category',
                  hintStyle: TextStyle(
                    color: Colors.grey, // Set the hint text color
                  ),
                  filled: true,
                  fillColor: const Color(0xFFDCDCDC),
                  prefixIcon: Icon(Icons.search,color: Colors.grey,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Room Cards
            ListView.builder(
              shrinkWrap: true, // Required for SingleChildScrollView
              physics: NeverScrollableScrollPhysics(), // Disable ListView scrolling
              itemCount: filteredRooms.length,
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scrollable Room Details
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, // Horizontal scroll
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
                                    color: Colors.grey[600],fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  '${room['description']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.coffee, size: 12, color: Colors.green),  // Check icon
                                    SizedBox(width: 4),
                                    Text(
                                      'Breakfast included in the price',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.bathtub, size: 12, color: Colors.green),  // Check icon
                                    SizedBox(width: 4),
                                    Text(
                                      'Private bathroom',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.wifi, size: 12, color: Colors.green,),  // Check icon
                                    SizedBox(width: 4),
                                    Text(
                                      'Free wifi',
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Edit and Delete Icons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end, // Align the column's children to the end
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero, // Remove padding around the icon
                                  constraints: BoxConstraints(), // Remove size constraints for tighter fit
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditRoom(),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero, // Remove padding around the icon
                                  constraints: BoxConstraints(), // Remove size constraints for tighter fit
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(room['roomNumber']),
                                ),
                              ],
                            ),


                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                room['image'],
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFE4E4E4),
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Hotel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Restaurant',
          ),
        ],
      ),
    );
  }
}
