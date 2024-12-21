import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/getStartedPage.dart'; // Import your login page here

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Initialize variables to hold user information
    String? name = 'Guest';
    String? emailAddress = 'No email';
    String? profilePhoto;

    if (user != null) {
      for (final providerProfile in user.providerData) {
        name = providerProfile.displayName ?? 'Guest';
        emailAddress = providerProfile.email ?? 'No email';
        profilePhoto = providerProfile.photoURL;
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(15.0), // Add padding here
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 452,
                  height: 296,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/welcome.png'),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: Text(
                          'Hey Mr/Mrs! $emailAddress',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.white,
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 48),
                        child: Text(
                          'Discover your perfect place',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Choose your option",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // First option - Hotel image and button
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/hotel.png",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Our Awesome Hotel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Action for the button
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF19A7FE),
                              padding: const EdgeInsets.symmetric(horizontal: 47, vertical: 3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text(
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
                const SizedBox(height: 16),
                // Second option - Restaurant image and button
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/restaurant.png",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Our Awesome Restaurant',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Action for the button
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF19A7FE),
                              padding: const EdgeInsets.symmetric(horizontal: 47, vertical: 3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text(
                              'Explore Menu',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Logout button
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
