import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:hoteldineflutter/pages/UserPage/mybooking.dart';
import 'dart:typed_data';
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
  final List<Map<String, dynamic>> bookedRooms = [];
  List<Map<String, dynamic>> filteredRooms = [];
  late Databases databases;
  late Storage storage;
  bool isLoading = true;
  final String databaseId = '67650e170015d7a01bc8';
  final String collectionId = '6784c4dd00332fc62aeb';
  final String BookingCollection = '67a066880000448ec129';

  @override
  void initState() {
    super.initState();
    initializeAppwrite();
    fetchRooms();
    fetchDates();
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
            'image': doc.data['ImageUrl'],
            'documentId': doc.$id,
          });
        }
        filteredRooms = rooms;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching rooms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDates() async {
    try {
      DocumentList documentList = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: BookingCollection,
      );
      setState(() {
        bookedRooms.clear();
        for (var doc in documentList.documents) {
          bookedRooms.add({
            'roomNumber': doc.data['RoomNumber'],
            'Check_in_Date': doc.data['Check_in_Date'],
            'Check_out_Date': doc.data['Check_out_date'],
          });
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching booked rooms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _reloadRooms() async {
    setState(() {
      isLoading = true;
    });
    await fetchRooms();
    await fetchDates();
  }

  bool isRoomBookedBetweenDates(
      Map<String, dynamic> room, String checkInDate, String checkOutDate) {
    for (var bookedRoom in bookedRooms) {
      if (bookedRoom['roomNumber'] == room['roomNumber']) {
        DateTime bookedCheckIn = DateTime.parse(bookedRoom['Check_in_Date']);
        DateTime bookedCheckOut = DateTime.parse(bookedRoom['Check_out_Date']);
        DateTime selectedCheckIn = DateTime.parse(checkInDate);
        DateTime selectedCheckOut = DateTime.parse(checkOutDate);

        if ((selectedCheckIn.isBefore(bookedCheckOut) ||
                selectedCheckIn.isAtSameMomentAs(bookedCheckOut)) &&
            (selectedCheckOut.isAfter(bookedCheckIn) ||
                selectedCheckOut.isAtSameMomentAs(bookedCheckIn))) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> body = [
      _homePage(),
      MyBooking(),
      myprofile(),
    ];

    final List<String> appBarTitles = [
      'Choose Room',
      'Booked Rooms',
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
          ? Center(child: CircularProgressIndicator())
          : body[currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'My Booking'),
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
                      setState(() {
                        filteredRooms = rooms.where((room) {
                          return !bookedRooms.any((bookedRoom) =>
                              bookedRoom['roomNumber'] == room['roomNumber']);
                        }).toList();
                      });
                    }
                  : null,
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
                final bookedRoom = bookedRooms.firstWhere(
                  (bookedRoom) =>
                      bookedRoom['roomNumber'] == room['roomNumber'],
                  orElse: () => {},
                );

                bool isBooked = _dateRangeController.text.contains(" - ")
                    ? isRoomBookedBetweenDates(
                        room,
                        _dateRangeController.text.split(" - ")[0],
                        _dateRangeController.text.split(" - ")[1])
                    : false;

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
                                      ),
                                      SizedBox(width: 8),
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
                                      ),
                                      SizedBox(width: 8),
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
                                      ),
                                      SizedBox(width: 8),
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
                                  ),
                                  if (bookedRoom.isNotEmpty) ...[
                                    Text(
                                      'Check-in Date: ${bookedRoom['Check_in_Date']}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Check-out Date: ${bookedRoom['Check_out_Date']}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ],
                              ),
                            ),
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
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isBooked
                                ? null
                                : () {
                                    if (_dateRangeController.text
                                        .contains(" - ")) {
                                      List<String> dates = _dateRangeController
                                          .text
                                          .split(" - ");
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
                              backgroundColor:
                                  isBooked ? Colors.grey : Color(0xFFE9FBFF),
                            ),
                            child: Text(
                              isBooked ? 'Room booked' : 'Select',
                              style: TextStyle(
                                color:
                                    isBooked ? Colors.white : Colors.blueAccent,
                              ),
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

  Future<void> _selectDateRange() async {
    DateTime today = DateTime.now();
    DateTime firstSelectableDate = DateTime(today.year, today.month, today.day);

    DateTime? checkInDate = await showDatePicker(
      context: context,
      initialDate: firstSelectableDate,
      firstDate: firstSelectableDate,
      lastDate: DateTime(2100),
    );

    if (checkInDate != null) {
      DateTime? checkOutDate = await showDatePicker(
        context: context,
        initialDate: checkInDate.add(Duration(days: 1)),
        firstDate: checkInDate.add(Duration(days: 1)),
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
    setState(() {
      _isSearchButtonEnabled =
          _dateRangeController.text.isNotEmpty && _adults > 0 && _children >= 0;
    });
  }
}
