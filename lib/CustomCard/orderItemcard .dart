import 'dart:ui';

import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/UI/Order/historyorder.dart';
import 'package:intl/intl.dart';

class OrderItemCard extends StatefulWidget {
  final OrderItem orderItem;
  final bool isDark;
  final int index;
  const OrderItemCard({
    super.key,
    required this.orderItem,
    required this.isDark,
    required this.index,
  });

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  var format = NumberFormat("#,###", "vi_VN");
  int subtotalAmount = 0;
  double totalPrice = 0;
  String nameOrderStatus = '';
  late List<ProductFavourite> productFavouriteList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (CartItem item in widget.orderItem.cartItems) {
      Product productInfo =
          FirebaseDBManager.productService.getProductByName(item.productName)
              as Product;
      subtotalAmount += item.amount;
      totalPrice += item.amount * productInfo.price;
    }
    LoadData();
  }

  Future<void> LoadData() async {
    productFavouriteList = await FirebaseDBManager.favouriteService
        .getFavouritesByEmail(GlobalData.userDetail.email);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.orderItem.statusOrder) {
      case StatusOrder.Waiting:
        nameOrderStatus = 'Hàng chờ';
        break;
      case StatusOrder.Processing:
        nameOrderStatus = 'Đang làm';
        break;
      case StatusOrder.Shipping:
        nameOrderStatus = 'Đang giao';
        break;
      case StatusOrder.Finished:
        nameOrderStatus = 'Đã xong';
        break;
    }
    LoadData();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top: Cart Items Preview
            SizedBox(
              height: 100,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.orderItem.cartItems.length,
                  itemBuilder: (context, index) {
                    CartItem cartItem = widget.orderItem.cartItems[index];
                    Product productInfo =
                        FirebaseDBManager.productService.getProductByName(
                              cartItem.productName,
                            )
                            as Product;
                    return Container(
                      width: 220,
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              productInfo.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productInfo.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${format.format(productInfo.price)} đ',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() async {
                                if (productFavouriteList
                                    .where(
                                      (element) =>
                                          element.productName ==
                                          productInfo.name,
                                    )
                                    .isEmpty) {
                                  await FirebaseDBManager.favouriteService
                                      .addFavourite(
                                        ProductFavourite(
                                          email: GlobalData.userDetail.email,
                                          productName: productInfo.name,
                                        ),
                                      );
                                } else {
                                  await FirebaseDBManager.favouriteService
                                      .removeFavourite(
                                        GlobalData.userDetail.email,
                                        productInfo.name,
                                      );
                                }
                                LoadData();
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HistoryOrder(
                                      isDark: widget.isDark,
                                      index: widget.index,
                                    ),
                                  ),
                                );
                              });
                            },
                            child: Icon(
                              productFavouriteList
                                      .where(
                                        (element) =>
                                            element.productName ==
                                            productInfo.name,
                                      )
                                      .isNotEmpty
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  productFavouriteList
                                      .where(
                                        (element) =>
                                            element.productName ==
                                            productInfo.name,
                                      )
                                      .isNotEmpty
                                  ? Colors.redAccent
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 16),

            /// Middle section: Order Details
            Divider(color: Colors.grey[300]),

            buildOrderDetailRow('Tổng tiền:', '${format.format(totalPrice)} đ'),
            buildOrderDetailRow('Mã đơn hàng:', widget.orderItem.id),
            buildOrderDetailRow('Số lượng:', subtotalAmount.toString()),
            buildOrderDetailRow('Trạng thái:', nameOrderStatus),

            SizedBox(height: 10),

            /// Bottom Buttons: only for Finished orders
            if (widget.orderItem.statusOrder == StatusOrder.Finished)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.star_border, color: Colors.orange),
                    label: Text('Rate Product'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.refresh),
                    label: Text('Re-order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
