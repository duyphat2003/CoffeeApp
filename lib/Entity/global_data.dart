import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/ads.dart';
import 'package:coffeeapp/Entity/cartitem.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/Entity/tablestatus.dart';
import 'package:coffeeapp/Entity/userdetail.dart';

class GlobalData {
  /// CART ITEMS OF ORDER
  static List<CartItem> _cartItemList = [];

  // Getter
  static List<CartItem> get cartItemList => _cartItemList;

  // Setter
  static set cartItemList(List<CartItem> value) {
    _cartItemList = value;
  }

  // userDetail
  static UserDetail _userDetail = UserDetail(
    displayName: '',
    email: '',
    password: '',
    photoURL: '',
    rank: '',
  );

  // Getter
  static UserDetail get userDetail => _userDetail;

  // Setter
  static set userDetail(UserDetail value) {
    _userDetail = value;
  }
}
