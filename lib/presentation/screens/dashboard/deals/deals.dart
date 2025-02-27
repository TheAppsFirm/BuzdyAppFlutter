import 'package:buzdy/presentation/screens/dashboard/deals/coinDetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buzdy/presentation/screens/dashboard/deals/bubbleCrypto.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/widgets/custom_text_field.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/ui_helpers.dart';

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
          title: const Text("Deals"),
          centerTitle: true,
          bottom: const TabBar(
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
            _DealerListView(
              scrollController: _scrollController,
              searchController: _searchController,
            ),
            const DealsScreen(),
          ],
        ),
      ),
    );
  }
}

/// This widget is separated out to avoid nesting too many Consumer widgets.
/// It now accepts both the scroll controller and the search controller.
class _DealerListView extends StatelessWidget {
  final ScrollController scrollController;
  final TextEditingController searchController;

  const _DealerListView({
    Key? key,
    required this.scrollController,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          CustomTextField(
            prefixIcon: Icon(Icons.search, color: greyColor),
            isRequired: false,
            hint: "Search coins...",
            controller: searchController,
            onChanged: (query) {
              userViewModel.searchCoins(query);
            },
          ),
          UIHelper.verticalSpaceSm20,
          // Coin List
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: userViewModel.coins.length +
                  (userViewModel.isFetching ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == userViewModel.coins.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final coin = userViewModel.coins[index];
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
      ),
    );
  }
}
