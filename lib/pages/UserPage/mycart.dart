import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/UserPage/availablefoods.dart';
import 'package:hoteldineflutter/pages/UserPage/restaurantpayment.dart';

class Mycart extends StatefulWidget {
  @override
  MycartState createState() => MycartState();
}

class MycartState extends State<Mycart> {
  List<String> cartItems = []; // Empty list for now, simulate an empty cart
  double totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // If cart is empty, show the message and button
          if (cartItems.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You haven’t added anything to your cart!",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30), // Space between text and button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Availablefoods()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBB8506), // Custom button color
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Browse",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(cartItems[index]),
                    // You can add more details like item price here
                  );
                },
              ),
            ),

          // If cart is not empty, show total amount and Pay Now button
          if (cartItems.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'BDT ${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),

                      ),

                    ],
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Paynow()),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBB8506), // Custom button color
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Pay Now",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
