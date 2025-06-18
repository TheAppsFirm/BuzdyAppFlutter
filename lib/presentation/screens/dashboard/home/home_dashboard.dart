import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/user_view_model.dart';
import '../crypto/CryptoScreen.dart';
import '../banks/bank.dart';
import '../products/products.dart';
import '../feed/feed.dart';
import '../../../widgets/glass_container.dart';

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  const StatCard({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
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
      ),
    );
  }
}

class YoutubePreview extends StatelessWidget {
  final UserViewModel vm;
  const YoutubePreview({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final videos = vm.youtubeVideos.take(3).toList();
    return videos.isEmpty
        ? const Center(child: Text('No videos'))
        : Row(
            children: videos
                .map((e) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: e.snippet?.thumbnails?.thumbnailsDefault?.url != null
                            ? Image.network(
                                e.snippet!.thumbnails!.thumbnailsDefault!.url!,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(),
                      ),
                    ))
                .toList(),
          );
  }
}

class CryptoPreview extends StatelessWidget {
  final UserViewModel vm;
  const CryptoPreview({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final coins = vm.coins.take(3).toList();
    return coins.isEmpty
        ? const Center(child: Text('No coins'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: coins
                .map((e) => Text('${e.symbol}: \$${e.rate?.toStringAsFixed(2) ?? '-'}'))
                .toList(),
          );
  }
}

class BusinessPreview extends StatelessWidget {
  final UserViewModel vm;
  const BusinessPreview({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final merchants = vm.merchantList.take(3).toList();
    return merchants.isEmpty
        ? const Center(child: Text('No data'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: merchants
                .map((e) => Text(
                      e.name ?? '-',
                      overflow: TextOverflow.ellipsis,
                    ))
                .toList(),
          );
  }
}

class ProductPreview extends StatelessWidget {
  final UserViewModel vm;
  const ProductPreview({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final products = vm.productList.take(3).toList();
    return products.isEmpty
        ? const Center(child: Text('No products'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: products
                .map((e) => Text(
                      e.name ?? '-',
                      overflow: TextOverflow.ellipsis,
                    ))
                .toList(),
          );
  }
}

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  Future<void> _refreshDashboard(UserViewModel vm) async {
    vm.resetFilters();
    await Future.wait([
      vm.getAllBanks(pageNumber: 1),
      vm.getAllMarchants(pageNumber: 1),
      vm.getAllProducts(pageNumber: 1),
      vm.fetchCoins(limit: 25, isRefresh: true),
      vm.fetchYoutubeVideos(isRefresh: true),
    ]);
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

    return Scaffold(
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
                _buildHeader(context, greeting, userName, date, time, viewModel),
              const SizedBox(height: 20),
              _buildFeatureGrid(context, viewModel),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String greeting, String userName, String date, String time, UserViewModel vm) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withOpacity(0.7),
            colors.primaryContainer.withOpacity(0.5),
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
            Text('$greeting, $userName',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: colors.onPrimary)),
          const SizedBox(height: 4),
          Text('$date · $time',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.onPrimary.withOpacity(0.8))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatCard(title: 'Videos', count: vm.youtubeVideos.length),
              StatCard(title: 'Coins', count: vm.coins.length),
              StatCard(title: 'Products', count: vm.productList.length),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search... ',
              filled: true,
              fillColor: colors.onPrimary.withOpacity(0.1),
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: vm.searchCoins,
          ),
        ],
      ),
      ),
    );
  }


  Widget _buildFeatureGrid(BuildContext context, UserViewModel vm) {
    final features = [
      {
        'title': 'YouTube',
        'icon': Icons.ondemand_video,
        'builder': YoutubePreview(vm: vm),
        'onTap': () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const FeedScreen())),
      },
      {
        'title': 'Crypto',
        'icon': Icons.currency_bitcoin,
        'builder': CryptoPreview(vm: vm),
        'onTap': () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CryptoScreen())),
      },
      {
        'title': 'Business',
        'icon': Icons.business,
        'builder': BusinessPreview(vm: vm),
        'onTap': () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const HomeScreen())),
      },
      {
        'title': 'Products',
        'icon': Icons.shopping_bag,
        'builder': ProductPreview(vm: vm),
        'onTap': () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProductsScreen())),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 200).floor().clamp(2, 4);
        final aspectRatio = constraints.maxWidth > 600 ? 1.3 : 1.1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return FeatureCard(
              title: feature['title'] as String,
              icon: feature['icon'] as IconData,
              child: feature['builder'] as Widget,
              onTap: feature['onTap'] as VoidCallback,
            );
          },
        );
      },
    );
  }



}
