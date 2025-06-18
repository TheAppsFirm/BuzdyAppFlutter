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
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(userName, date, time, viewModel),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildFeatureGrid(context, viewModel),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildNewsSection(),
            const SizedBox(height: 20),
            _buildAnalyticsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, String date, String time, UserViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, $userName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text('$date - $time', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Videos', vm.youtubeVideos.length),
            _buildStatCard('Coins', vm.coins.length),
            _buildStatCard('Products', vm.productList.length),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int count) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(count.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, UserViewModel vm) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: [
        _featureCard(
          title: 'YouTube',
          child: _youtubePreview(vm),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedScreen())),
        ),
        _featureCard(
          title: 'Crypto',
          child: _cryptoPreview(vm),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CryptoScreen())),
        ),
        _featureCard(
          title: 'Business',
          child: _businessPreview(vm),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeScreen())),
        ),
        _featureCard(
          title: 'Products',
          child: _productPreview(vm),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsScreen())),
        ),
      ],
    );
  }

  Widget _featureCard({required String title, required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton.small(onPressed: () {}, child: const Icon(Icons.mic)),
        FloatingActionButton.small(onPressed: () {}, child: const Icon(Icons.qr_code_scanner)),
        FloatingActionButton.small(onPressed: () {}, child: const Icon(Icons.settings)),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('News & Updates', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('No news available.'),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Analytics & Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Usage statistics will appear here.'),
      ],
    );
  }
}
