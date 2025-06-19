import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/user_view_model.dart';
import '../crypto/CryptoScreen.dart';
import '../banks/bank.dart';
import '../products/products.dart';
import '../../search/search_screen.dart';
import '../../search/article_webview.dart';
import '../../search/models/news_article.dart';
import '../../../viewmodels/search_view_model.dart';
import '../../../viewmodels/analytics_view_model.dart';
import '../../../widgets/line_chart.dart';
import '../../../widgets/analytics_widgets.dart';
import '../crypto/model.dart/coinModel.dart';
import '../banks/model/merchnatModel.dart';
import '../products/model/productModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/glass_container.dart';
import 'package:buzdy/core/constants.dart';

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

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback onTap;
  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 4),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(child: child),
          ],
        ),
      )
    );
  }
}

// Removed old preview widgets

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
      _searchVm.clear();
    }
    await _analyticsVm.load();
  }

  void _onSearchChanged(String text, UserViewModel vm) {
    vm.searchCoins(text);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (text.isEmpty) {
      _searchVm.clear();
    } else {
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _searchVm.search(text);
      });
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
                    onSearchChanged: (v) => _onSearchChanged(v, viewModel),
                  ),
                  if (_analyticsVm.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  const SizedBox(height: 20),
                  const MarketTrendSection(),
                  const SizedBox(height: 20),
                  CryptoPriceSection(coins: viewModel.coins),
                  const SizedBox(height: 20),
                  const AiInsightsSection(),
                  const SizedBox(height: 20),
                  const LawPolicySection(),
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

// --- New dashboard section widgets ---

class GreetingSection extends StatelessWidget {
  final String greeting;
  final String userName;
  final String date;
  final String time;
  final TextEditingController searchController;
  final UserViewModel userVm;
  final void Function(String) onSearchChanged;

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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    onSearchChanged(searchController.text);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(
                          initialQuery: searchController.text,
                        ),
                      ),
                    );
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            QuickResultsSection(userVm: userVm),
          ],
        ),
      ),
    );
  }
}

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: coins
                  .map((e) => Text(
                        '${e.symbol}: \$${e.rate?.toStringAsFixed(2) ?? '-'}',
                      ))
                  .toList(),
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
              final query =
                  searchVm.lastQuery.isNotEmpty ? searchVm.lastQuery : 'latest crypto';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchScreen(initialQuery: query),
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
              final query =
                  searchVm.lastQuery.isNotEmpty ? searchVm.lastQuery : 'latest crypto';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchScreen(initialQuery: query),
                ),
              );
            },
          ),
      ],
    );
  }

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
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: onTap == null
          ? card
          : InkWell(onTap: onTap, child: card),
    );
  }
}

class CryptoPriceSection extends StatelessWidget {
  final List<CoinModel> coins;

  const CryptoPriceSection({super.key, required this.coins});

  CoinModel? _find(String code) {
    for (final c in coins) {
      if ((c.code ?? '').toUpperCase() == code.toUpperCase()) {
        return c;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final btc = _find('BTC');
    final eth = _find('ETH');

    Widget row(String label, CoinModel? coin) {
      final price = coin?.rate != null
          ? '\$${coin!.rate!.toStringAsFixed(2)}'
          : 'N/A';
      final change = coin?.delta?.day ?? 0;
      final color = change >= 0 ? Colors.green : Colors.red;
      final icon = change >= 0 ? Icons.trending_up : Icons.trending_down;
      return Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text('$label: $price ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('(${change.toStringAsFixed(2)}%)', style: TextStyle(color: color)),
        ],
      );
    }

    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crypto Prices',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            row('BTC', btc),
            const SizedBox(height: 4),
            row('ETH', eth),
          ],
        ),
      ),
    );
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CryptoScreen()),
      ),
      child: card,
    );
  }
}

class LawPolicySection extends StatelessWidget {
  const LawPolicySection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SearchViewModel>(context);
    if (vm.lawLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final info = vm.lawInfo;
    if (info == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Law & Policy', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Country: ${info.country}'),
            Text('Legal: ${info.legalStatus}'),
            Text('Taxation: ${info.taxation}'),
            Text('Restrictions: ${info.restrictions}'),
            if (info.link != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticleWebView(url: info.link!),
                    ),
                  );
                },
                child: const Text('Read more'),
              ),
          ],
        ),
      ),
    );
  }
}

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
        const Text('Businesses', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    ),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
        const Text('Products', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ProductsScreen()),
                    ),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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


