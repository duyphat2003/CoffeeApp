import 'dart:ui';
import 'package:coffeeapp/Entity/ads.dart';
import 'package:coffeeapp/Entity/categoryproduct.dart';
import 'package:coffeeapp/FirebaseCloudDB/FirebaseDBManager.dart';
import 'package:flutter/material.dart';
import 'package:coffeeapp/CustomCard/productcard_categorymain.dart';
import 'package:coffeeapp/CustomCard/productcard_recommended.dart';
import 'package:coffeeapp/Entity/Product.dart';
import 'package:coffeeapp/Entity/global_data.dart';
import 'package:coffeeapp/UI/Product/product_list.dart';
import 'package:logger/logger.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  late bool isDark;
  final ValueChanged<bool> onDarkChanged;

  Home({required this.isDark, required this.onDarkChanged, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void toggleDarkMode() {
    setState(() {
      widget.isDark = !widget.isDark;
    });

    widget.onDarkChanged(widget.isDark); // Notify parent
  }

  late List<Product> productTop10HighRatingList = [];
  late List<Product> productTop5NewestList = [];
  late List<Product> productSearchList = [];
  late int indexCategory;
  late List<Product> productsCategory = [];
  late List<CategoryProduct> categories = [];
  late List<Ads> ads = [];
  var logger = Logger();
  @override
  void initState() {
    super.initState();
    indexCategory = 0;
    // productsCategory = products.where((element) => element.type.toString(),);
  }

  Future<void> LoadData() async {
    GlobalData.userDetail = (await FirebaseDBManager.authService.getUserDetail(
      GlobalData.userDetail.email,
    ))!;

    categories = await FirebaseDBManager.categoryProductService
        .getCategoryProductList();
    productTop10HighRatingList = await FirebaseDBManager.productService
        .getTop10RatedProducts();

    productsCategory = await FirebaseDBManager.productService.getProductsByType(
      categories[indexCategory].name,
    );
    ads = await FirebaseDBManager.adsService.getAds();
  }

  Future<void> LoadProductWithCategory() async {
    productsCategory = await FirebaseDBManager.productService.getProductsByType(
      categories[indexCategory].name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 4; // 4 items visible
    return Scaffold(
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// LEFT: Avatar + Name
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(
                                  GlobalData.userDetail.photoURL,
                                ),
                                radius: 30,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(GlobalData.userDetail.displayName),
                                  Text(GlobalData.userDetail.rank),
                                ],
                              ),
                            ],
                          ),

                          /// RIGHT: Search bar
                          SizedBox(
                            width: 250,
                            height: 40,
                            child: SearchAnchor(
                              builder: (context, controller) {
                                return SearchBar(
                                  controller: controller,
                                  onTap: () => controller.openView(),
                                  onChanged: (_) => controller.openView(),
                                  onSubmitted: (value) async {
                                    if (value.trim().isEmpty ||
                                        productSearchList.isEmpty) {
                                      return; // Do nothing if empty
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Searching for: $value"),
                                      ),
                                    );
                                    controller.closeView(value);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductList(
                                          nameProduct: value.trim(),
                                          productType: "",
                                          isDark: widget.isDark,
                                          index: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: const Icon(Icons.search),
                                  trailing: <Widget>[
                                    Tooltip(
                                      message: widget.isDark
                                          ? 'Chế độ tối'
                                          : 'Chế độ sáng',
                                      child: IconButton(
                                        isSelected: widget.isDark,
                                        onPressed: () =>
                                            setState(toggleDarkMode),
                                        icon: const Icon(
                                          Icons.wb_sunny_outlined,
                                        ),
                                        selectedIcon: const Icon(
                                          Icons.brightness_2_outlined,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },

                              suggestionsBuilder: (context, controller) async {
                                // Filter your product list by the current query
                                final query = controller.text.toLowerCase();
                                productSearchList = await FirebaseDBManager
                                    .productService
                                    .searchProductsByName(query.trim());

                                // Show a message if no match is found
                                if (productSearchList.isEmpty) {
                                  return [
                                    const ListTile(
                                      title: Text('Không tìm thấy kết quả'),
                                    ),
                                  ];
                                }

                                return List<ListTile>.generate(
                                  productSearchList.length,
                                  (index) {
                                    final item = productSearchList[index].name;
                                    return ListTile(
                                      title: Text(item),
                                      onTap: () {
                                        setState(() {
                                          controller.closeView(
                                            item,
                                          ); // Optionally fill text field
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// BANNER ADS
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: SizedBox(
                          height: 200, // adjust as needed
                          child: PageView.builder(
                            itemCount: ads.length,
                            onPageChanged: (index) {
                              // Optional: update current page indicator
                            },
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(ads[index].name)),
                                  );
                                },
                                child: Image.asset(
                                  ads[index].imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// HEADER CATEGORY
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Danh mục nước uống",
                              style: TextStyle(color: Colors.orange[300]),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Xem thêm")),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductList(
                                    nameProduct: "",
                                    productType: categories[indexCategory].name
                                        .toString()
                                        .split('.')[1],
                                    isDark: widget.isDark,
                                    index: 0,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Xem Thêm",
                              style: TextStyle(color: Colors.orange[300]),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// CATEGORY LIST
                      SizedBox(
                        height: 40,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: itemWidth,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      indexCategory = index;
                                      LoadProductWithCategory();
                                    });
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 8,
                                    ),
                                    color: index == indexCategory
                                        ? Colors.green.shade100
                                        : Colors.blue.shade100,
                                    child: Center(
                                      child: Text(
                                        categories[index].displayName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// PRODUCT LIST
                      SizedBox(
                        height: 244,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: productsCategory.length,
                            itemBuilder: (context, index) {
                              final product = productsCategory[index];
                              return ProductcardCategorymain(
                                product: product,
                                isDark: widget.isDark,
                                index: 0,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// RECOMMENDED PRODUCT LIST
                      Column(
                        children: [
                          Text("Những nước uống khuyến khích nên chọn"),
                          SizedBox(height: 5),
                          SizedBox(
                            height: 600,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                    },
                                  ),
                              child: ListView.builder(
                                itemCount: productTop10HighRatingList.length,
                                itemBuilder: (context, index) {
                                  final product =
                                      productTop10HighRatingList[index];
                                  return ProductcardRecommended(
                                    product: product,
                                    isDark: widget.isDark,
                                    index: 0,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
