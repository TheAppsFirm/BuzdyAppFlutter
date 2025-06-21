// ---------------------------------------------------------------------------
// Dashboard Home Screen
// ---------------------------------------------------------------------------
// This file contains the main dashboard screen along with helper widgets used
// to present analytics, quick search results and lists of businesses/products.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

// View models
import '../../../viewmodels/user_view_model.dart';
import '../../../viewmodels/search_view_model.dart';
import '../../../viewmodels/analytics_view_model.dart';

// Screens
import '../crypto/CryptoScreen.dart';
import '../../dashboard.dart';
import '../../search/search_screen.dart';
import '../../search/article_webview.dart';

// Models
import '../crypto/model.dart/coinModel.dart';
import '../banks/model/merchnatModel.dart';
import '../products/model/productModel.dart';
import '../../search/models/news_article.dart';

// Widgets
import '../../../widgets/analytics_widgets.dart';
import '../../../widgets/glass_container.dart';

// Constants
import 'package:buzdy/core/constants.dart';

/// Small card used for quick statistic blocks.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}


class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final SearchViewModel _searchVm;
  late final AnalyticsViewModel _analyticsVm;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchVm = SearchViewModel();
    _analyticsVm = AnalyticsViewModel()..load();
    _showHint();
  }

  Future<void> _showHint() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('world_hint_shown') ?? false;
    if (!shown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Tap the arrow icon to open full search results.'),
          ),
        );
      });
      await prefs.setBool('world_hint_shown', true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchVm.dispose();
    _analyticsVm.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard(UserViewModel vm) async {
    vm.resetFilters();
    await Future.wait([
      vm.getAllBanks(pageNumber: 1),
      vm.getAllMarchants(pageNumber: 1),
      vm.getAllProducts(pageNumber: 1),
      vm.fetchCoins(limit: 25, isRefresh: true),
    ]);
    if (_searchController.text.isEmpty) {
      await _searchVm.clear();
    }
    await _analyticsVm.load();
  }

  void _onSearchChanged(String text, UserViewModel vm, {bool immediate = false}) {
    setState(() {});
    vm.searchCoins(text);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (text.isEmpty) {
      _searchVm.clear();
    } else {
      if (immediate) {
        _searchVm.search(text);
      } else {
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _searchVm.search(text);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    final user = viewModel.userModel;
    final userName = user != null
        ? '${user.firstname} ${user.lastname}'.trim()
        : 'Buzdy';
    final now = DateTime.now();
    final date = DateFormat.yMMMMd().format(now);
    final time = DateFormat.Hm().format(now);
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _searchVm),
        ChangeNotifierProvider.value(value: _analyticsVm),
      ],
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _refreshDashboard(viewModel),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  GreetingSection(
                    greeting: greeting,
                    userName: userName,
                    date: date,
                    time: time,
                    searchController: _searchController,
                    userVm: viewModel,
                    onSearchChanged: (v, {immediate = false}) =>
                        _onSearchChanged(v, viewModel, immediate: immediate),
                  ),
                  const Divider(height: 32),
                  if (_analyticsVm.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  const SizedBox(height: 20),
                  const MarketTrendSection(),
                  const SizedBox(height: 20),
                  CryptoPriceSection(coins: viewModel.allCoins),
                  const SizedBox(height: 20),
                  const AiInsightsSection(),
                  const Divider(height: 32),
                  const SizedBox(height: 20),
                  const LawPolicySection(),
                  const Divider(height: 32),
                  const SizedBox(height: 20),
                  BusinessList(merchants: viewModel.merchantList),
                  const SizedBox(height: 20),
                  ProductList(products: viewModel.productList),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}

// ---------------------------------------------------------------------------
// Section widgets
// ---------------------------------------------------------------------------

/// Header showing greeting, analytics stats and the search bar.
class GreetingSection extends StatelessWidget {
  final String greeting;
  final String userName;
  final String date;
  final String time;
  final TextEditingController searchController;
  final UserViewModel userVm;
  final void Function(String, {bool immediate}) onSearchChanged;

  const GreetingSection({
    super.key,
    required this.greeting,
    required this.userName,
    required this.date,
    required this.time,
    required this.searchController,
    required this.userVm,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kAppButtonColor.withOpacity(0.7),
            kAppButtonColor.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $userName',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: colors.onPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '$date · $time',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.onPrimary.withOpacity(0.8)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Consumer<AnalyticsViewModel>(
                  builder: (context, vm, _) => StatCard(
                      title: 'Total Coins', value: (vm.totalCoins ?? 0).toString()),
                ),
                Consumer<AnalyticsViewModel>(
                  builder: (context, vm, _) => StatCard(
                      title: 'Exchanges', value: (vm.exchanges ?? 0).toString()),
                ),
                Consumer<AnalyticsViewModel>(
                  builder: (context, vm, _) => StatCard(
                      title: '24h Vol',
                      value: vm.volume24h != null
                          ? '\$${(vm.volume24h! / 1e9).toStringAsFixed(1)}B'
                          : '-'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const MarketCapCard(),
            const SizedBox(height: 12),
            const FearGreedGauge(),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) => onSearchChanged(v),
              onChanged: (v) => onSearchChanged(v),
              decoration: InputDecoration(
                hintText: 'Search... ',
                filled: true,
                fillColor: colors.onPrimary.withOpacity(0.1),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        onSearchChanged(searchController.text, immediate: true);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SearchScreen(
                              initialQuery: searchController.text,
                              viewModel: context.read<SearchViewModel>(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              ),
            const SizedBox(height: 8),
            // Quick search results appear directly below the search box so
            // users can see matches without scrolling the whole dashboard.
            QuickResultsSection(userVm: userVm),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick search result cards displayed beneath the search field.
// ---------------------------------------------------------------------------
class QuickResultsSection extends StatelessWidget {
  final UserViewModel userVm;

  const QuickResultsSection({
    super.key,
    required this.userVm,
  });

  @override
  Widget build(BuildContext context) {
    final searchVm = Provider.of<SearchViewModel>(context);
    if (searchVm.lastQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    if (searchVm.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final coins = userVm.coins.take(3).toList();
    final videos = searchVm.videoResults.take(3).toList();
    final news = searchVm.newsResults.take(3).toList();

    if (videos.isEmpty && news.isEmpty && coins.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No results found'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (coins.isNotEmpty)
          _section(
            'Crypto',
            Column(
              children: coins.map(_coinInfoCard).toList(),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CryptoScreen()),
            ),
          ),
        if (videos.isNotEmpty)
          _section(
            'Videos',
            Column(
              children: videos
                  .map(
                    (v) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          if (v.snippet?.thumbnails?.thumbnailsDefault?.url !=
                              null)
                            Image.network(
                              v.snippet!.thumbnails!.thumbnailsDefault!.url!,
                              width: 60,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              v.snippet?.title ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            onTap: () {
              final query = searchVm.lastQuery.isNotEmpty
                  ? searchVm.lastQuery
                  : 'latest crypto';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchScreen(
                    initialQuery: query,
                    viewModel: searchVm,
                    initialTab: 0,
                  ),
                ),
              );
            },
          ),
        if (news.isNotEmpty)
          _section(
            'News',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: news
                  .map((n) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(n.title,
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
            ),
            onTap: () {
              final query = searchVm.lastQuery.isNotEmpty
                  ? searchVm.lastQuery
                  : 'latest crypto';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchScreen(
                    initialQuery: query,
                    viewModel: searchVm,
                    initialTab: 1,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatNumber(double number) {
    final formatter = NumberFormat.compact();
    return formatter.format(number);
  }

  // Builds the best possible display title for a coin using available fields.
  String _coinTitle(CoinModel coin) {
    final name =
        (coin.name.isNotEmpty && coin.name != 'Unknown Name') ? coin.name : '';
    final symbol =
        coin.symbol.isNotEmpty && coin.symbol != 'N/A' ? coin.symbol : '';
    final code = coin.code != null && coin.code!.isNotEmpty ? coin.code! : '';
    final displayName = name.isNotEmpty
        ? name
        : symbol.isNotEmpty
            ? symbol
            : code;
    final displaySymbol = symbol.isNotEmpty
        ? symbol
        : code.isNotEmpty
            ? code
            : '';
    if (displaySymbol.isEmpty) {
      return displayName;
    }
    return '$displayName ($displaySymbol)';
  }

  // Card showing key metrics for a single coin result.
  Widget _coinInfoCard(CoinModel e) {
    final day = e.delta?.day;
    final week = e.delta?.week;
    final isPos = day != null && day >= 0;
    final arrow = isPos ? '↑' : '↓';
    final changeText =
        day != null ? '${arrow}${(day.abs() * 100).toStringAsFixed(2)}%' : 'N/A';
    final changeColor = isPos ? Colors.green : Colors.red;
    final weekText =
        week != null ? '${(week * 100).toStringAsFixed(2)}%' : 'N/A';
    final volume = e.volume != null ? '\$${_formatNumber(e.volume!)}' : 'N/A';
    final cap = e.cap != null ? '\$${_formatNumber(e.cap!)}' : 'N/A';
    final supply = e.circulatingSupply != null
        ? _formatNumber(e.circulatingSupply!)
        : 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (e.png64 != null && e.png64!.isNotEmpty)
                    Image.network(e.png64!, width: 24, height: 24)
                  else if (e.webp64 != null && e.webp64!.isNotEmpty)
                    Image.network(e.webp64!, width: 24, height: 24)
                  else if (e.imageUri.isNotEmpty)
                    Image.network(e.imageUri, width: 24, height: 24)
                  else
                    const SizedBox(width: 24, height: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _coinTitle(e),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.rate != null
                        ? '\$${e.rate!.toStringAsFixed(2)}'
                        : 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(changeText, style: TextStyle(color: changeColor)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MCap: ${cap}'),
                  Text('Vol: ${volume}'),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '7d: ${weekText}',
                    style: TextStyle(
                        color: week != null && week >= 0
                            ? Colors.green
                            : Colors.red),
                  ),
                  Text('Supply: ${supply}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to wrap a block in a titled card. Used by quick results.
  Widget _section(String title, Widget child, {VoidCallback? onTap}) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
    final content = onTap == null ? card : InkWell(onTap: onTap, child: card);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(width: double.infinity, child: content),
    );
  }
}

/// Displays a compact summary of BTC/ETH prices and daily changes.
class CryptoPriceSection extends StatelessWidget {
  final List<CoinModel> coins;

  const CryptoPriceSection({super.key, required this.coins});

  CoinModel? _find(String code) =>
      coins.firstWhereOrNull((c) => (c.code ?? '').toUpperCase() == code.toUpperCase());

  @override
  Widget build(BuildContext context) {
    final lastUpdated = context.select<AnalyticsViewModel, DateTime?>((vm) => vm.lastUpdated);
    final symbols = ['BTC', 'ETH'];

    

    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crypto Prices',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...symbols.map((code) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _PriceRow(label: code, coin: _find(code)),
                )),
            if (lastUpdated != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Last updated: '
                  '${DateTime.now().difference(lastUpdated).inMinutes} mins ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Last updated: -',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
    return Hero(
      tag: 'crypto-summary',
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashBoard(index: 1)),
          );
        },
        child: card,
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final CoinModel? coin;

  const _PriceRow({required this.label, required this.coin});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.compactCurrency(symbol: '\$');
    if (coin == null || coin!.rate == null) {
      return Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey, size: 16),
          const SizedBox(width: 4),
          Text('$label: N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      );
    }

    final rate = coin!.rate!;

    final price = formatter.format(rate);
    final change = coin!.delta?.day ?? 0;
    final deltaAbs = rate * change / 100;
    final changeColor = change >= 0 ? Colors.green : Colors.red;
    final icon = change >= 0 ? Icons.trending_up : Icons.trending_down;
    final arrow = change >= 0 ? '+' : '';
    Widget? coinIcon;
    if (coin!.png64 != null && coin!.png64!.isNotEmpty) {
      coinIcon = Image.network(coin!.png64!, width: 16, height: 16);
    } else if (coin!.webp64 != null && coin!.webp64!.isNotEmpty) {
      coinIcon = Image.network(coin!.webp64!, width: 16, height: 16);
    }

    return Row(
      children: [
        if (coinIcon != null) ...[coinIcon, const SizedBox(width: 4)],
        Icon(icon, color: changeColor, size: 16),
        const SizedBox(width: 4),
        Text('$label: $price ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('($arrow${change.toStringAsFixed(2)}%, ${arrow}${formatter.format(deltaAbs)})',
            style: TextStyle(color: changeColor)),
      ],
    );
  }
}

/// Shows local legal status, taxes and restrictions for crypto.
class LawPolicySection extends StatelessWidget {
  const LawPolicySection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SearchViewModel>(context);
    final info = vm.lawInfo;
    if (info == null && vm.lawLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (info == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SearchScreen(
                // Pre-populate the search field so results load
                // automatically for the user's country.
                initialQuery: '${info.country} crypto law',
                initialTab: 2,
                viewModel: context.read<SearchViewModel>(),
              ),
            ),
          );
        },
        title: const Text(
          'Law & Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Country: ${info.country}'),
              Text('Legal: ${info.legalStatus}'),
              Text('Taxation: ${info.taxation}'),
              Text('Restrictions: ${info.restrictions}'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// Horizontally scrolling list of nearby businesses.
class BusinessList extends StatelessWidget {
  final List<MerchantModelData> merchants;
  const BusinessList({super.key, required this.merchants});

  @override
  Widget build(BuildContext context) {
    if (merchants.isEmpty) {
      return const SizedBox.shrink();
    }
    final items = merchants.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Businesses',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashBoard(index: 2)),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 120,
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const DashBoard(index: 2),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: item.image != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(item.image!, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.business, size: 50),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            item.name,
                            textAlign: TextAlign.center,
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
      ],
    );
  }
}

/// Horizontally scrolling list of products available to buy with crypto.
class ProductList extends StatelessWidget {
  final List<Product> products;
  const ProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }
    final items = products.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Products',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashBoard(index: 3)),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = item.image;
              return SizedBox(
                width: 120,
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const DashBoard(index: 3)),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: imageUrl != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(imageUrl, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.shopping_bag, size: 50),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            item.name,
                            textAlign: TextAlign.center,
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
      ],
    );
  }
}



/// List of crypto-related news articles shown in the dashboard.
class TrendingNews extends StatelessWidget {
  final List<NewsArticle> news;

  const TrendingNews({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trending Crypto News',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: news.length,
          itemBuilder: (context, index) {
            final item = news[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: item.imageUrl != null
                    ? Image.network(item.imageUrl!,
                        width: 80, fit: BoxFit.cover)
                    : null,
                title: Text(item.title),
                subtitle: Text(item.source ?? ''),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticleWebView(url: item.url),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}


