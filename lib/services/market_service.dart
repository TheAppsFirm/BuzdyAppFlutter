import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketService {
  Future<Map<String, dynamic>?> fetchGlobal() async {
    final res = await http.get(Uri.parse('https://api.coingecko.com/api/v3/global'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchBitcoinTrend(int days) async {
    final uri = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=$days');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prices = data['prices'] as List<dynamic>;
      final trend = <double>[];
      for (final item in prices) {
        trend.add((item[1] as num).toDouble());
      }
      final start = DateTime.fromMillisecondsSinceEpoch(prices.first[0]);
      final end = DateTime.fromMillisecondsSinceEpoch(prices.last[0]);
      return {
        'trend': trend,
        'start': start,
        'end': end,
      };
    }
    return {
      'trend': <double>[],
      'start': DateTime.now().subtract(Duration(days: days)),
      'end': DateTime.now(),
    };
  }

  Future<int?> fetchFearGreed() async {
    final res = await http.get(Uri.parse('https://api.alternative.me/fng/?limit=1'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final v = data['data'][0]['value'];
      return int.tryParse(v);
    }
    return null;
  }
}
