import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/cartitem.dart';

class OrderItem {
  final String id;
  final String createDate;
  final String timeOrder;
  late StatusOrder statusOrder;
  final List<CartItem> cartItems;
  final String email;

  OrderItem({
    required this.id,
    required this.createDate,
    required this.timeOrder,
    required this.statusOrder,
    required this.email,
    required this.cartItems,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    createDate: json['createDate'],
    timeOrder: json['timeOrder'],
    statusOrder: stringToEnum(StatusOrder.values, json['statusOrder']),
    email: json['email'],
    cartItems: [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createDate': createDate,
    'timeOrder': timeOrder,
    'statusOrder': enumToString(statusOrder),
    'email': email,
  };
}

// ignore: constant_identifier_names
enum StatusOrder { Waiting, Processing, Shipping, Finished }
