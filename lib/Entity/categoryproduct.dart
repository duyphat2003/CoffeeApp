import 'package:coffeeapp/Entity/Product.dart';

class CategoryProduct {
  final String id;
  final String createDate;
  final ProductType name;
  final String imageUrl;
  final String displayName;

  CategoryProduct({
    required this.id,
    required this.createDate,
    required this.name,
    required this.imageUrl,
    required this.displayName,
  });

  factory CategoryProduct.fromJson(Map<String, dynamic> json) =>
      CategoryProduct(
        id: json['id'],
        createDate: json['createDate'],
        name: stringToEnum(ProductType.values, json['name']),
        imageUrl: json['imageUrl'],
        displayName: json['displayName'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'createDate': createDate,
    'name': enumToString(name),
    'imageUrl': imageUrl,
    'displayName': displayName,
  };
}
