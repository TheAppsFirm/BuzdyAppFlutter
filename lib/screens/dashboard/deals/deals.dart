import 'package:buzdy/screens/dashboard/deals/coinDetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buzdy/screens/dashboard/deals/bubbleCrypto.dart';
import 'package:buzdy/screens/provider/UserViewModel.dart';
import 'package:buzdy/views/custom_text_field.dart';
import 'package:buzdy/views/colors.dart';
import 'package:buzdy/views/customText.dart';
import 'package:buzdy/views/ui_helpers.dart';

class DealerScreen extends StatefulWidget {
  const DealerScreen({super.key});

  @override
  State<DealerScreen> createState() => _DealerScreenState();
}

class _DealerScreenState extends State<DealerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        setState(() => _isLoadingMore = true);
        userViewModel.fetchCoins(limit: 10).then((_) {
          setState(() => _isLoadingMore = false);
        });
      }
    });
  }

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
            _buildListView(), // First Tab: List View with Search
            DealsScreen(), // Second Tab: Bubble View
          ],
        ),
      ),
    );
  }

  /// List View with Search Feature and Pagination
  Widget _buildListView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<UserViewModel>(builder: (context, pr, c) {
        if (pr.isFetching && pr.coins.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search Bar
            CustomTextField(
              prefix: Icon(Icons.search, color: greyColor),
              required: false,
              hint: "Search coins...",
              controllerr: _searchController,
              onChanged: (query) {
                pr.searchCoins(query);
              },
            ),
            UIHelper.verticalSpaceSm20,

            // Coin List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: pr.coins.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == pr.coins.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final coin = pr.coins[index];

                  return InkWell(
                    onTap: () {
                      Get.to(CoinDetailScreen(coin: coin));
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
                          backgroundImage: NetworkImage(coin.imageUri ?? ""),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        title: kText(
                          text: coin.name ?? "",
                          fSize: 16.0,
                          tColor: mainBlackcolor,
                          fWeight: FontWeight.w600,
                        ),
                        subtitle: kText(
                          text: coin.symbol ?? "",
                          fSize: 14.0,
                          tColor: greyColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
