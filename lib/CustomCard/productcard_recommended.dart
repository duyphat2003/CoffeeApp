import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomMethod/executeratingdisplay.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/UI/Product/product_detail.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ProductcardRecommended extends StatefulWidget {
  late bool isDark;
  final int index;
  final Product product;
  ProductcardRecommended({
    super.key,
    required this.product,
    required this.isDark,
    required this.index,
  });

  @override
  State<ProductcardRecommended> createState() => _ProductcardRecommendedState();
}

class _ProductcardRecommendedState extends State<ProductcardRecommended> {
  var format = NumberFormat("#,###", "vi_VN");
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2.5),
      child: Card(
        color: Colors.blueGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetail(
                        isDark: widget.isDark,
                        index: 0,
                        product: widget.product,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.product.imageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// CENTER: Name + Rating + Price
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(
                          isDark: widget.isDark,
                          index: 0,
                          product: widget.product,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        widget.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Rating and review count
                      Row(
                        children: [
                          Executeratingdisplay(rate: widget.product.rating),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.product.reviewCount})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Price
                      Text(
                        '${format.format(widget.product.price)} đ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// RIGHT: Add to Cart Button
              Center(
                child: IconButton(
                  alignment: Alignment.centerRight,
                  onPressed: () {
                    setState(() {
                      CartItem cartItem = CartItem(
                        productName: widget.product.name,
                        amount: 1,
                        size: SizeOption.Small,
                        idOrder: '',
                      );
                      Product productInfo =
                          FirebaseDBManager.productService.getProductByName(
                                cartItem.productName,
                              )
                              as Product;
                      if (GlobalData.cartItemList
                          .where(
                            (element) =>
                                element.productName.trim().toLowerCase() ==
                                productInfo.name.trim().toLowerCase(),
                          )
                          .isNotEmpty) {
                        GlobalData.cartItemList
                            .firstWhere(
                              (element) =>
                                  element.productName.trim().toLowerCase() ==
                                  productInfo.name.trim().toLowerCase(),
                            )
                            .amount += cartItem
                            .amount;
                        if (GlobalData.cartItemList
                                .firstWhere(
                                  (element) =>
                                      element.productName
                                          .trim()
                                          .toLowerCase() ==
                                      productInfo.name.trim().toLowerCase(),
                                )
                                .amount >
                            10) {
                          GlobalData.cartItemList
                                  .firstWhere(
                                    (element) =>
                                        element.productName
                                            .trim()
                                            .toLowerCase() ==
                                        productInfo.name.trim().toLowerCase(),
                                  )
                                  .amount =
                              10;
                        }
                      } else {
                        GlobalData.cartItemList.add(cartItem);
                      }
                    });
                  },

                  icon: const Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.yellow,
                    size: 24.0,
                    semanticLabel: 'Thêm vào giỏ hàng',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
