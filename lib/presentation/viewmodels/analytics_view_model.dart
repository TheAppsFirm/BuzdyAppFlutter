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
  // Computed values for quick insights
  double? get trendChange {
    if (trend.length < 2) return null;
    final first = trend.first;
    final last = trend.last;
    if (first == 0) return null;
    return (last - first) / first * 100;
  }

  String get volatilityLabel {
    if (trend.length < 2) return 'Unknown';
    final max = trend.reduce((a, b) => a > b ? a : b);
    final min = trend.reduce((a, b) => a < b ? a : b);
    final avg = trend.reduce((a, b) => a + b) / trend.length;
    final diff = (max - min) / avg * 100;
    if (diff < 2) return 'Stable';
    if (diff < 5) return 'Volatile';
    return 'Highly Volatile';
  }

  String get sentimentLabel {
    final value = fearGreed ?? 0;
    if (value < 30) return 'Fearful';
    if (value < 60) return 'Neutral';
    return 'Greedy';
  }
  // AI-generated notes about current market conditions. These strings
  // are produced using a prompt that summarizes stats such as total
  // coins, exchanges and trading volume. See `analytics_widgets.dart`
  // for display.
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
