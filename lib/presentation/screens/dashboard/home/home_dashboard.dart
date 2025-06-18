import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/user_view_model.dart';
import '../crypto/CryptoScreen.dart';
import '../banks/bank.dart';
import '../products/products.dart';
import '../feed/feed.dart';

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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refreshDashboard(viewModel),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, userName, date, time, viewModel),
              const SizedBox(height: 20),
              _buildFeatureGrid(context, viewModel),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String date, String time, UserViewModel vm) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, $userName',
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
          Row(
            children: [
              _buildStatCard(context, 'Videos', vm.youtubeVideos.length),
              const SizedBox(width: 8),
              _buildStatCard(context, 'Coins', vm.coins.length),
              const SizedBox(width: 8),
              _buildStatCard(context, 'Products', vm.productList.length),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int count) {
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


  Widget _buildFeatureGrid(BuildContext context, UserViewModel vm) {
    final features = [
      {
        'title': 'YouTube',
        'icon': Icons.ondemand_video,
        'builder': _youtubePreview(vm),
        'onTap': () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const FeedScreen())),
      },
      {
        'title': 'Crypto',
        'icon': Icons.currency_bitcoin,
        'builder': _cryptoPreview(vm),
        'onTap': () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const CryptoScreen())),
      },
      {
        'title': 'Business',
        'icon': Icons.business,
        'builder': _businessPreview(vm),
        'onTap': () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const HomeScreen())),
      },
      {
        'title': 'Products',
        'icon': Icons.shopping_bag,
        'builder': _productPreview(vm),
        'onTap': () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProductsScreen())),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _featureCard(
          context: context,
          title: feature['title'] as String,
          icon: feature['icon'] as IconData,
          child: feature['builder'] as Widget,
          onTap: feature['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _featureCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.surfaceVariant, colors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
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
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _youtubePreview(UserViewModel vm) {
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

  Widget _cryptoPreview(UserViewModel vm) {
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

  Widget _businessPreview(UserViewModel vm) {
    final merchants = vm.merchantList.take(3).toList();
    return merchants.isEmpty
        ? const Center(child: Text('No data'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: merchants.map((e) => Text(e.name ?? '-')).toList(),
          );
  }

  Widget _productPreview(UserViewModel vm) {
    final products = vm.productList.take(3).toList();
    return products.isEmpty
        ? const Center(child: Text('No products'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: products.map((e) => Text(e.name ?? '-')).toList(),
          );
  }


}
