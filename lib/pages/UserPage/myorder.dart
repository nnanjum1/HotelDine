import 'package:flutter/material.dart';

class Myorder extends StatefulWidget {
  @override
  MyorderState createState() => MyorderState();
}

class MyorderState extends State<Myorder> {
  List<Map<String, dynamic>> orders = [
    {
      'OrderID': 'ORD123456',
      'TransactionID': 'TXN7890',
      'PaymentMethod': 'Bkash', // Added PaymentMethod
      'Status': 'Confirmed',
      'Items': [
        {'ItemName': 'Burger', 'ItemQuantity': 2, 'Price': 12.99},
        {'ItemName': 'Fries', 'ItemQuantity': 1, 'Price': 4.50},
      ],
      'DeliveryRoom': '1001',
    },
    {
      'OrderID': 'ORD123457',
      'TransactionID': 'TXN7891',
      'PaymentMethod': 'Nagad', // Added PaymentMethod
      'Status': 'Delivered',
      'Items': [
        {'ItemName': 'Pizza', 'ItemQuantity': 1, 'Price': 8.50},
        {'ItemName': 'Coke', 'ItemQuantity': 2, 'Price': 3.00},
        {'ItemName': 'Garlic Bread', 'ItemQuantity': 1, 'Price': 5.00},
      ],
    },
    {
      'OrderID': 'ORD123458',
      'TransactionID': 'TXN7892',
      'PaymentMethod': 'Rocket', // Added PaymentMethod
      'Status': 'Confirmed',
      'Items': [
        {'ItemName': 'Pasta', 'ItemQuantity': 1, 'Price': 6.00},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final List items = order['Items'] ?? []; // Handle null by providing an empty list

                  // Fetch the payment method for the current order
                  String paymentMethod = order['PaymentMethod'] ?? 'Not specified'; // Handle null

                  // Debugging: print payment method for the current order
                  print("Order ${order['OrderID']} Payment Method: $paymentMethod");

                  // Calculate total cost for the current order
                  double orderTotalCost = items.fold(0.0, (sum, item) {
                    double itemTotalPrice = (item['Price'] ?? 0.0) * (item['ItemQuantity'] ?? 1);
                    return sum + itemTotalPrice;
                  });
                  String status = order['Status'] ?? 'Unknown';

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
                          Text('Payment Method: $paymentMethod'), // Payment method before transaction ID
                          Text('Transaction ID: ${order['TransactionID']}'),
                          SizedBox(height: 10),
                          Text('Status: $status'),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: order['DeliveryRoom'] != null
                                ? Text(
                              'Deliver to Room No: ${order['DeliveryRoom']}',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            )
                                : Container(), // Empty container if room number is not available
                          ),
                          SizedBox(height: 10),
                          Divider(),
                          Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: items.length,
                            itemBuilder: (context, itemIndex) {
                              final item = items[itemIndex];
                              double itemTotalPrice = (item['Price'] ?? 0.0) * (item['ItemQuantity'] ?? 1);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '• ${item['ItemName']} (${item['ItemQuantity']}) = BDT (${item['Price'].toStringAsFixed(2)} x ${item['ItemQuantity']}) = BDT ${itemTotalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            },
                          ),
                          Divider(),
                          Text(
                            'Total Price: \BDT ${orderTotalCost.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
}
