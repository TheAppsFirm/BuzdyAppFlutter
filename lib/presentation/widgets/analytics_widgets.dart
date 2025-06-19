import 'package:flutter/material.dart';
import '../viewmodels/analytics_view_model.dart';
import 'line_chart.dart';

class MarketTrendSection extends StatelessWidget {
  final AnalyticsViewModel vm;
  const MarketTrendSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.trend.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Loading...'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.show_chart),
                SizedBox(width: 4),
                Text("Market Trend", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            LineChart(data: vm.trend),
          ],
        ),
      ),
    );
  }
}

class MarketCapCard extends StatelessWidget {
  final AnalyticsViewModel vm;
  const MarketCapCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final cap = vm.marketCap ?? 0;
    final change = 0.0;
    if (vm.isLoading && cap == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Loading...'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total Market Cap", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("\$${cap.toStringAsFixed(0)}"),
            Text("24h Change: ${change.toStringAsFixed(2)}%"),
          ],
        ),
      ),
    );
  }
}

class FearGreedGauge extends StatelessWidget {
  final AnalyticsViewModel vm;
  const FearGreedGauge({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final value = vm.fearGreed ?? 0;
    if (vm.isLoading && value == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Loading...'),
        ),
      );
    }
    final color = value < 50 ? Colors.red : Colors.green;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text("Fear & Greed"),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: value / 100,
                color: color,
                backgroundColor: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text("$value"),
          ],
        ),
      ),
    );
  }
}

class AiInsightsSection extends StatelessWidget {
  final AnalyticsViewModel vm;
  const AiInsightsSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.aiInsights.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Loading...'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bolt),
                SizedBox(width: 4),
                Text("AI Insights", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ...vm.aiInsights.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text("• $e"),
                )),
          ],
        ),
      ),
    );
  }
}
