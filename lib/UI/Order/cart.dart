import 'dart:ui';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/dasheddivider.dart';
import 'package:coffeeapp/CustomMethod/generateCustomId.dart';
import 'package:coffeeapp/CustomMethod/getCurrentFormattedDateTime.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/Entity/tablestatus.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:intl/intl.dart';

class Cart extends StatefulWidget {
  final bool isDark;
  final int index;
  const Cart({required this.isDark, super.key, required this.index});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerDiscountCoupon =
      TextEditingController();
  TableStatus? _selectedTable;
  List<TableStatus> _tableNumbers = []; // Customize as needed

  @override
  void initState() {
    super.initState();
    LoadData();
  }

  // ignore: non_constant_identifier_names
  Future<void> LoadData() async {
    _tableNumbers = await FirebaseDBManager.tableStatusService
        .getTablesByBookingStatus(false);
  }

  // ignore: non_constant_identifier_names
  String GetSizeString(SizeOption size) {
    switch (size) {
      case SizeOption.Small:
        return "Nhỏ";
      case SizeOption.Medium:
        return "Vừa";
      case SizeOption.Large:
        return "Lớn";
    }
  }

  final f = DateFormat('yyyy-MM-dd hh:mm');
  int max = 10;
  String bankName = 'Vietcombank';
  int min = 0;
  @override
  Widget build(BuildContext context) {
    final double detailsWidth = 200; // Adjust width to fit your layout
    var format = NumberFormat("#,###", "vi_VN");

    late double subTotal = 0;
    late double deliveryCharge = 0;
    late double discount = 0;
    late double total = 0;

    for (CartItem cartItem in GlobalData.cartItemList) {
      Product product =
          FirebaseDBManager.productService.getProductByName(
                cartItem.productName,
              )
              as Product;
      subTotal += product.price * cartItem.amount;
    }

    if (_controllerDiscountCoupon.text.isNotEmpty) {
      discount = subTotal * 0.1;
    }

    total = (subTotal + deliveryCharge) - discount;

    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        // ignore: deprecated_member_use
        shadowColor: Colors.black.withOpacity(0.3),
        backgroundColor: widget.isDark ? Colors.grey[850] : Colors.brown,
        automaticallyImplyLeading: true,
        leading: IconButton(
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
          },
          icon: Icon(Icons.arrow_back, color: Colors.white70),
        ),

        title: Expanded(
          child: Center(
            child: Text(
              "Giỏ hàng",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      backgroundColor: widget.isDark ? Colors.grey[800] : Colors.brown[400],
      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Cart items
                      SizedBox(
                        height: 300,
                        child: (GlobalData.cartItemList.isEmpty)
                            ? Center(
                                child: Text(
                                  "Không có gì trong giỏ hàng. Quay lại chọn sản phẩm đi",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: GlobalData.cartItemList.length,
                                itemBuilder: (context, index) {
                                  final item = GlobalData.cartItemList[index];
                                  Product productInfo =
                                      FirebaseDBManager.productService
                                              .getProductByName(
                                                item.productName,
                                              )
                                          as Product;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Image
                                        Image.asset(
                                          productInfo.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        ),

                                        const SizedBox(width: 12),

                                        // Name, Size, Price
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                GetSizeString(item.size),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                productInfo.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${format.format(productInfo.price)} đ',
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Quantity Controls
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (item.amount > 1) {
                                                    item.amount--;
                                                  }
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                              ),
                                              color: Colors.redAccent,
                                              iconSize: 24,
                                            ),
                                            Text(
                                              '${item.amount}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (item.amount < max) {
                                                    item.amount++;
                                                  }
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                              ),
                                              color: Colors.green,
                                              iconSize: 24,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      SizedBox(height: 10),

                      // Phone
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Số điện thoại",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      TextField(
                        controller: _controllerPhone,
                        decoration: InputDecoration(
                          hintText: "Nhập số điện thoại",
                          hintStyle: TextStyle(color: Colors.orange[200]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // Name
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Họ và tên",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      TextField(
                        controller: _controllerName,
                        decoration: InputDecoration(
                          hintText: "Nhập họ và tên",
                          hintStyle: TextStyle(color: Colors.orange[200]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // Adress
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Bàn",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      //Table
                      DropdownButtonFormField<TableStatus>(
                        value: _selectedTable,
                        onChanged: (TableStatus? newValue) {
                          setState(() {
                            _selectedTable = newValue!;
                          });
                        },
                        items: _tableNumbers.map((TableStatus value) {
                          return DropdownMenuItem<TableStatus>(
                            value: value,
                            child: Text(value.nameTable),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: "Chọn bàn",
                          hintStyle: TextStyle(color: Colors.orange[200]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          prefixIcon: const Icon(
                            Icons.table_bar_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // Discount Coupon
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Phiếu giảm giá",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      //Coupon
                      TextField(
                        controller: _controllerDiscountCoupon,
                        decoration: InputDecoration(
                          hintText: "Nhập mã giảm giá",
                          hintStyle: TextStyle(color: Colors.orange[200]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          prefixIcon: const Icon(
                            Icons.card_giftcard,
                            color: Colors.redAccent,
                          ),
                          suffixIcon: SizedBox(
                            width: 100,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                elevation: 4,
                                // ignore: deprecated_member_use
                                shadowColor: Colors.black.withOpacity(0.3),
                                minimumSize: const Size(0, 0),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: Colors.lightBlueAccent,
                                textStyle: TextStyle(color: Colors.orange[400]),
                              ),
                              child: Text(
                                'Áp dụng',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[400],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //Subtotal, delivery charge, discount and total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Subtotal
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Tạm tính:', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 10),
                              Text(
                                '${format.format(subTotal)} đ',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Delivery Charges
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Phí vận chuyển:',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${format.format(deliveryCharge)} đ',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Discount
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Giảm giá:', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 10),
                              Text(
                                '${format.format(discount)} đ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DashedDivider(
                            width: detailsWidth,
                            dashWidth: 6,
                            dashSpace: 4,
                            thickness: 1,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          // Total
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Tổng cộng:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${format.format(total)} đ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          height: 56, // Optional fixed height
          child: ElevatedButton(
            onPressed: () async {
              if (_controllerName.text.isEmpty ||
                  _controllerPhone.text.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Còn thiếu thông tin')));
                return;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đặt nước uống thành công\nVui lòng chờ đợi ở bàn đã chọn và chuyển khoản qua $bankName để tiến hành xử lý đơn hàng',
                    ),
                  ),
                );
                OrderItem orderItem = OrderItem(
                  id: generateCustomId(),
                  timeOrder: getCurrentFormattedDateTime(),
                  cartItems: GlobalData.cartItemList,
                  statusOrder: StatusOrder.Waiting,
                  createDate: DateFormat(
                    'dd/MM/yyyy – HH:mm:ss',
                  ).format(DateTime.now()),
                  email: GlobalData.userDetail.email,
                );

                await FirebaseDBManager.orderService.createOrder(orderItem);

                for (CartItem cartItem in GlobalData.cartItemList) {
                  cartItem.idOrder = orderItem.id;
                  await FirebaseDBManager.cartService.addCartItem(cartItem);
                }

                GlobalData.cartItemList.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.brown,
            ),
            child: const Text(
              'Thanh toán',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
