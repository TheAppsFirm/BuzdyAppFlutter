import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/coinModel.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/widgets/appBar.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/ui_helpers.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'FullScreenChart.dart';

class CoinDetailScreen extends StatefulWidget {
  final CoinModel coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  Map<String, dynamic>? aiAnalysis;
  bool isLoadingAiAnalysis = false;
  String? extraDescription;

  @override
  void initState() {
    super.initState();
    _fetchOnlineDescription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(
        title: "",
        leadinIconColor: appButtonColor,
        actionwidget: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Image
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(
                  widget.coin.png64 != null && widget.coin.png64!.isNotEmpty
                      ? widget.coin.png64!
                      : widget.coin.webp64 != null && widget.coin.webp64!.isNotEmpty
                          ? widget.coin.webp64!
                          : widget.coin.imageUri,
                ),
              ),
            ),
            UIHelper.verticalSpaceSm20,

            // Coin Name & Symbol
            Center(
              child: kText(
                text:
                    "${widget.coin.name} (${widget.coin.code ?? widget.coin.symbol})",
                fSize: 22.0,
                fWeight: FontWeight.bold,
                tColor: mainBlackcolor,
              ),
            ),
            UIHelper.verticalSpaceSm10,

            // TradingView Chart (only if a valid code or symbol is available)
            if ((widget.coin.code ?? widget.coin.symbol).trim().isNotEmpty &&
                (widget.coin.code ?? widget.coin.symbol).toUpperCase() != 'N/A')
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: InAppWebView(
                        // Build the symbol and encode it for the TradingView URL
                        initialUrlRequest: URLRequest(
                          url: WebUri(
                            'https://s.tradingview.com/widgetembed/'
                            '?symbol='
                            '${Uri.encodeComponent('BINANCE:${(widget.coin.code ?? widget.coin.symbol).toUpperCase()}USDT')}'
                            '&interval=D'
                            '&theme=dark'
                            '&hidesidetoolbar=1',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: _openFullScreenChart,
                      ),
                    ),
                  ],
                ),
              ),
            UIHelper.verticalSpaceSm20,

            // Description from API when available (full text below the chart)
            if (((widget.coin.description.trim().isNotEmpty &&
                        widget.coin.description != 'No description available') ||
                    (extraDescription != null && extraDescription!.isNotEmpty)))
              _buildDetailSection(
                "Description",
                widget.coin.description.trim().isNotEmpty &&
                        widget.coin.description != 'No description available'
                    ? widget.coin.description
                    : extraDescription ?? '',
              ),
            UIHelper.verticalSpaceSm20,

            Center(
              child: CustomButton(
                () => _fetchAndShowAiAnalysis(),
                color: appButtonColor,
                text: "AI Analysis",
                isLoading: isLoadingAiAnalysis,
              ),
            ),
            UIHelper.verticalSpaceSm10,
            _buildAiAnalysisSection(),
            UIHelper.verticalSpaceSm20,

            // Market Cap
            if (widget.coin.usdMarketCap != 0)
              _buildDetailSection(
                  "Market Cap",
                  "\$${widget.coin.usdMarketCap.toStringAsFixed(2)}"),

            // Website
            if (widget.coin.website.isNotEmpty)
              _buildClickableDetail(
                  "Website", widget.coin.website, Icons.language),

            // Twitter
            if (widget.coin.twitter.isNotEmpty)
              _buildClickableDetail(
                  "Twitter", widget.coin.twitter, Icons.twelve_mp),

            // Telegram
            if (widget.coin.telegram.isNotEmpty)
              _buildClickableDetail(
                  "Telegram", widget.coin.telegram, Icons.telegram),

            // Created Timestamp
            if (widget.coin.createdTimestamp != 0)
              _buildDetailSection(
                  "Created", _formatDate(widget.coin.createdTimestamp)),
          ],
        ),
      ),
    );
  }

  /// Format Timestamp to Readable Date
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day}-${date.month}-${date.year}";
  }

  Widget _buildDetailSection(String title, String value, {int? maxLines}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      color: appButtonColor,
      child: ListTile(
        leading: Icon(Icons.info_outline, color: Colors.white, size: 30),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.white),
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        ),
      ),
    );
  }

  void _fetchAndShowAiAnalysis() async {
    setState(() {
      isLoadingAiAnalysis = true;
    });
    UserViewModel userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    final result =
        await userViewModel.fetchCoinAnalysis(coin: widget.coin);
    if (result != null && result['analysis'] != null) {
      aiAnalysis = result['analysis'];
    }
    setState(() {
      isLoadingAiAnalysis = false;
    });
  }

  Future<void> _fetchOnlineDescription() async {
    if (widget.coin.description.trim().isNotEmpty &&
        widget.coin.description != 'No description available') {
      return;
    }
    final query = (widget.coin.code ?? widget.coin.symbol).toLowerCase();
    final searchUrl =
        Uri.parse('https://api.coingecko.com/api/v3/search?query=$query');
    final searchRes = await http.get(searchUrl);
    if (searchRes.statusCode == 200) {
      final id = jsonDecode(searchRes.body)['coins']?.first?['id'];
      if (id != null) {
        final coinUrl = Uri.parse('https://api.coingecko.com/api/v3/coins/$id');
        final coinRes = await http.get(coinUrl);
        if (coinRes.statusCode == 200) {
          final desc = jsonDecode(coinRes.body)['description']['en'];
          if (desc != null && desc is String && desc.trim().isNotEmpty) {
            setState(() {
              extraDescription = desc
                  .replaceAll(RegExp(r'<[^>]*>'), '')
                  .replaceAll('\r', '')
                  .replaceAll('\n', ' ');
            });
          }
        }
      }
    }
  }

  void _openFullScreenChart() {
    final url =
        'https://s.tradingview.com/widgetembed/?symbol=${_encodedTradingViewSymbol()}&interval=D&theme=dark&hidesidetoolbar=1';
    Get.to(FullScreenChart(url: url));
  }

  String _encodedTradingViewSymbol() {
    final asciiSymbol = (widget.coin.code != null && widget.coin.code!.trim().isNotEmpty
            ? widget.coin.code!
            : widget.coin.symbol)
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    return Uri.encodeComponent('BINANCE:${asciiSymbol.toUpperCase()}USDT');
  }

  Widget _buildAiAnalysisSection() {
    if (isLoadingAiAnalysis) {
      return const SizedBox();
    }
    if (aiAnalysis == null) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: aiAnalysis!.entries.map((entry) {
        final value = entry.value;
        if (value is Map) {
          return _buildAnalysisCard(entry.key, value.cast<String, dynamic>());
        }
        return _buildDetailSection(entry.key, value.toString());
      }).toList(),
    );
  }

  Widget _buildAnalysisCard(String title, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...data.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          e.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(e.value.toString()),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  /// Clickable Links (Website, Twitter, Telegram)
  Widget _buildClickableDetail(String title, String url, IconData icon) {
    return InkWell(
      onTap: () {},
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        color: Colors.blueAccent,
        child: ListTile(
          leading: Icon(icon, color: Colors.white, size: 30),
          title: Text(
            title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            url,
            style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                decoration: TextDecoration.underline),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
