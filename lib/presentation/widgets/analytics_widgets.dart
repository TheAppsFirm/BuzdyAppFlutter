import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/analytics_view_model.dart';
import 'line_chart.dart';

class MarketTrendSection extends StatelessWidget {
  const MarketTrendSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AnalyticsViewModel>(context);
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
              children: [
                const Icon(Icons.show_chart),
                const SizedBox(width: 4),
                const Text("Market Trend", style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (vm.trendChange != null)
                  Text(
                    '${vm.trendChange! >= 0 ? '+' : ''}${vm.trendChange!.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: vm.trendChange! >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(vm.volatilityLabel),
              ],
            ),
            const SizedBox(height: 8),
            LineChart(data: vm.trend),
            if (vm.trendStart != null && vm.trendEnd != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM d').format(vm.trendStart!)),
                    Text(DateFormat('MMM d').format(vm.trendEnd!)),
                  ],
                ),
              ),
            if (vm.trendChange != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'BTC has moved ${vm.trendChange!.toStringAsFixed(2)}% over the last 7 days',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MarketCapCard extends StatelessWidget {
  const MarketCapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AnalyticsViewModel>(context);
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
  const FearGreedGauge({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AnalyticsViewModel>(context);
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
            const SizedBox(width: 4),
            Text(vm.sentimentLabel),
          ],
        ),
      ),
    );
  }
}

/// Displays a list of short market takeaways generated from the
/// current analytics data.
class AiInsightsSection extends StatelessWidget {
  const AiInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AnalyticsViewModel>(context);
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
                  child: Row(
                    children: [
                      const Text('🔮'),
                      const SizedBox(width: 4),
                      Expanded(child: Text(e)),
                    ],
                  ),
                )),
            if (vm.lastUpdated != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Last updated: '
                  '${DateTime.now().difference(vm.lastUpdated!).inMinutes} mins ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
