import 'package:flutter/material.dart';

class ManageOrder extends StatefulWidget {
  @override
  ManageOrderState createState() => ManageOrderState();
}

class ManageOrderState extends State<ManageOrder> {
  bool isLoading = true;
  // List of orders, initially with payment method as null or predefined
  List<Map<String, dynamic>> orders = [
    {
      'OrderID': 'ORD123456',
      'PaymentMethod': null,  // Initially null
      'TransactionID': 'TXN7890',
      'Status': 'processing',
      'Items': [
        {'ItemName': 'Burger', 'ItemQuantity': 2, 'Price': 12.99},
        {'ItemName': 'Fries', 'ItemQuantity': 1, 'Price': 4.50},
      ],
      'DeliveryRoom': '1001',
      'IsDelivered': false,
      'PhoneNumber': '123-456-7890',
    },
    {
      'OrderID': 'ORD123457',
      'PaymentMethod': null,  // Initially null
      'TransactionID': 'TXN7891',
      'Status': 'processing',
      'Items': [
        {'ItemName': 'Pizza', 'ItemQuantity': 1, 'Price': 8.50},
        {'ItemName': 'Coke', 'ItemQuantity': 2, 'Price': 3.00},
        {'ItemName': 'Garlic Bread', 'ItemQuantity': 1, 'Price': 5.00},
      ],
      'IsDelivered': false,
      'PhoneNumber': '987-654-3210',
    },
    {
      'OrderID': 'ORD123458',
      'PaymentMethod': null,  // Initially null
      'TransactionID': 'TXN7892',
      'Status': 'processing',
      'Items': [
        {'ItemName': 'Pasta', 'ItemQuantity': 1, 'Price': 6.00},
      ],
      'IsDelivered': false,
      'PhoneNumber': '555-123-4567',
    },
    {
      'OrderID': 'ORD123459',
      'PaymentMethod': null,  // Initially null
      'TransactionID': 'TXN7893',
      'Status': 'processing',
      'Items': [
        {'ItemName': 'Sushi', 'ItemQuantity': 2, 'Price': 15.00},
        {'ItemName': 'Miso Soup', 'ItemQuantity': 1, 'Price': 5.00},
      ],
      'IsDelivered': false,
      'PhoneNumber': '222-333-4444',
    },
    {
      'OrderID': 'ORD123460',
      'PaymentMethod': null,  // Initially null
      'TransactionID': 'TXN7894',
      'Status': 'processing',
      'Items': [
        {'ItemName': 'Chicken Curry', 'ItemQuantity': 1, 'Price': 10.00},
        {'ItemName': 'Rice', 'ItemQuantity': 2, 'Price': 3.50},
      ],
      'IsDelivered': false,
      'PhoneNumber': '555-666-7777',
    },
    {
      'OrderID': 'ORD123461',
      'PaymentMethod': null,  // Initially null
      'TransactionID': 'TXN7895',
      'Status': 'processing',
      'Items': [
        {'ItemName': 'Steak', 'ItemQuantity': 1, 'Price': 25.00},
        {'ItemName': 'Mashed Potatoes', 'ItemQuantity': 1, 'Price': 5.00},
      ],
      'IsDelivered': false,
      'PhoneNumber': '888-999-0000',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Simulate fetching payment methods dynamically (e.g., from an API)
    fetchPaymentMethods();
  }

  // Fetch payment method based on order
  Future<void> fetchPaymentMethods() async {
    await Future.delayed(Duration(seconds: 2));  // Simulate API call delay
    setState(() {
      // Here you would update the payment methods based on your data
      for (var order in orders) {
        // For example, you can assign payment methods dynamically:
        if (order['OrderID'] == 'ORD123456') {
          order['PaymentMethod'] = 'bKash';
        } else if (order['OrderID'] == 'ORD123457') {
          order['PaymentMethod'] = 'Nagad';
        } else if (order['OrderID'] == 'ORD123458') {
          order['PaymentMethod'] = 'Rocket';
        } else if (order['OrderID'] == 'ORD123459') {
          order['PaymentMethod'] = 'Credit Card';
        } else if (order['OrderID'] == 'ORD123460') {
          order['PaymentMethod'] = 'PayPal';
        } else {
          order['PaymentMethod'] = 'Cash on Delivery';
        }
      }
    });
  }

  // Future<void> _reloadOrder() async {
  //   setState(() {
  //     isLoading = true; // Set loading state to true
  //   });
  //   await fetchOrder(); // Reload data
  // }

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
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Reload icon
            onPressed: null, // Call reload function
          ),
        ],
        title: Text(
          'Manage Order',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final List items = order['Items'] ?? [];

                  // Calculate total cost for the current order
                  double orderTotalCost = items.fold(0.0, (sum, item) {
                    double itemTotalPrice = (item['Price'] ?? 0.0) * (item['ItemQuantity'] ?? 1);
                    return sum + itemTotalPrice;
                  });
                  String status = order['Status'] ?? 'Unknown';
                  String phoneNumber = order['PhoneNumber'] ?? 'Not available';
                  String paymentMethod = order['PaymentMethod'] ?? 'Not specified'; // Use fetched payment method

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${order['OrderID']}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text('Payment Method: $paymentMethod'),
                          Text('Transaction ID: ${order['TransactionID']}'),
                          SizedBox(height: 10),
                          Text('Status: $status'),
                          SizedBox(height: 10),
                          Text('Phone Number: $phoneNumber'),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: order['DeliveryRoom'] != null
                                ? Text(
                              'Deliver to Room No: ${order['DeliveryRoom']}',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            )
                                : Container(),
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Column(
                            children: items.map<Widget>((item) {
                              double itemTotalPrice = (item['Price'] ?? 0.0) * (item['ItemQuantity'] ?? 1);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '• ${item['ItemName']} (${item['ItemQuantity']}) = BDT (${item['Price'].toStringAsFixed(2)} x ${item['ItemQuantity']}) = BDT ${itemTotalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                          ),
                          Divider(),
                          Text(
                            'Total Price: \BDT ${orderTotalCost.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),

                          // Checkbox for delivery status
                          CheckboxListTile(
                            title: Text('Mark as Delivered'),
                            value: order['IsDelivered'],
                            onChanged: (order['Status'] == 'Confirmed') // Enable checkbox only when status is "Confirmed"
                                ? (bool? value) {
                              setState(() {
                                order['IsDelivered'] = value ?? false;
                                order['Status'] = value ?? false ? 'Delivered' : 'Confirmed';
                              });
                            }
                                : null,
                          ),

                          SizedBox(height: 10),

                          // Align the Confirm button at the bottom right of the card
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () {
                                _showConfirmationDialog(context, order);
                              },
                              child: Text('Confirm Order'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the confirmation dialog
  Future<void> _showConfirmationDialog(BuildContext context, Map<String, dynamic> order) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Order'),
          content: Text('Do you want to confirm this order?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                setState(() {
                  order['Status'] = 'Processing';  // Set status to Processing
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  order['Status'] = 'Confirmed';  // Set status to Confirmed if not delivered
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
