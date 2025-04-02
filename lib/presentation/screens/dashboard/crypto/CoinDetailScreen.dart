//////
///
library;
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/coinModel.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/ui_helpers.dart';
import 'package:buzdy/presentation/widgets/CustomButton.dart';
import 'package:provider/provider.dart';

class CoinDetailScreen extends StatefulWidget {
  final CoinModel coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  int riskLevel = 0; // Ensuring it's an integer
  String investmentRecommendation = "No data available";

  @override
  void initState() {
    super.initState();
    checkCoinSecurity();
  }

  /// Fetch security details
  checkCoinSecurity() async {
    UserViewModel userViewModel =
        Provider.of<UserViewModel>(context, listen: false);

    print("Checking Security for Coin: ${widget.coin.mint}");

    final result =
        await userViewModel.checkCoinSecurity(securityToken: widget.coin.mint);

    if (result != null) {
      riskLevel = result.score; // Ensuring it's stored as an integer
      investmentRecommendation = result.recommendation;
      userViewModel.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitAction(
        title: "",
        leadinIconColor: appButtonColor,
        actionwidget: Center(
          child: CustomButton(
            width: 80,
            color: redColor,
            () => _showSecurityDialog(),
            text: "Security",
            fsize: 12.0,
          ),
        ),
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
                backgroundImage: NetworkImage(widget.coin.imageUri),
              ),
            ),
            UIHelper.verticalSpaceSm20,

            // Coin Name & Symbol
            Center(
              child: kText(
                text: "${widget.coin.name} (${widget.coin.symbol})",
                fSize: 22.0,
                fWeight: FontWeight.bold,
                tColor: mainBlackcolor,
              ),
            ),
            UIHelper.verticalSpaceSm10,

            // Description
            _buildDetailSection("Description", widget.coin.description),

            // Market Cap
            _buildDetailSection("Market Cap",
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
            _buildDetailSection(
                "Created", _formatDate(widget.coin.createdTimestamp)),

            UIHelper.verticalSpaceSm20,

            // Check Coin Security Button
            Center(
              child: CustomButton(
                color: redColor,
                () => _showSecurityDialog(),
                text: "Check Coin Security",
              ),
            ),
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

  Widget _buildDetailSection(String title, String value) {
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
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }

  /// Show Security Details in a Dialog
  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: _getRiskLevelColor(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Investment Security Check",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),

                    // Risk Level
                    _buildSecurityInfo("Risk Level:", riskLevel.toString()),

                    // Investment Advice
                    _buildSecurityInfo(
                        "Investment Advice:", investmentRecommendation),

                    const SizedBox(height: 20),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: _getRiskLevelMainColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Icon at the Top
              Positioned(
                top: -40,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _getRiskIcon(),
                    size: 45,
                    color: _getRiskLevelMainColor(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Get Risk Level Color
  List<Color> _getRiskLevelColor() {
    if (riskLevel <= 25) {
      return [Colors.redAccent, Colors.red]; // High risk (0 to 25)
    } else if (riskLevel <= 50) {
      return [Colors.orangeAccent, Colors.orange]; // Medium risk (26 to 50)
    } else {
      return [Colors.greenAccent, Colors.green]; // Low risk (51 and above)
    }
  }

  /// 🔹 Get Risk Level Main Color
  Color _getRiskLevelMainColor() {
    if (riskLevel <= 25) {
      return Colors.red;
    } else if (riskLevel <= 50) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// 🔹 Get Risk Icon
  IconData _getRiskIcon() {
    if (riskLevel <= 25) {
      return Icons.warning_amber_rounded;
    } else if (riskLevel <= 50) {
      return Icons.info_outline;
    } else {
      return Icons.check_circle;
    }
  }

  /// 🔹 Builds Security Info with Icons & Styling
  Widget _buildSecurityInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title $value",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
