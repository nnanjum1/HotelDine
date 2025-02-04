import 'package:flutter/material.dart';

class ManageBooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Manage Booking',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 10,
            shadowColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Room No:', style: textStyle())),
                      Expanded(child: Text('Booking ID:', style: textStyle())),
                    ],
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(child: Text('Guest:', style: textStyle())),
                      Expanded(child: Text('Duration:', style: textStyle())),
                    ],
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(child: Text('Room:', style: textStyle())),
                      Expanded(child: Text('Total Price:', style: textStyle())),
                    ],
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(child: Text('Check-in:', style: textStyle())),
                      Expanded(child: Text('Check-out:', style: textStyle())),
                    ],
                  ),
                  SizedBox(height: 8),


                  Text(
                    'Transaction ID:',
                    style: textStyle(),
                  ),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white),
                        onPressed: () {},
                        child: const Text('Guest Information'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white),
                        onPressed: () {},
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle textStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  }

  TextStyle textStyleSmall() {
    return const TextStyle(fontSize: 14);
  }
}
