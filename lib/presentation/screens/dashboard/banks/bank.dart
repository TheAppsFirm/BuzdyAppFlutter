import 'package:buzdy/presentation/screens/dashboard/detailScreen.dart';
import 'package:buzdy/presentation/screens/dashboard/banks/merchnatDetailScreen.dart';
import 'package:buzdy/presentation/screens/dashboard/banks/model/bankModel.dart';
import 'package:buzdy/presentation/screens/dashboard/banks/model/merchnatModel.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/widgets/appBar.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:buzdy/core/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> merchants = [
    'Amazon',
    'Ebay',
    'Walmart',
    'BestBuy',
    'Target'
  ];

  double _rating = 2;
  final _merchantController = SingleValueDropDownController(
    data: DropDownValueModel(name: "All Marchants", value: "All Items"),
  );
  final _bankController = SingleValueDropDownController(
      data: DropDownValueModel(name: "All Banks", value: "All Items"));

  void _updateRating(double rating) {
    setState(() {
      _rating = rating;
    });
  }

  final ScrollController _scrollControllerBank = ScrollController();
  final ScrollController _scrollControllerMerchant = ScrollController();

  @override
  void initState() {
    super.initState();

    // Listen for scroll events to load more banks
    _scrollControllerBank.addListener(() {
      if (_scrollControllerBank.position.pixels >=
          _scrollControllerBank.position.maxScrollExtent - 50) {
        print("scroll end ");
        // Load more banks when near the bottom
        Provider.of<UserViewModel>(context, listen: false).getAllBanks(
            pageNumber: Provider.of<UserViewModel>(context, listen: false)
                .bankcurrentPage);
      }
    });

    // Listen for scroll events to load more merchants
    _scrollControllerMerchant.addListener(() {
      if (_scrollControllerMerchant.position.pixels >=
          _scrollControllerMerchant.position.maxScrollExtent - 100) {
        // When user reaches the end, load more data
        Provider.of<UserViewModel>(context, listen: false).getAllMarchants(
            pageNumber: Provider.of<UserViewModel>(context, listen: false)
                .merchantcurrentPage);
      }
    });

    // UserViewModel pr = Provider.of<UserViewModel>(context, listen: false);
    // pr.getAllBanks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: appBarrWitoutAction(
        title: "Merchants & Banks",
        centerTitle: true,
        leadingWidget: SizedBox(
          width: 10,
          height: 5,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Consumer<UserViewModel>(builder: (context, pr, c) {
          return SingleChildScrollView(
            controller: _scrollControllerBank,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Merchant Dropdown
                DropDownTextField(
                  controller: _merchantController,
                  clearOption: false,
                  enableSearch: true,
                  textFieldDecoration:
                      customInputDecoration(hintText: "Select Merchant"),
                  validator: (value) {
                    if (value == null) {
                      return "Please select a merchant";
                    }
                    return null;
                  },
                  dropDownItemCount: pr.merchantList.length,
                  dropDownList:
                      pr.merchantList.map((MerchantModelData merchant) {
                    return DropDownValueModel(
                      name: merchant.name,
                      value: merchant.id,
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Handle merchant selection if needed
                  },
                ),
                SizedBox(height: 20),
                DropDownTextField(
                  controller: _bankController,
                  clearOption: false,
                  enableSearch: true,
                  validator: (value) {
                    if (value == null) {
                      return "Please select a bank";
                    }
                    return null;
                  },
                  dropDownItemCount: pr.bankList.length,
                  dropDownList: pr.bankList.map((Bank bank) {
                    return DropDownValueModel(
                      name: bank.name,
                      value: bank.id,
                    );
                  }).toList(),
                  textFieldDecoration:
                      customInputDecoration(hintText: "Select Bank"),
                  onChanged: (value) {
                    // Handle bank selection if needed
                  },
                ),
                SizedBox(height: 20),

                // Horizontal Merchants List
                kText(text: "Merchants", fWeight: fontWeightBold, fSize: 18.0),
                SizedBox(height: 10),
                SizedBox(
                  height: Get.height / 5.4,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: _scrollControllerMerchant,
                          itemCount: pr.merchantList.length,
                          itemBuilder: (context, index) {
                            if (index == pr.merchantList.length) {
                              // Show loader at the end while fetching new items
                              return pr.merchantisLoadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox(); // If not loading, return empty space
                            }
                            MerchantModelData model = pr.merchantList[index];
                            return InkWell(
                                onTap: () {
                                  Get.to(
                                    MerchnatDetailScreen(
                                      model: model,
                                      title: model.name,
                                      imageUrls: [
                                        "https://portal.buzdy.com//storage/admin/uploads/images/16061334945fbba6f60d1e6.jpg",
                                        "https://portal.buzdy.com//storage/admin/uploads/images/16061335095fbba70511ec0.jpg",
                                        "https://portal.buzdy.com//storage/admin/uploads/images/16061335255fbba715d6610.jpg"
                                      ],
                                      description:
                                          "All information provided on this webpage is courtesy of NRSP Microfinance Bank Limited.",
                                      address: model.address ?? "",
                                      email: model.email ?? "",
                                      phone: model.phone ?? "",
                                      operatingHours: "08:00:00 - 18:00:00",
                                      offDays: "Saturday, Sunday",
                                    ),
                                  );
                                },
                                child: listWidget(model: model));
                          },
                        ),
                      ),

                      /// **Show Loader When Loading More**
                      if (pr.merchantisLoadingMore)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      /// **No More Data Message**
                      if (!pr.merchanthasMoreData && pr.merchantList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "No more",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Vertical Banks Grid
                kText(text: "Banks", fWeight: fontWeightBold, fSize: 18.0),
                SizedBox(height: 10),
                Container(
                  child: GridView.builder(
                    //   controller: _scrollControllerBank,
                    shrinkWrap:
                        true, // Ensures GridView fits inside the scrollable area
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pr.bankList.length,
                    itemBuilder: (context, index) {
                      Bank model = pr.bankList[index];
                      return InkWell(
                          onTap: () {
                            Get.to(
                              DetailScreen(
                                model: model,
                                title: model.name,
                                imageUrls: [
                                  "https://portal.buzdy.com//storage/admin/uploads/images/16061334945fbba6f60d1e6.jpg",
                                  "https://portal.buzdy.com//storage/admin/uploads/images/16061335095fbba70511ec0.jpg",
                                  "https://portal.buzdy.com//storage/admin/uploads/images/16061335255fbba715d6610.jpg"
                                ],
                                description:
                                    "All information provided on this webpage is courtesy of NRSP Microfinance Bank Limited.",
                                address:
                                    "Near Baghdad Railway Station, University Road, Bahawalpur 63100, Pakistan.",
                                email: "info@nrspbank.com",
                                phone: "(062) 2285126",
                                operatingHours: "08:00:00 - 18:00:00",
                                offDays: "Saturday, Sunday",
                              ),
                            );
                          },
                          child: gridWidgetWidget(model));
                    },
                  ),
                ),

                /// **Show Loader When Loading More**
                if (pr.bankisLoadingMore)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                /// **No More Data Message**
                if (!pr.bankhasMoreData && pr.bankList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "No more banks to load",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  InputDecoration customInputDecoration({
    required String hintText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200], // Light grey background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.grey[400]!, // Grey border color
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.grey[400]!, // Enabled state border
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.blueAccent, // Highlighted border color
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.red, // Error border color
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.red, // Highlighted error border
          width: 1.5,
        ),
      ),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[600]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
    );
  }

  SizedBox listWidget({MerchantModelData? model}) {
    return SizedBox(
      width: Get.width / 2.3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: Card(
            color: whiteColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.3, color: greyColor),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Expanded(
                    child: SizedBox(
                  child: Image.network(
                      fit: BoxFit.cover,
                      "https://portal.buzdy.com/storage/admin/uploads/images/1690965833.jpg"),
                )),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: kText(
                                text: model!.name,
                                fWeight: fontWeightBold,
                                fSize: 10.0,
                                textalign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceSm10,
                      kText(
                          text: "head office",
                          fWeight: fontWeightBold,
                          tColor: Colors.green),
                      UIHelper.verticalSpaceSm10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () => _updateRating(index +
                                      1.0), // Update rating when star tapped
                                  child: Icon(
                                    Icons.star,
                                    color: index < _rating
                                        ? Colors.yellow
                                        : Colors.grey,
                                    size: 10,
                                  ),
                                );
                              }),
                            ),
                            kText(
                              text: "1 reviews",
                              fWeight: fontWeightBold,
                              tColor: mainBlackcolor,
                              fSize: 10.0,
                            )
                          ],
                        ),
                      ),
                      UIHelper.verticalSpaceSm5,
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  SizedBox gridWidgetWidget(Bank model) {
    int avgRating = model.avgRating.round() ?? 0; // Ensure it's an integer

    return SizedBox(
      child: Card(
        color: whiteColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.3, color: greyColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                child: Image.network(
                  fit: BoxFit.cover,
                  "https://portal.buzdy.com/storage/admin/uploads/images/1690965833.jpg",
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: kText(
                            text: model.name,
                            fWeight: fontWeightBold,
                            fSize: 12.0,
                            textalign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpaceSm10,
                  kText(
                    text: "head office",
                    fWeight: fontWeightBold,
                    tColor: Colors.green,
                  ),
                  UIHelper.verticalSpaceSm10,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: index < avgRating
                                  ? Colors.yellow
                                  : Colors.grey,
                              size: 13,
                            );
                          }),
                        ),
                        kText(
                          text: "${model.reviews.length} reviews",
                          fWeight: fontWeightBold,
                          tColor: mainBlackcolor,
                          fSize: 10.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
