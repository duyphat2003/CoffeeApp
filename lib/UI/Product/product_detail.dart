import 'dart:ui';

import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/Entity/tablestatus.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomMethod/executeratingdisplay.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Transition/menunavigationbar.dart';
import 'package:coffeeapp/UI/Order/cart.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ProductDetail extends StatefulWidget {
  late int index;
  late bool isDark;
  final Product product;
  ProductDetail({
    required this.index,
    required this.isDark,
    super.key,
    required this.product,
  });

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  var format = NumberFormat("#,###", "vi_VN");
  late int indexSize = 0;
  late int amountBuy = 1;
  int max = 10;
  int min = 1;
  // ignore: non_constant_identifier_names
  double heightBtn_Bottom = 50;

  final Map<SizeOption, String> sizes = {
    SizeOption.Small: 'Nhỏ',
    SizeOption.Medium: 'Trung bình',
    SizeOption.Large: 'Lớn',
  };
  late SizeOption currentSize;

  @override
  void initState() {
    super.initState();
    currentSize = SizeOption.Small;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,

              child: Stack(
                children: [
                  /// Product Image (header)
                  Image.asset(
                    widget.product.imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  /// Back Button on top
                  Positioned(
                    top:
                        MediaQuery.of(context).padding.top +
                        8, // Below status bar
                    left: 8,
                    child: CircleAvatar(
                      // ignore: deprecated_member_use
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      ),
                    ),
                  ),

                  /// Favourite button on top
                  Positioned(
                    top:
                        MediaQuery.of(context).padding.top +
                        8, // Below status bar
                    right: 8,
                    child: CircleAvatar(
                      // ignore: deprecated_member_use
                      backgroundColor: Colors.pink.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite_outline,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),

                  // Detail Product
                  Positioned(
                    top: 200,
                    left: 0,
                    right: 0,
                    child: SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.grey[800]
                              : Colors.brown[400],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Name + Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${format.format(widget.product.price)} đ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Row 2: Product type
                            Text(
                              'Loại sản  phẩm: ${widget.product.type.toString().split('.')[1].toString()}',
                              style: TextStyle(
                                color: Color.fromARGB(255, 94, 94, 94),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Row 3: Rating
                            Executeratingdisplay(rate: widget.product.rating),
                            const SizedBox(height: 12),

                            // Row 4: Size title and options
                            const Text(
                              'Kích cỡ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            SizedBox(
                              height: 28, // Give ListView some height
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: sizes.length,
                                itemBuilder: (context, index) {
                                  final size = sizes.entries.elementAt(index);
                                  return Container(
                                    width: 100,
                                    height: 28,
                                    margin: const EdgeInsets.only(left: 8),
                                    child: TextButton(
                                      onPressed: () {
                                        currentSize = size.key;
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.pinkAccent
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.1),
                                        foregroundColor: Colors.pinkAccent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.pinkAccent,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child: Text(size.value),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Row 5: Description
                            const Text(
                              'Mô tả',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.product.description,
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //Footer
                  Positioned(
                    bottom: 8,
                    right: 8,
                    left: 8,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: heightBtn_Bottom,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: CircleAvatar(
                            // ignore: deprecated_member_use
                            backgroundColor: Colors.pink.withOpacity(0.5),
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (amountBuy > min) amountBuy--;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          alignment: AlignmentDirectional.center,
                          width: 100,
                          height: heightBtn_Bottom,
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            amountBuy.toString(),
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(width: 10),
                        Container(
                          width: 50,
                          height: heightBtn_Bottom,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: CircleAvatar(
                            // ignore: deprecated_member_use
                            backgroundColor: Colors.pink.withOpacity(0.5),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (amountBuy < max) amountBuy++;
                                });
                              },
                            ),
                          ),
                        ),
                        Spacer(flex: 1),

                        Container(
                          width: 100,
                          height: heightBtn_Bottom,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  CartItem cartItem = CartItem(
                                    productName: widget.product.name,
                                    amount: amountBuy,
                                    size: SizeOption.Small,
                                    idOrder: '',
                                  );
                                  Product productInfo =
                                      FirebaseDBManager.productService
                                              .getProductByName(
                                                widget.product.name,
                                              )
                                          as Product;
                                  if (GlobalData.cartItemList
                                      .where(
                                        (element) =>
                                            element.productName
                                                .trim()
                                                .toLowerCase() ==
                                            cartItem.productName
                                                .trim()
                                                .toLowerCase(),
                                      )
                                      .isNotEmpty) {
                                    GlobalData.cartItemList
                                            .firstWhere(
                                              (element) =>
                                                  element.productName
                                                      .trim()
                                                      .toLowerCase() ==
                                                  productInfo.name
                                                      .trim()
                                                      .toLowerCase(),
                                            )
                                            .amount +=
                                        cartItem.amount;
                                    if (GlobalData.cartItemList
                                            .firstWhere(
                                              (element) =>
                                                  element.productName
                                                      .trim()
                                                      .toLowerCase() ==
                                                  productInfo.name
                                                      .trim()
                                                      .toLowerCase(),
                                            )
                                            .amount >
                                        10) {
                                      GlobalData.cartItemList
                                              .firstWhere(
                                                (element) =>
                                                    element.productName
                                                        .trim()
                                                        .toLowerCase() ==
                                                    productInfo.name
                                                        .trim()
                                                        .toLowerCase(),
                                              )
                                              .amount =
                                          10;
                                    }
                                  } else {
                                    GlobalData.cartItemList.add(cartItem);
                                  }
                                });
                              },
                            ),
                          ),
                        ),

                        SizedBox(width: 10),

                        Container(
                          width: 100,
                          height: heightBtn_Bottom,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: IconButton(
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  CartItem cartItem = CartItem(
                                    productName: widget.product.name,
                                    amount: amountBuy,
                                    size: SizeOption.Small,
                                    idOrder: '',
                                  );
                                  Product productInfo =
                                      FirebaseDBManager.productService
                                              .getProductByName(
                                                widget.product.name,
                                              )
                                          as Product;
                                  if (GlobalData.cartItemList
                                      .where(
                                        (element) =>
                                            element.productName
                                                .trim()
                                                .toLowerCase() ==
                                            productInfo.name
                                                .trim()
                                                .toLowerCase(),
                                      )
                                      .isNotEmpty) {
                                    GlobalData.cartItemList
                                            .firstWhere(
                                              (element) =>
                                                  element.productName
                                                      .trim()
                                                      .toLowerCase() ==
                                                  productInfo.name
                                                      .trim()
                                                      .toLowerCase(),
                                            )
                                            .amount +=
                                        cartItem.amount;
                                    if (GlobalData.cartItemList
                                            .firstWhere(
                                              (element) =>
                                                  element.productName
                                                      .trim()
                                                      .toLowerCase() ==
                                                  productInfo.name
                                                      .trim()
                                                      .toLowerCase(),
                                            )
                                            .amount >
                                        10) {
                                      GlobalData.cartItemList
                                              .firstWhere(
                                                (element) =>
                                                    element.productName
                                                        .trim()
                                                        .toLowerCase() ==
                                                    productInfo.name
                                                        .trim()
                                                        .toLowerCase(),
                                              )
                                              .amount =
                                          10;
                                    }
                                  } else {
                                    GlobalData.cartItemList.add(cartItem);
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Cart(
                                        isDark: widget.isDark,
                                        index: widget.index,
                                      ),
                                    ),
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
