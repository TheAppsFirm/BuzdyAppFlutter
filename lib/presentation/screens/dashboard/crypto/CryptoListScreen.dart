
import 'package:buzdy/presentation/screens/dashboard/crypto/CryptoBubblesScreen.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/CoinDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/widgets/custom_text_field.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/ui_helpers.dart';

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({Key? key}) : super(key: key);

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _scrollController.addListener(() {
      // Trigger pagination only if the user has scrolled to the bottom
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore) {
        setState(() => _isLoadingMore = true);
        userViewModel.fetchCoins(limit: 25).then((_) {
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
          title: const Text("Crypto"),
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
            _CryptoListView(
              scrollController: _scrollController,
              searchController: _searchController,
            ),
            const CryptoBubblesScreen(),
          ],
        ),
      ),
    );
  }
}

/// This widget displays a list of coins with an improved cell UI and pull-to-refresh.
class _CryptoListView extends StatelessWidget {
  final ScrollController scrollController;
  final TextEditingController searchController;

  const _CryptoListView({
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
          // Coin List with Pull-to-Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Trigger a refresh to fetch the latest coins.
                await userViewModel.fetchCoins(limit: 10, isRefresh: true);
              },
              child: ListView.builder(
                controller: scrollController,
                // Only add a bottom loader if the coins list is not empty.
                itemCount: userViewModel.coins.length +
                    (userViewModel.coins.isNotEmpty && userViewModel.isFetching ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == userViewModel.coins.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final coin = userViewModel.coins[index];
                  return InkWell(
                    onTap: () async {
                      userViewModel.easyLoadingStart();
                      final detail = await userViewModel
                          .fetchCoinDetail(coin.code ?? coin.symbol);
                      userViewModel.easyLoadingStop();
                      if (detail != null) {
                        Get.to(CoinDetailScreen(coin: detail));
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Coin Image
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: NetworkImage(
                                coin.png64 != null && coin.png64!.trim().isNotEmpty
                                    ? coin.png64!
                                    : coin.webp64 != null && coin.webp64!.trim().isNotEmpty
                                        ? coin.webp64!
                                        : 'https://via.placeholder.com/64',
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Coin Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name and Rank Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        coin.name.trim().isNotEmpty
                                            ? coin.name
                                            : (coin.code != null && coin.code!.trim().isNotEmpty
                                                ? coin.code!
                                                : "N/A"),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        coin.rank != null
                                            ? 'Rank: ${coin.rank}'
                                            : 'Rank: N/A',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Symbol and Rate Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        coin.code != null &&
                                                coin.code!.trim().isNotEmpty
                                            ? coin.code!
                                            : (coin.symbol.trim().isNotEmpty
                                                ? coin.symbol
                                                : "N/A"),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        coin.rate != null
                                            ? '\$${coin.rate!.toStringAsFixed(2)}'
                                            : 'N/A',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Additional Information Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // 24h Change Text
                                      coin.delta != null
                                          ? _buildDeltaText(coin.delta!.day)
                                          : const Text(
                                              '24h: N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      // Market Cap
                                      Text(
                                        coin.cap != null
                                            ? 'MCap: \$${_formatNumber(coin.cap!)}'
                                            : 'MCap: N/A',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 24h delta text with an up/down arrow and colored text.
  Widget _buildDeltaText(double dayDelta) {
    final isPositive = dayDelta >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final arrow = isPositive ? '↑' : '↓';
    // Assuming delta.day is a percentage value (e.g. 0.05 for 5%)
    final percentChange = (dayDelta.abs() * 100).toStringAsFixed(2);
    return Text(
      '24h: $arrow$percentChange%',
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Formats large numbers into K, M, or B (e.g., 1234567 -> "1.23M").
  String _formatNumber(double number) {
    if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  }
}
