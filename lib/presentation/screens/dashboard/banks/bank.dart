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
  String? _selectedCity;

  final List<String> countryList = [
    "All Countries",
    "DZA", "AUS", "BHR", "BGD", "BEL", "CAN", "CHN", "FIN", "FRA", "DEU",
    "IND", "IDN", "JPN", "KWT", "MDA", "NLD", "NOR", "OMN", "PAK", "QAT",
    "SAU", "SGP", "KOR", "SWE", "CHE", "UAE", "GBR", "USA",
  ];

  final Map<String, String> countryMapping = {
  "All Countries": "All Countries",
  "DZA": "Algeria",
  "AUS": "Australia",
  "BHR": "Bahrain",
  "BGD": "Bangladesh",
  "BEL": "Belgium",
  "CAN": "Canada",
  "CHN": "China",
  "FIN": "Finland",
  "FRA": "France",
  "DEU": "Germany",
  "IND": "India",
  "IDN": "Indonesia",
  "JPN": "Japan",
  "KWT": "Kuwait",
  "MDA": "Moldova",
  "NLD": "Netherlands",
  "NOR": "Norway",
  "OMN": "Oman",
  "PAK": "Pakistan",
  "QAT": "Qatar",
  "SAU": "Saudi Arabia",
  "SGP": "Singapore",
  "KOR": "South Korea",
  "SWE": "Sweden",
  "CHE": "Switzerland",
  "UAE": "United Arab Emirates",
  "GBR": "United Kingdom",
  "USA": "United States",
};

