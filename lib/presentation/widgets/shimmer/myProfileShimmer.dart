import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

// Extension to capitalize strings.
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class CryptoBubblesScreen extends StatefulWidget {
  const CryptoBubblesScreen({super.key});

  @override
  State<CryptoBubblesScreen> createState() => _CryptoBubblesScreenState();
}

class _CryptoBubblesScreenState extends State<CryptoBubblesScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _controller;
  List<Bubble> bubbles = [];

  // Filter state variables
  String _searchQuery = "";
  String _selectedTimeframe = "hour"; // Options: hour, day, week, month, year
  String _selectedSort = "Market Cap"; // Options: Market Cap, Rank, Price, Volume
  int _coinRange = 50; // How many coins to display
  double _minPercentChange = 0.0; // Only show coins with abs(performance) >= this value

  // Image cache: map from coin id to preloaded ui.Image.
  final Map<String, ui.Image> _imageCache = {};

  @override
  void initState() {
    super.initState();
    final userVM = Provider.of<UserViewModel>(context, listen: false);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();

    _controller.addListener(() {
      _updateBubblePositions();
      setState(() {});
    });

    // Preload images for bubble coins.
    _preloadImages();

    // Generate bubbles after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBubbles();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Preload images for each coin in the bubble coin list.
  void _preloadImages() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    for (var coin in userVM.bubbleCoins) {
      if (!_imageCache.containsKey(coin.id) && coin.image.isNotEmpty) {
        _loadImage(coin.image).then((ui.Image img) {
          setState(() {
            _imageCache[coin.id] = img;
          });
        }).catchError((error) {
          debugPrint("Error loading image for ${coin.id}: $error");
        });
      }
    }
  }

  /// Loads an image from a URL and returns a [ui.Image].
  Future<ui.Image> _loadImage(String url) async {
    final completer = Completer<ui.Image>();
    final networkImage = NetworkImage(url);
    final stream = networkImage.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }, onError: (error, stackTrace) {
      completer.completeError(error, stackTrace);
    });
    stream.addListener(listener);
    final image = await completer.future;
    stream.removeListener(listener);
    return image;
  }

  /// Update the bubbles based on the current filter settings.
  void _updateBubbles() {
    final screenSize = MediaQuery.of(context).size;
    final userVM = Provider.of<UserViewModel>(context, listen: false);

    // Filter coins by search query.
    List<BubbleCoinModel> filteredCoins = userVM.bubbleCoins.where((coin) {
      final query = _searchQuery.toLowerCase();
      return coin.name.toLowerCase().contains(query) ||
          coin.symbol.toLowerCase().contains(query);
    }).toList();

    // Filter by minimum percentage change (absolute value)
    filteredCoins = filteredCoins.where((coin) {
      double value;
      try {
        value = coin.performance[_selectedTimeframe] ?? 0.0;
      } catch (e) {
        debugPrint("Error accessing performance for coin ${coin.id}: $e");
        value = 0.0;
      }
      return value.abs() >= _minPercentChange;
    }).toList();

    // Sort coins based on selected sort.
    if (_selectedSort == "Market Cap") {
      filteredCoins.sort((a, b) => b.marketcap.compareTo(a.marketcap));
    } else if (_selectedSort == "Rank") {
      filteredCoins.sort((a, b) => a.rank.compareTo(b.rank));
    } else if (_selectedSort == "Price") {
      filteredCoins.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSort == "Volume") {
      filteredCoins.sort((a, b) => b.volume.compareTo(a.volume));
    }

    // Limit to the selected coin range.
    if (filteredCoins.length > _coinRange) {
      filteredCoins = filteredCoins.take(_coinRange).toList();
    }

    setState(() {
      bubbles = _generateBubbles(screenSize, filteredCoins);
    });
  }

  /// Generates crypto bubbles using the filtered coin list.
  List<Bubble> _generateBubbles(
      Size screenSize, List<BubbleCoinModel> bubbleCoins) {
    final List<Bubble> bubbles = [];
    const double padding = 20;
    const double bottomPadding = 200; // Ensure no bubbles are too low

    for (final coin in bubbleCoins) {
      double performanceMetric;
      try {
        performanceMetric = coin.performance[_selectedTimeframe] ?? 0.0;
      } catch (e) {
        debugPrint("Error in performanceMetric for coin ${coin.id}: $e");
        performanceMetric = 0.0;
      }

      double baseSize = screenSize.width / 12;
      double adjustedSize = baseSize + performanceMetric.abs() * 15;

      double bubbleSize = max(baseSize * 1.2, adjustedSize);
      bubbleSize = min(bubbleSize, screenSize.width / 5);

      Offset position;
      bool overlaps;

      do {
        overlaps = false;
        position = Offset(
          padding + _random.nextDouble() * (screenSize.width - 2 * padding),
          padding +
              _random.nextDouble() *
                  (screenSize.height - 2 * padding - bottomPadding),
        );

        for (final other in bubbles) {
          final distance = (position - other.origin).distance;
          if (distance < (bubbleSize / 2 + other.size / 2)) {
            overlaps = true;
            break;
          }
        }
      } while (overlaps);

      bubbles.add(Bubble(
        model: coin,
        origin: position,
        currentPosition: position,
        size: bubbleSize,
        velocity: Offset(
          (_random.nextDouble() * 2 - 1) * 0.4,
          (_random.nextDouble() * 2 - 1) * 0.4,
        ),
      ));
    }
    return bubbles;
  }

  /// Update bubble positions for smooth animation.
  void _updateBubblePositions() {
    for (final bubble in bubbles) {
      final newPosition = bubble.currentPosition + bubble.velocity;
      if ((newPosition - bubble.origin).distance > bubble.size / 5) {
        bubble.velocity = -bubble.velocity;
      }
      bubble.currentPosition = newPosition;
    }
  }

  /// Detect tapped bubble and show its details.
  void _onTapBubble(Offset tapPosition) {
    for (final bubble in bubbles) {
      final distance = (tapPosition - bubble.currentPosition).distance;
      if (distance < bubble.size / 2) {
        _showBubbleDetails(bubble);
        break;
      }
    }
  }

  /// Show bubble details in a dialog.
  void _showBubbleDetails(Bubble bubble) {
    double performance;
    try {
      performance = bubble.model.performance[_selectedTimeframe] ?? 0.0;
    } catch (e) {
      debugPrint("Error retrieving performance for details: $e");
      performance = 0.0;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            bubble.model.name,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Symbol: ${bubble.model.symbol}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Price: \$${bubble.model.price.toStringAsFixed(2)}"),
              Text(
                "${_selectedTimeframe.capitalize()} Change: ${performance.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: performance > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text("Market Cap: \$${bubble.model.marketcap}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  /// Build the filter panel with search, dropdowns for timeframe, sort, coin range, and minimum change.
  Widget _buildFilterPanel() {
    // Options for coin range and minimum percent change.
    const List<int> coinRangeOptions = [10, 25, 50, 100, 200];
    const List<double> minChangeOptions = [0.0, 1.0, 2.0, 5.0, 10.0];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search field.
          TextField(
            decoration: InputDecoration(
              labelText: "Search coins",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _updateBubbles();
            },
          ),
          const SizedBox(height: 8),
          // Row for timeframe, sort, coin range, and min change.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Timeframe Dropdown.
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Timeframe",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _selectedTimeframe,
                  items: const [
                    DropdownMenuItem(value: "hour", child: Text("Hour")),
                    DropdownMenuItem(value: "day", child: Text("Day")),
                    DropdownMenuItem(value: "week", child: Text("Week")),
                    DropdownMenuItem(value: "month", child: Text("Month")),
                    DropdownMenuItem(value: "year", child: Text("Year")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTimeframe = value;
                        _updateBubbles();
                      });
                    }
                  },
                ),
              ),
              // Sort Dropdown.
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Sort by",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _selectedSort,
                  items: const [
                    DropdownMenuItem(
                        value: "Market Cap", child: Text("Market Cap")),
                    DropdownMenuItem(value: "Rank", child: Text("Rank")),
                    DropdownMenuItem(value: "Price", child: Text("Price")),
                    DropdownMenuItem(value: "Volume", child: Text("Volume")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSort = value;
                        _updateBubbles();
                      });
                    }
                  },
                ),
              ),
              // Coin Range Dropdown.
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Show top",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _coinRange,
                  items: coinRangeOptions
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text("$e coins")))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _coinRange = value;
                        _updateBubbles();
                      });
                    }
                  },
                ),
              ),
              // Minimum Change Dropdown.
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<double>(
                  decoration: InputDecoration(
                    labelText: "Min % Change",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _minPercentChange,
                  items: minChangeOptions
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text("${e.toStringAsFixed(1)}%")))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _minPercentChange = value;
                        _updateBubbles();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Place the filter panel above the bubble chart.
      body: Column(
        children: [
          _buildFilterPanel(),
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                _onTapBubble(details.localPosition);
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: screenSize,
                    painter: BubblePainter(
                      bubbles: bubbles,
                      timeframe: _selectedTimeframe,
                      imageCache: _imageCache,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bubble model for crypto bubbles.
class Bubble {
  final BubbleCoinModel model;
  final Offset origin;
  Offset currentPosition;
  double size;
  Offset velocity;

  Bubble({
    required this.model,
    required this.origin,
    required this.currentPosition,
    required this.size,
    required this.velocity,
  });
}

/// Custom painter to draw crypto bubbles.
/// It draws the coin image (if loaded) or falls back to coin symbol.
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final String timeframe;
  final Map<String, ui.Image> imageCache;

  BubblePainter({
    required this.bubbles,
    required this.timeframe,
    required this.imageCache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final bubble in bubbles) {
      double performance;
      try {
        performance = bubble.model.performance[timeframe] ?? 0.0;
      } catch (e) {
        debugPrint("Error in BubblePainter performance: $e");
        performance = 0.0;
      }
      paint.color = performance > 0
          ? Colors.green.withOpacity(0.7)
          : Colors.red.withOpacity(0.7);

      // Draw the bubble.
      canvas.drawCircle(bubble.currentPosition, bubble.size / 2, paint);

      // Draw coin image inside the bubble if available.
      ui.Image? coinImage = imageCache[bubble.model.id];
      if (coinImage != null) {
        final rect = Rect.fromCenter(
          center: bubble.currentPosition,
          width: bubble.size * 0.8,
          height: bubble.size * 0.8,
        );
        paintImage(
          canvas: canvas,
          rect: rect,
          image: coinImage,
          fit: BoxFit.contain,
        );
      } else {
        // Fallback: draw the coin symbol text.
        final TextPainter symbolPainter = TextPainter(
          text: TextSpan(
            text: bubble.model.symbol,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: bubble.size / 5,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        symbolPainter.layout();
        symbolPainter.paint(
          canvas,
          bubble.currentPosition -
              Offset(symbolPainter.width / 2, symbolPainter.height / 2),
        );
      }

      // Draw performance percentage below the image/text.
      final TextPainter percentagePainter = TextPainter(
        text: TextSpan(
          text: "${performance.toStringAsFixed(1)}%",
          style: TextStyle(
            color: Colors.white,
            fontSize: bubble.size / 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      percentagePainter.layout();
      percentagePainter.paint(
        canvas,
        bubble.currentPosition +
            Offset(-percentagePainter.width / 2, bubble.size / 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
