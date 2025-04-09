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
  final _merchantController = SingleValueDropDownController(
    data: DropDownValueModel(name: "All Merchants", value: "All Items"),
  );
  final _bankController = SingleValueDropDownController(
      data: DropDownValueModel(name: "All Banks", value: "All Items"));

  final TextEditingController _searchController = TextEditingController();
  String _selectedCountry = 'All Countries';
  final List<String> countryList = [
    "All Countries",
    "Algeria",
    "Australia",
    "Bahrain",
    "Bangladesh",
    "Belgium",
    "Canada",
    "China",
    "Finland",
    "France",
    "Germany",
    "India",
    "Indonesia",
    "Japan",
    "Kuwait",
    "Moldova",
    "Netherlands",
    "Norway",
    "Oman",
    "Pakistan",
    "Qatar",
    "Saudi Arabia",
    "Singapore",
    "South Korea",
    "Sweden",
    "Switzerland",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !Provider.of<UserViewModel>(context, listen: false).bankisLoadingMore &&
          _selectedCountry == 'All Countries') {
        print("Bank scroll triggered at page: ${Provider.of<UserViewModel>(context, listen: false).bankcurrentPage}");
        Provider.of<UserViewModel>(context, listen: false)
            .getAllBanks(pageNumber: Provider.of<UserViewModel>(context, listen: false).bankcurrentPage);
      }
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !Provider.of<UserViewModel>(context, listen: false).merchantisLoadingMore) {
        print("Merchant scroll triggered at page: ${Provider.of<UserViewModel>(context, listen: false).merchantcurrentPage}");
        Provider.of<UserViewModel>(context, listen: false)
            .getAllMarchants(pageNumber: Provider.of<UserViewModel>(context, listen: false).merchantcurrentPage);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _merchantController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: appBarrWitoutAction(
        title: "Merchants & Banks",
        centerTitle: true,
        leadingWidget: SizedBox(width: 10, height: 5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Consumer<UserViewModel>(builder: (context, pr, c) {
          List<Bank> filteredBanks = pr.bankList
              .where((bank) => bank.name.toLowerCase().contains(_searchController.text.toLowerCase()))
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: customInputDecoration(hintText: "Search")
                          .copyWith(prefixIcon: Icon(Icons.search, size: 20)),
                      style: TextStyle(fontSize: 14),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: DropDownTextField(
                      controller: SingleValueDropDownController(
                        data: DropDownValueModel(name: _selectedCountry, value: _selectedCountry),
                      ),
                      clearOption: false,
                      textFieldDecoration: customInputDecoration(hintText: "Country"),
                      dropDownList: countryList
                          .map((country) => DropDownValueModel(name: country, value: country))
                          .toList(),
                      textStyle: TextStyle(fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value.value;
                          if (_selectedCountry == 'All Countries') {
                            pr.bankList.clear();
                            pr.bankcurrentPage = 1;
                            pr.bankhasMoreData = true;
                            pr.getAllBanks(pageNumber: pr.bankcurrentPage);
                          } else {
                            pr.getBanksByCountry(country: _selectedCountry.toLowerCase());
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.refresh, size: 20),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _selectedCountry = 'All Countries';
                        pr.bankList.clear();
                        pr.bankcurrentPage = 1;
                        pr.bankhasMoreData = true;
                        pr.getAllBanks(pageNumber: pr.bankcurrentPage);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropDownTextField(
                        controller: _merchantController,
                        clearOption: false,
                        enableSearch: true,
                        textFieldDecoration: customInputDecoration(hintText: "Select Merchant"),
                        dropDownItemCount: pr.merchantList.length,
                        dropDownList: pr.merchantList.map((MerchantModelData merchant) {
                          return DropDownValueModel(name: merchant.name, value: merchant.id);
                        }).toList(),
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 10),
                      DropDownTextField(
                        controller: _bankController,
                        clearOption: false,
                        enableSearch: true,
                        dropDownItemCount: filteredBanks.length,
                        dropDownList: filteredBanks.map((Bank bank) {
                          return DropDownValueModel(name: bank.name, value: bank.id);
                        }).toList(),
                        textFieldDecoration: customInputDecoration(hintText: "Select Bank"),
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 20),
                      kText(text: "Merchants", fWeight: fontWeightBold, fSize: 18.0),
                      SizedBox(height: 10),
                      SizedBox(
                        height: Get.height / 5.4,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pr.merchantList.length + (pr.merchanthasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == pr.merchantList.length && pr.merchanthasMoreData) {
                              return pr.merchantisLoadingMore
                                  ? Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(child: CircularProgressIndicator()),
                                    )
                                  : SizedBox(width: 50);
                            }
                            MerchantModelData model = pr.merchantList[index];
                            return InkWell(
                              onTap: () {
                                Get.to(MerchnatDetailScreen(
                                  model: model,
                                  title: model.name,
                                  imageUrls: [model.image],
                                  description: model.description ?? "",
                                  address: model.address ?? "",
                                  email: model.email ?? "",
                                  phone: model.phone ?? "",
                                  operatingHours: "08:00:00 - 18:00:00",
                                  offDays: "Saturday, Sunday",
                                ));
                              },
                              child: listWidget(model: model),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      kText(text: "Banks", fWeight: fontWeightBold, fSize: 18.0),
                      SizedBox(height: 10),
                      if (pr.bankisLoadingMore && filteredBanks.isEmpty)
                        Center(child: CircularProgressIndicator()),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: filteredBanks.length + (_selectedCountry == 'All Countries' && pr.bankhasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredBanks.length && _selectedCountry == 'All Countries' && pr.bankhasMoreData) {
                            return pr.bankisLoadingMore
                                ? Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  )
                                : SizedBox(height: 50); // Placeholder to extend scroll
                          }
                          Bank model = filteredBanks[index];
                          return InkWell(
                            onTap: () {
                              Get.to(DetailScreen(
                                model: model,
                                title: model.name,
                                imageUrls: [model.image],
                                description: "Banking services provided by ${model.name}",
                                address: model.address ?? "",
                                email: model.email ?? "",
                                phone: model.phone ?? "",
                                operatingHours: "08:00:00 - 18:00:00",
                                offDays: "Saturday, Sunday",
                              ));
                            },
                            child: gridWidgetWidget(model),
                          );
                        },
                      ),
                      if (_selectedCountry == 'All Countries' && !pr.bankhasMoreData && filteredBanks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "All banks loaded",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  model!.image.contains('http')
                      ? model.image
                      : 'https://portal.buzdy.com/storage/admin/uploads/images/${model.image}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: kText(
                        text: model.name,
                        fWeight: fontWeightBold,
                        fSize: 10.0,
                        textalign: TextAlign.center,
                        maxLines: 2,
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
                                color: index < model.avgRating ? Colors.yellow : Colors.grey,
                                size: 10,
                              );
                            }),
                          ),
                          kText(
                            text: "1 reviews",
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
      ),
    );
  }

  SizedBox gridWidgetWidget(Bank model) {
    int avgRating = model.avgRating.round();

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
              child: Image.network(
                model.image.contains('http')
                    ? model.image
                    : 'https://portal.buzdy.com/storage/admin/uploads/images/${model.image}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: kText(
                      text: model.name,
                      fWeight: fontWeightBold,
                      fSize: 12.0,
                      textalign: TextAlign.center,
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
                              color: index < avgRating ? Colors.yellow : Colors.grey,
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

  InputDecoration customInputDecoration({required String hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
    );
  }
}