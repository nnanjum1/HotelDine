import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/UserPage/availablefoods.dart';
import 'package:hoteldineflutter/pages/UserPage/restaurantpayment.dart';

class Mycart extends StatefulWidget {
  @override
  MycartState createState() => MycartState();
}

class MycartState extends State<Mycart> {
  List<Map<String, dynamic>> cartItems = [
    {
      "name": "Burger",
      "price": 5.99,
      "image": "https://source.unsplash.com/200x200/?burger",
      "quantity": 1,
    },
    {
      "name": "Pizza",
      "price": 8.99,
      "image": "https://source.unsplash.com/200x200/?pizza",
      "quantity": 1,
    },
    {
      "name": "Pasta",
      "price": 7.49,
      "image": "https://source.unsplash.com/200x200/?pasta",
      "quantity": 1,
    },
  ]; // Removed the extra closing bracket

  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotal();
  }

  void calculateTotal() {
    double total = 0.0;
    for (var item in cartItems) {
      total += item["price"] * item["quantity"];
    }
    setState(() {
      totalAmount = total;
    });
  }

  void incrementQuantity(int index) {
    setState(() {
      cartItems[index]["quantity"]++;
      calculateTotal();
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (cartItems[index]["quantity"] > 1) {
        cartItems[index]["quantity"]--;
        calculateTotal();
      }
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
      calculateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                  var item = cartItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          // Food Image
                          Image.network(item["image"], width: 70, height: 70, fit: BoxFit.cover),

                          SizedBox(width: 10),

                          // Name & Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item["name"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text("\$${item["price"].toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.green)),
                              ],
                            ),
                          ),

                          // Increment & Decrement Buttons
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () => decrementQuantity(index),
                              ),
                              Text("${item["quantity"]}", style: TextStyle(fontSize: 16)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () => incrementQuantity(index),
                              ),
                            ],
                          ),

                          // Remove Button
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeItem(index),
                          ),
                        ],
                      ),
                    ),
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
                        'Total Amount ',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'BDT ${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Paynow()),
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
