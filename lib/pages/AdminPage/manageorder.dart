import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
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
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('676506150033480a87c5');

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
            'TotalAmount': doc.data['TotalAmount'] ?? 0.0,
            'name': doc.data['Name'] ?? 'No Name',
            'TnxId': doc.data['TnxId'],
            'OrderItemsList': doc.data['OrderItemsList'] ?? [],
            'RoomNumber': doc.data['RoomNumber'] ?? 'Given Nothing',
            'orderItemsQuantity': doc.data['orderItemsQuantity'] ?? [],
            'orderItemsPrices': doc.data['orderItemsPrices'] ?? [],
            'Status': doc.data['Status'],
          };
        }).toList();

        totalAmount =
            cartItems.fold(0.0, (sum, item) => sum + item['TotalAmount']);
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

  Future<void> confirmOrder(String documentId) async {
    try {
      await database.updateDocument(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '679fb9fb0004c6321d63',
        documentId: documentId,
        data: {'Status': 'Order is ready!!'},
      );

      fetchCartData(); // Refresh the list after updating status
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  Future<void> cancelOrder(String documentId) async {
    try {
      await database.updateDocument(
        databaseId: '67650e170015d7a01bc8',
        collectionId: '679fb9fb0004c6321d63',
        documentId: documentId,
        data: {'Status': 'Order cancelled'},
      );

      fetchCartData(); // Refresh the list after updating status
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
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

                      Color statusColor = order['Status'] == 'Order is ready!!'
                          ? Colors.green
                          : order['Status'] == 'Order cancelled'
                              ? Colors.red
                              : Colors.brown;

                      bool isOrderConfirmed =
                          order['Status'] == 'Order is ready!!';
                      bool isOrderCancelled =
                          order['Status'] == 'Order cancelled';

                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text('Room: ${order['RoomNumber']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Order ID: ${order['documentId']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      'Payment Method: ${order['paymentMethod']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Transaction ID: ${order['TnxId']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Divider(),
                                  Text('Items:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Text(
                                          '• $item (${quantity}) = BDT (${price.toStringAsFixed(2)} x $quantity) = BDT ${itemTotalPrice.toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(),
                                  Text(
                                      'Total Price: BDT ${orderTotalCost.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed:
                                            isOrderConfirmed || isOrderCancelled
                                                ? null
                                                : () => cancelOrder(
                                                    order['documentId']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel Order',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            isOrderConfirmed || isOrderCancelled
                                                ? null
                                                : () => confirmOrder(
                                                    order['documentId']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Confirm Order',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order['Status'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Order List Price: BDT ${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
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
