import 'dart:ui';

import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/Entity/orderitem.dart';
import 'package:coffeeapp/Entity/productfavourite.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/menuitem.dart';
import 'package:coffeeapp/UI/Login_Register/coffeeloginregisterscreen.dart';
import 'package:coffeeapp/UI/Order/cart.dart';
import 'package:coffeeapp/UI/Order/historyorder.dart';

class Profile extends StatefulWidget {
  final bool isDark;
  const Profile({super.key, required this.isDark});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LoadData();
  }

  Future<void> LoadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getUserDetail(
      GlobalData.userDetail.email,
    ))!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: widget.isDark ? Colors.grey[800] : Colors.brown[400],
      backgroundColor: Colors.transparent,

      body: FutureBuilder<void>(
        future: LoadData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60),
                    // Avatar
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                              GlobalData.userDetail.photoURL,
                            ),
                            radius: 50,
                          ),
                          SizedBox(height: 5),
                          Text(
                            GlobalData.userDetail.displayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            GlobalData.userDetail.rank,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 3, 180),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Menu Option
                    Padding(
                      padding: EdgeInsetsGeometry.all(6),
                      child: Column(
                        children: [
                          // Information
                          MenuItem(title: "Thông tin tài khoản"),

                          // Cart
                          MenuItem(
                            title: "Giỏ hàng",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Cart(isDark: widget.isDark, index: 2),
                                ),
                              );
                            },
                          ),

                          // History
                          MenuItem(
                            title: "Lịch sử đơn hàng",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryOrder(
                                    isDark: widget.isDark,
                                    index: 2,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Setting
                          MenuItem(title: "Cài đặt"),

                          // About
                          MenuItem(title: "Về app"),

                          // Log out
                          MenuItem(
                            title: "Đăng xuất",
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CoffeeLoginRegisterScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
