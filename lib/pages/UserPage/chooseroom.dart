import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    // Pages for navigation
    final List<Widget> body = [
      _homePage(),
      Center(child: Text('Booked Page')),
      Center(child: Text('Saved Page')),
      Center(child: Text('Profile Page')),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Choose Room',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: body[currentIndex],
      bottomNavigationBar: NavigationBar(
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
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                print(
                    "Date Range: ${_dateRangeController.text}, Adults: $_adults, Children: $_children");
              },
              child: Text(
                'Search',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Date Range Picker
  Future<void> _selectDateRange() async {
    DateTime? checkInDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (checkInDate != null) {
      DateTime? checkOutDate = await showDatePicker(
        context: context,
        initialDate: checkInDate.add(Duration(days: 1)),
        firstDate: checkInDate,
        lastDate: DateTime(2100),
      );

      if (checkOutDate != null) {
        setState(() {
          _dateRangeController.text =
          "${checkInDate.toString().split(" ")[0]} - ${checkOutDate.toString().split(" ")[0]}";
        });
      }
    }
  }
}