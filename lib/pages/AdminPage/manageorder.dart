import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

class UserOrderList extends StatefulWidget {
  @override
  MyorderState createState() => MyorderState();
}

class MyorderState extends State<UserOrderList> {
  late Client client;
  late Databases database;

  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = false;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();

    client = Client()
      ..setEndpoint(
          'https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
      ..setProject('676506150033480a87c5'); // Replace with your project ID

    database = Databases(client);

    fetchCartData();
  }

  Future<void> fetchCartData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await database.listDocuments(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '679fb9fb0004c6321d63',
      );

      setState(() {
        cartItems = response.documents.map((doc) {
          return {
            'documentId': doc.$id,
            'paymentMethod': doc.data['paymentMethod'],
            'TotalAmount': doc.data['TotalAmount'],
            'name': doc.data['Name'] ?? 'No Name',
            'TnxId': doc.data['TnxId'],
            'OrderItemsList': doc.data['OrderItemsList'] ?? [],
            'RoomNumber': doc.data['RoomNumber'] ?? 'Given Nothing',
            'orderItemsQuantity': doc.data['orderItemsQuantity'] ?? [],
            'orderItemsPrices': doc.data['orderItemsPrices'] ?? [],
          };
        }).toList();

        totalAmount = cartItems.fold(
          0.0,
          (sum, item) => sum + (item['TotalAmount'] ?? 0.0),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching cart: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
        title: Text('Order List'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchCartData,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final order = cartItems[index];
                      final List orderItems = order['OrderItemsList'] ?? [];
                      final List orderItemsQuantity =
                          order['orderItemsQuantity'] ?? [];
                      final List orderItemsPrices =
                          order['orderItemsPrices'] ?? [];

                      double orderTotalCost = orderItems.fold(0.0, (sum, item) {
                        int itemIndex = orderItems.indexOf(item);
                        double price = double.tryParse(
                                orderItemsPrices[itemIndex].toString()) ??
                            0.0;
                        int quantity = int.tryParse(
                                orderItemsQuantity[itemIndex].toString()) ??
                            1;
                        double itemTotalPrice = price * quantity;
                        return sum + itemTotalPrice;
                      });

                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Room: ${order['RoomNumber']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Order ID: ${order['documentId']}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Payment Method: ${order['paymentMethod']}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Transaction ID: ${order['TnxId']}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Divider(),
                              Text('Items:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: orderItems.length,
                                itemBuilder: (context, itemIndex) {
                                  final item = orderItems[itemIndex];
                                  double price = double.tryParse(
                                          orderItemsPrices[itemIndex]
                                              .toString()) ??
                                      0.0;
                                  int quantity = int.tryParse(
                                          orderItemsQuantity[itemIndex]
                                              .toString()) ??
                                      1;
                                  double itemTotalPrice = price * quantity;

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      '• ${item} (${quantity}) = BDT (${price.toStringAsFixed(2)} x $quantity) = BDT ${itemTotalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  );
                                },
                              ),
                              Divider(),
                              Text(
                                  'Total Price: BDT ${orderTotalCost.toStringAsFixed(2)}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
