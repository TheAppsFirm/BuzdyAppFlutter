import 'package:buzdy/screens/dashboard/bubbleCrypto.dart';
import 'package:buzdy/views/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzdy/views/appBar.dart';
import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/customText.dart';
import 'package:buzdy/views/ui_helpers.dart';

class DealerScreen extends StatefulWidget {
  @override
  State<DealerScreen> createState() => _DealerScreenState();
}

class _DealerScreenState extends State<DealerScreen> {
  final List<Map<String, dynamic>> coins = [
    {
      "name": "Bitcoin",
      "symbol": "BTC",
      "price": "\$30,200",
      "change": "+2.5%",
      "description": "Bitcoin is a decentralized cryptocurrency."
    },
    {
      "name": "Ethereum",
      "symbol": "ETH",
      "price": "\$2,000",
      "change": "-1.2%",
      "description": "Ethereum is a decentralized platform for smart contracts."
    },
    {
      "name": "Binance Coin",
      "symbol": "BNB",
      "price": "\$320",
      "change": "+0.8%",
      "description": "Binance Coin is used to pay fees on the Binance exchange."
    },
    {
      "name": "Ripple",
      "symbol": "XRP",
      "price": "\$0.50",
      "change": "+5.1%",
      "description": "Ripple is a digital payment protocol and cryptocurrency."
    },
    {
      "name": "Cardano",
      "symbol": "ADA",
      "price": "\$0.30",
      "change": "-0.5%",
      "description": "Cardano is a blockchain platform for change-makers."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          title: Text("Deals"),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "List"),
              Tab(text: "Bubbles"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListView(), // First Tab: List View
            DealsScreen(), // Second Tab: Bubble View
          ],
        ),
      ),
    );
  }

  /// First Tab: List View
  Widget _buildListView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          CustomTextField(
            prefix: Icon(Icons.search, color: greyColor),
            required: false,
            hint: "Search coins...",
            controllerr: TextEditingController(),
          ),
          UIHelper.verticalSpaceSm20,

          // Coin List
          Expanded(
            child: ListView.builder(
              itemCount: coins.length,
              itemBuilder: (context, index) {
                final coin = coins[index];
                return GestureDetector(
                  onTap: () {
                    //    Get.to(() => );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 0.0,
                    color: Colors.blue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: kText(
                            text: coin["symbol"],
                            fSize: 12.0,
                            fWeight: FontWeight.bold,
                            tColor: mainBlackcolor,
                          ),
                        ),
                      ),
                      title: kText(
                        text: coin["name"],
                        fSize: 16.0,
                        tColor: mainBlackcolor,
                        fWeight: FontWeight.w600,
                      ),
                      subtitle: kText(
                        text: coin["price"],
                        fSize: 14.0,
                        tColor: greyColor,
                      ),
                      trailing: kText(
                        text: coin["change"],
                        fSize: 14.0,
                        tColor: coin["change"].contains('+')
                            ? Colors.green
                            : Colors.red,
                        fWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
