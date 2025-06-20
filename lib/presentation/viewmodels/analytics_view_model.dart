import 'package:flutter/material.dart';
import '../../services/market_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final MarketService _service = MarketService();

  bool isLoading = true;
  double? marketCap;
  double? volume24h;
  int? totalCoins;
  int? exchanges;
  int? fearGreed;
  DateTime? lastUpdated;
  DateTime? trendStart;
  DateTime? trendEnd;
  List<double> trend = [];
  final List<String> aiInsights = [
    'Altcoins gaining momentum',
    'ETH may break resistance',
    'Watch BTC volatility this week',
  ];

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final global = await _service.fetchGlobal();
    if (global != null) {
      marketCap = (global['total_market_cap']?['usd'] as num?)?.toDouble();
      volume24h = (global['total_volume']?['usd'] as num?)?.toDouble();
      totalCoins = global['active_cryptocurrencies'] as int?;
      exchanges = global['markets'] as int?;
    }
    final trendData = await _service.fetchBitcoinTrend(7);
    trend = (trendData['trend'] as List).cast<double>();
    trendStart = trendData['start'] as DateTime;
    trendEnd = trendData['end'] as DateTime;
    fearGreed = await _service.fetchFearGreed();

    lastUpdated = DateTime.now();

    isLoading = false;
    notifyListeners();
  }
}
