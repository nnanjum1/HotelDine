import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
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
                        'Hey Mr/Mrs! ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                    Padding(
                      padding: EdgeInsets.only(left: 48),
                      child: Text(
                        'Discover your perfect place',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Choose your option",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/hotel.png",
                      width: 180,
                      height: 200,
                    ),
                    SizedBox(width: 16), // Spacing between image and text column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Awesome Hotel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8), // Add spacing between title and description
                        Text(
                          'Experience luxurious comfort in\nour premium rooms with world-\nclass amenities. Whether you\'re\nhere for business or leisure,\nenjoy the perfect stay with\nexceptional service.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 16), // Add spacing before the button
                        ElevatedButton(
                          onPressed: () {
                            // Action for the button
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF19A7FE),
                            padding: EdgeInsets.symmetric(horizontal: 47, vertical: 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Text(
                            'Explore Rooms',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Restaurant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8), // Add spacing between title and description
                        Text(
                          'Enjoy a variety of gourmet\ndishes, crafted by expert chefs.\nFrom local favorites to\'re\ninternational flavors, our\nrestaurant promises a dining\nexperience for every taste.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 16), // Add spacing before the button
                        ElevatedButton(
                          onPressed: () {
                            // Action for the button
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF19A7FE),
                            padding: EdgeInsets.symmetric(horizontal: 47, vertical: 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Text(
                            'Explore Menu',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16), // Spacing between image and text column
                    Image.asset(
                      "assets/images/restaurant.png",
                      width: 180,
                      height: 200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
