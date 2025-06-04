import 'package:coffeeapp/Entity/Product.dart';

class CartItem {
  late String idOrder;
  final String productName;
  final SizeOption size;
  late int amount;

  CartItem({
    required this.idOrder,
    required this.productName,
    required this.amount,
    required this.size,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    idOrder: json['idOrder'],
    productName: json['productName'],
    amount: json['amount'],
    size: stringToEnum(SizeOption.values, json['size']),
  );

  Map<String, dynamic> toJson(String idOrder) => {
    'idOrder': idOrder,
    'productName': productName,
    'size': enumToString(size),
    'amount': amount,
  };
}

// ignore: constant_identifier_names
enum SizeOption { Small, Medium, Large }