final Map<String, List<String>> cityMap = {
  "Algeria": ["Alger", "Algeria", "Algiers", "Bab Ezzouar", "Mascara"],
  "Switzerland": ["Aarau", "Basel", "Bern", "Luzern", "Zürich", "Genève"],
  "United Arab Emirates": ["Dubai", "Abu Dhabi", "Sharjah", "Fujairah", "Ras Al Khaimah", "Ajman"],
  "Canada": ["Ottawa", "Toronto", "Montreal", "Oakville, Ontario", "Saskatoon"],
  "United States": ["Boston", "New York", "San Francisco", "Dallas", "Cincinnati", "Cleveland", "Charlotte", "Mclean", "Pittsburgh"],
  "Germany": ["Berlin", "Frankfurt", "Frankfurt am Main", "Hannover", "Köln", "Stuttgart", "Wiesbaden", "München"],
  "United Kingdom": ["London", "Birmingham", "Bradford", "Leicester", "Manchester", "Sutton", "Wellingborough", "Blyth", "Glasgow", "Surrey", "Warley"],
  "France": ["Paris"],
  "India": ["Chennai", "Kolkata", "Mumbai", "New Dehli", "Shivajinagar", "Bengluru", "Karur", "Nainital", "Thrissur", "Vadodara"],
  "Pakistan": ["Lahore", "Karachi", "Islamabad", "Rawalpindi", "Faisalabad", "Peshawar", "Muzaffarabad"],
  "Bangladesh": ["Dhaka"],
  "Oman": ["Muscat", "Sohar"],
  "Qatar": ["Doha"],
  "Saudi Arabia": ["Riyadh", "Jeddah"],
  "Kuwait": ["kuwait"],
  "Indonesia": ["Jakarta"],
  "Japan": ["Tokyo", "Osaka", "Chiyoda"],
  "South Korea": ["Seoul"],
  "Australia": ["Melbourne", "bendigo", "sydeny", "Sydney"],
  "Netherlands": ["Amsterdam", "Den Haag", "Driebergen-Rijsenburg", "Utrecht"],
  "Belgium": ["Antwerp", "Brussels"],
  "Moldova": ["Chisinau"],
  "Bahrain": ["Manama"],
  "China": ["Beijing", "Shanghai", "Shenzhen"],
  "Singapore": ["Marina Bay Link Mall", "People's Park Centre"],
  "Norway": ["Oslo", "Lysaker", "Stavanger"],
  "Sweden": ["Stockholm"],
  "Hong Kong": ["Robinson Road"],
  "South Africa": ["hoofddroop"],
};



  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        final viewModel = Provider.of<UserViewModel>(context, listen: false);
        if (_selectedCountry == 'All Countries') {
          if (!viewModel.merchantisLoadingMore && viewModel.merchanthasMoreData) {
            viewModel.getAllMarchants(pageNumber: viewModel.merchantcurrentPage);
          }
          if (!viewModel.bankisLoadingMore && viewModel.bankhasMoreData) {
            viewModel.getAllBanks(pageNumber: viewModel.bankcurrentPage);
          }
        } else {
          if (!viewModel.merchantisLoadingMore && viewModel.merchanthasMoreData) {
            viewModel.getMerchantsByCountry(
              country: countryMapping[_selectedCountry]!.toLowerCase(),
              city: _selectedCity?.toLowerCase(),
              pageNumber: viewModel.merchantcurrentPage,
            );
          }
          if (!viewModel.bankisLoadingMore && viewModel.bankhasMoreData) {
            viewModel.getBanksByCountry(
              country: countryMapping[_selectedCountry]!.toLowerCase(),
              city: _selectedCity?.toLowerCase(),
              pageNumber: viewModel.bankcurrentPage,
            );
          }
        }
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
          List<MerchantModelData> filteredMerchants = pr.merchantList
              .where((merchant) => merchant.name.toLowerCase().contains(_searchController.text.toLowerCase()))
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
                        if (value == null || value.value == _selectedCountry) return;
                        setState(() {
                          _selectedCountry = value.value;
                          _selectedCity = null;
                          pr.resetFilters();
                          if (_selectedCountry == 'All Countries') {
                            pr.getAllBanks(pageNumber: 1);
                            pr.getAllMarchants(pageNumber: 1);
                          } else {
                            pr.getBanksByCountry(
                              country: countryMapping[_selectedCountry]!.toLowerCase(),
                              city: null,
                              pageNumber: 1,
                            );
                            pr.getMerchantsByCountry(
                              country: countryMapping[_selectedCountry]!.toLowerCase(),
                              city: null,
                              pageNumber: 1,
                            );
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
                        _selectedCity = null;
                        pr.resetFilters();
                        pr.getAllBanks(pageNumber: 1);
                        pr.getAllMarchants(pageNumber: 1);
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (_selectedCountry != 'All Countries' && cityMap[countryMapping[_selectedCountry]!] != null)
                Row(
                  children: [
                    Expanded(
                      child: DropDownTextField(
                        controller: SingleValueDropDownController(
                          data: DropDownValueModel(
                            name: _selectedCity ?? "Select City",
                            value: _selectedCity,
                          ),
                        ),
                        clearOption: true,
                        textFieldDecoration: customInputDecoration(hintText: "Select City"),
                        dropDownList: [
                          DropDownValueModel(name: "Select City", value: null),
                          ...cityMap[countryMapping[_selectedCountry]!]!
                              .map((city) => DropDownValueModel(name: city, value: city))
                              .toList(),
                        ],
                        textStyle: TextStyle(fontSize: 14),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value.value;
                            pr.resetFilters();
                            pr.getBanksByCountry(
                              country: countryMapping[_selectedCountry]!.toLowerCase(),
                              city: _selectedCity?.toLowerCase(),
                              pageNumber: 1,
                            );
                            pr.getMerchantsByCountry(
                              country: countryMapping[_selectedCountry]!.toLowerCase(),
                              city: _selectedCity?.toLowerCase(),
                              pageNumber: 1,
                            );
                          });
                        },
                      ),
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
                        dropDownList: [
                          DropDownValueModel(name: "All Merchants", value: "All Items"),
                          ...filteredMerchants.map((merchant) => DropDownValueModel(name: merchant.name, value: merchant.id)),
                        ],
                        onChanged: (value) {
                          if (value != null && value.value != "All Items") {
                            final selectedMerchant = filteredMerchants.firstWhere(
                              (merchant) => merchant.id == value.value,
                              orElse: () => filteredMerchants.first,
                            );
                            Get.to(() => MerchnatDetailScreen(
                                  model: selectedMerchant,
                                  title: selectedMerchant.name,
                                  imageUrls: [
                                    selectedMerchant.image ??
                                        "https://portal.buzdy.com/storage/admin/uploads/images/default.jpg"
                                  ],
                                  description: selectedMerchant.description ?? "",
                                  address: selectedMerchant.address ?? "",
                                  email: selectedMerchant.email ?? "",
                                  phone: selectedMerchant.phone ?? "",
                                  operatingHours: "08:00:00 - 18:00:00",
                                  offDays: "Saturday, Sunday",
                                ));
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      DropDownTextField(
                        controller: _bankController,
                        clearOption: false,
                        enableSearch: true,
                        textFieldDecoration: customInputDecoration(hintText: "Select Bank"),
                        dropDownList: [
                          DropDownValueModel(name: "All Banks", value: "All Items"),
                          ...filteredBanks.map((bank) => DropDownValueModel(name: bank.name, value: bank.id)),
                        ],
                        onChanged: (value) {
                          if (value != null && value.value != "All Items") {
                            final selectedBank = filteredBanks.firstWhere(
                              (bank) => bank.id == value.value,
                              orElse: () => filteredBanks.first,
                            );
                            Get.to(() => DetailScreen(
                                  model: selectedBank,
                                  title: selectedBank.name,
                                  imageUrls: [
                                    selectedBank.image ??
                                        "https://portal.buzdy.com/storage/admin/uploads/images/default.jpg"
                                  ],
                                  description: "Banking services provided by ${selectedBank.name}",
                                  address: selectedBank.address ?? "",
                                  email: selectedBank.email ?? "",
                                  phone: selectedBank.phone ?? "",
                                  operatingHours: "08:00:00 - 18:00:00",
                                  offDays: "Saturday, Sunday",
                                ));
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      kText(text: "Merchants", fWeight: fontWeightBold, fSize: 18.0),
                      SizedBox(height: 10),
                      if (pr.merchantisLoadingMore && filteredMerchants.isEmpty)
                        Center(child: CircularProgressIndicator()),
                      SizedBox(
                        height: Get.height / 5.4,
                        child: filteredMerchants.isEmpty && !pr.merchantisLoadingMore
                            ? Center(child: Text("No merchants found"))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredMerchants.length +
                                    (pr.merchanthasMoreData ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == filteredMerchants.length && pr.merchanthasMoreData) {
                                    return pr.merchantisLoadingMore
                                        ? Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Center(child: CircularProgressIndicator()),
                                          )
                                        : SizedBox(width: 50);
                                  }
                                  MerchantModelData model = filteredMerchants[index];
                                  return InkWell(
                                    onTap: () {
                                      Get.to(() => MerchnatDetailScreen(
                                            model: model,
                                            title: model.name,
                                            imageUrls: [
                                              model.image ??
                                                  "https://portal.buzdy.com/storage/admin/uploads/images/default.jpg"
                                            ],
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
                      filteredBanks.isEmpty && !pr.bankisLoadingMore
                          ? Center(child: Text("No banks found"))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 5.0,
                                mainAxisSpacing: 5.0,
                              ),
                              itemCount: filteredBanks.length + (pr.bankhasMoreData ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == filteredBanks.length && pr.bankhasMoreData) {
                                  return pr.bankisLoadingMore
                                      ? Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(child: CircularProgressIndicator()),
                                        )
                                      : SizedBox(height: 50);
                                }
                                Bank model = filteredBanks[index];
                                return InkWell(
                                  onTap: () {
                                    Get.to(() => DetailScreen(
                                          model: model,
                                          title: model.name,
                                          imageUrls: [
                                            model.image ??
                                                "https://portal.buzdy.com/storage/admin/uploads/images/default.jpg"
                                          ],
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
                      if (!pr.bankhasMoreData && filteredBanks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "All banks loaded",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      if (!pr.merchanthasMoreData && filteredMerchants.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "All merchants loaded",
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
    print("Merchant Image URL: ${model!.image}"); // Log the image URL
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
                child: model.image != null
                    ? Image.network(
                        model.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Image load error for ${model.name}: $error"); // Log errors
                          return Icon(Icons.broken_image, size: 50);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                      )
                    : Icon(Icons.image_not_supported, size: 50),
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
                            text: "1 reviews", // Update dynamically if review data available
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
    print("Bank Image URL: ${model.image}"); // Log the image URL
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
              child: model.image != null
                  ? Image.network(
                      model.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("Image load error for ${model.name}: $error"); // Log errors
                        return Icon(Icons.broken_image, size: 50);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                    )
                  : Icon(Icons.image_not_supported, size: 50),
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