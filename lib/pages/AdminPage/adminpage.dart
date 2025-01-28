import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/AdminPage/restaurantbutton.dart';
import 'package:hoteldineflutter/pages/getStartedPage.dart';

import 'hotelbutton.dart';

class adminPage extends StatelessWidget {
  const adminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // Container with an image
            Container(
              width: 452,
              height: 296,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcome.png'),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 48),
                    child: Text(
                      'Hello Admin!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,  // Ensure text is visible on the image
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4.0, // Blurring effect
                            offset: Offset(0, 2), // Horizontal and vertical offsets
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              "Choose your option",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            Container(
              width: 339,
              height: 169,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/admin_hotel.png'),
                ),
              ),
              child: Center( // Center the button within the container
                child: SizedBox(
                  width: 194, // Set desired width
                  height: 30, // Set desired height
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> HotelButton()),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Align text and icon in the center
                      children: [
                        Text(
                          'Click Here',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8), // Add spacing between text and icon
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            Container(
              width: 339,
              height: 169,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/admin_restaurant.png'),
                ),
              ),
              child: Center( // Center the button within the container
                child: SizedBox(
                  width: 194, // Set desired width
                  height: 30, // Set desired height
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> RestaurantButton()),);

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Click Here',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => getStartedPage()), // Redirect to login page
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE70A0A),
                padding: const EdgeInsets.symmetric(horizontal: 47, vertical: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text(
                'Log out',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 16,),
            BottomNavigationBar(
                currentIndex: 0,

                backgroundColor: Color(0xFFE4E4E4),

                items:[

                  BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.apartment),label: 'Hotel'),
                  BottomNavigationBarItem(icon: Icon(Icons.restaurant_rounded),label: 'Restaurant')
                ]),

          ],
        ),
      ),
    );
  }
}