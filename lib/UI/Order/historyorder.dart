import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/orderItemcard%20.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';

class HistoryOrder extends StatefulWidget {
  final bool isDark;
  final int index;
  const HistoryOrder({super.key, required this.isDark, required this.index});

  @override
  State<HistoryOrder> createState() => _HistoryOrderState();
}

class _HistoryOrderState extends State<HistoryOrder> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LoadData();
  }

  late List<OrderItem> orderItemList = [];
  // ignore: non_constant_identifier_names
  Future<void> LoadData() async {
    orderItemList = await FirebaseDBManager.orderService.getOrdersByEmail(
      GlobalData.userDetail.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? Colors.grey[800] : Colors.brown[400],

      appBar: AppBar(
        backgroundColor: widget.isDark ? Colors.grey[850] : Colors.brown,
        elevation: 4.0,
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.3),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuNavigationBar(
                  isDark: widget.isDark,
                  selectedIndex: widget.index,
                ),
              ),
            );
          }, // Add navigation logic
        ),
        title: Text('Order History'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/drink/user.png",
              ), // User image
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (context, asyncSnapshot) {
          return ListView.builder(
            itemCount: orderItemList.length, // Change to your data length
            itemBuilder: (context, index) {
              OrderItem orderItem = orderItemList[index];
              return OrderItemCard(
                orderItem: orderItem,
                isDark: widget.isDark,
                index: widget.index,
              );
            },
          );
        },
      ),
    );
  }
}
