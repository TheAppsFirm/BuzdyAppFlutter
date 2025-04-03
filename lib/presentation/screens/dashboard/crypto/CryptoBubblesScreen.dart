import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Extension to capitalize strings.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
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

  // Filter state variables.
  String _searchQuery = "";
  String _selectedTimeframe = "hour"; // hour, day, week, month, year
  String _selectedSort = "Market Cap"; // Market Cap, Rank, Price, Volume
  int _coinRange = 50;                // How many coins to display
  double _minPercentChange = 0.0;     // Only show coins with abs(performance) >= this value
  double _zoom = 1.0;                 // Zoom factor

  // Image cache: map from coin id to preloaded ui.Image.
  final Map<String, ui.Image> _imageCache = {};
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();

    _controller.addListener(() {
      if (mounted) {
        _updateBubblePositions();
        setState(() {});
      }
    });

    // Delay bubble generation to ensure context is fully available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() async {
    try {
      setState(() => _isLoading = true);
      await _preloadImages();
      if (mounted) {
        _updateBubbles();
        setState(() => _isLoading = false);
      }
    } catch (e, stack) {
      debugPrint("Error during initialization: $e\n$stack");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Preload images for each coin.
  Future<void> _preloadImages() async {
    try {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      List<Future<void>> futures = [];

      for (var coin in userVM.bubbleCoins) {
        if (!_imageCache.containsKey(coin.id) && coin.image.isNotEmpty) {
          futures.add(
            _loadImage(coin.image).then((ui.Image img) {
              if (mounted) {
                setState(() {
                  _imageCache[coin.id] = img;
                });
              }
            }).catchError((error) {
              debugPrint("Error loading image for ${coin.id}: $error");
            }),
          );
        }
      }

      await Future.wait(futures);
    } catch (e) {
      debugPrint("Error in preloadImages: $e");
    }
  }

  /// Loads an image from a URL.
  Future<ui.Image> _loadImage(String url) async {
    // If URL starts with "file://", replace it with our base URL:
    if (url.startsWith("file://")) {
      url = "https://cryptobubbles.net/backend/data/" + url.substring(7);
    }
    try {
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
    } catch (e) {
      debugPrint("Error in _loadImage: $e");
      // Return a 1x1 placeholder image instead of rethrowing
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 1, 1),
        Paint()..color = Colors.transparent,
      );
      final picture = recorder.endRecording();
      return picture.toImage(1, 1);
    }
  }

  /// Update bubbles based on current filter settings.
  void _updateBubbles() {
    if (!mounted) return;
    final screenSize = MediaQuery.of(context).size;
    final userVM = Provider.of<UserViewModel>(context, listen: false);

    if (userVM.bubbleCoins.isEmpty) {
      setState(() => bubbles = []);
      return;
    }

    // 1) Filter coins by search query.
    List<BubbleCoinModel> filteredCoins = userVM.bubbleCoins.where((coin) {
      final query = _searchQuery.toLowerCase();
      return coin.name.toLowerCase().contains(query) ||
          coin.symbol.toLowerCase().contains(query);
    }).toList();

    // 2) Filter by minimum percentage change.
    filteredCoins = filteredCoins.where((coin) {
      double value = coin.performance[_selectedTimeframe] ?? 0.0;
      return value.abs() >= _minPercentChange;
    }).toList();

    // 3) Sort coins.
    if (_selectedSort == "Market Cap") {
      filteredCoins.sort((a, b) => b.marketcap.compareTo(a.marketcap));
    } else if (_selectedSort == "Rank") {
      filteredCoins.sort((a, b) => a.rank.compareTo(b.rank));
    } else if (_selectedSort == "Price") {
      filteredCoins.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSort == "Volume") {
      filteredCoins.sort((a, b) => b.volume.compareTo(a.volume));
    }

    // 4) Limit coin range.
    if (filteredCoins.length > _coinRange) {
      filteredCoins = filteredCoins.take(_coinRange).toList();
    }

    // 5) Generate & set new bubble list
    setState(() {
      bubbles = _generateBubbles(screenSize, filteredCoins);
    });
  }

  /// Generates bubbles from filtered coins.
  List<Bubble> _generateBubbles(
    Size screenSize,
    List<BubbleCoinModel> bubbleCoins,
  ) {
    final List<Bubble> generatedBubbles = [];

    if (screenSize.width <= 0 || screenSize.height <= 0) {
      debugPrint("Invalid screen size: $screenSize");
      return [];
    }

    const double padding = 20;
    const double bottomPadding = 200;
    final double availableWidth = max(screenSize.width - 2 * padding, 100);
    final double availableHeight =
        max(screenSize.height - 2 * padding - bottomPadding, 100);

    const int maxAttempts = 50;

    for (final coin in bubbleCoins) {
      double performanceMetric = coin.performance[_selectedTimeframe] ?? 0.0;

      // Ensure reasonable bubble sizes with constraints
      double baseSize = max(screenSize.width / 12, 30.0); // Minimum base
      double adjustedSize =
          baseSize + min(performanceMetric.abs() * 15, 100.0); // Cap growth
      double bubbleSize = max(baseSize * 1.2, adjustedSize);
      bubbleSize = min(bubbleSize, screenSize.width / 5);

      Offset position;
      bool overlaps;
      int attempts = 0;

      do {
        overlaps = false;
        position = Offset(
          padding + _random.nextDouble() * availableWidth,
          padding + _random.nextDouble() * availableHeight,
        );

        for (final other in generatedBubbles) {
          final distance = (position - other.origin).distance;
          if (distance < (bubbleSize / 2 + other.size / 2)) {
            overlaps = true;
            break;
          }
        }

        attempts++;
        if (attempts >= maxAttempts) {
          // If we can't place the bubble after max attempts, shrink it and try again
          bubbleSize *= 0.8;
          attempts = 0;
          if (bubbleSize < 10) {
            // If we've shrunk too much, skip
            overlaps = false;
            continue;
          }
        }
      } while (overlaps);

      generatedBubbles.add(
        Bubble(
          model: coin,
          origin: position,
          currentPosition: position,
          size: bubbleSize,
          velocity: Offset(
            (_random.nextDouble() * 2 - 1) * 0.2,
            (_random.nextDouble() * 2 - 1) * 0.2,
          ),
        ),
      );

      // Limit to prevent performance issues
      if (generatedBubbles.length >= 100) break;
    }
    return generatedBubbles;
  }

  /// Update bubble positions for smooth animation.
  void _updateBubblePositions() {
    for (final bubble in bubbles) {
      final newPosition = bubble.currentPosition + bubble.velocity;
      if ((newPosition - bubble.origin).distance > bubble.size / 5) {
        // If drifting too far from origin, reverse velocity
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
    double performance = bubble.model.performance[_selectedTimeframe] ?? 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            bubble.model.name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Symbol: ${bubble.model.symbol}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Price: \$${bubble.model.price.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                "${_selectedTimeframe.capitalize()} Change: "
                "${performance.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: performance > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Market Cap: \$${bubble.model.marketcap}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build a filter panel that wraps to a new line if it overflows.
  Widget _buildFilterPanel() {
    const List<int> coinRangeOptions = [10, 25, 50, 100, 200];
    const List<double> minChangeOptions = [0.0, 1.0, 2.0, 5.0, 10.0];

    return Card(
      color: Colors.white.withOpacity(0.08),
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            // Search field
            SizedBox(
              width: 120,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Search",
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  _updateBubbles();
                },
              ),
            ),

            // Timeframe Dropdown
            SizedBox(
              width: 130,
              child: DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Timeframe",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: _selectedTimeframe,
                items: const [
                  DropdownMenuItem(
                    value: "hour",
                    child: Text("Hour", style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: "day",
                    child: Text("Day", style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: "week",
                    child: Text("Week", style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: "month",
                    child: Text("Month", style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: "year",
                    child: Text("Year", style: TextStyle(color: Colors.white)),
                  ),
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

            // Sort Dropdown
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Sort by",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: _selectedSort,
                items: const [
                  DropdownMenuItem(
                    value: "Market Cap",
                    child: Text("Market Cap", style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: "Rank",
                    child: Text("Rank", style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: "Price",
                    child: Text("Price", style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: "Volume",
                    child: Text("Volume", style: TextStyle(color: Colors.white)),
                  ),
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

            // Coin Range Dropdown
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<int>(
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Top coins",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: _coinRange,
                items: coinRangeOptions
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            "$e",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
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

            // Min Change Dropdown
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<double>(
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Min ${_selectedTimeframe.capitalize()} %",
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: _minPercentChange,
                items: minChangeOptions
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          "${e.toStringAsFixed(1)}%",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
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

            // Zoom Slider
            SizedBox(
              width: 180,
              child: Row(
                children: [
                  const Text(
                    "Zoom:",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Expanded(
                    child: Slider(
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      label: _zoom.toStringAsFixed(1),
                      activeColor: Colors.blueAccent,
                      inactiveColor: Colors.grey,
                      value: _zoom,
                      onChanged: (value) {
                        setState(() => _zoom = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    try {
      return Scaffold(
        // A dark top app bar
        appBar: AppBar(
          title: const Text("Crypto Bubbles"),
          backgroundColor: Colors.black87,
        ),
        body: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF424242)], // black to dark grey
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildFilterPanel(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent,
                          ),
                        ),
                      )
                    : bubbles.isEmpty
                        ? const Center(
                            child: Text(
                              "No coins match your filter criteria",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTapDown: (details) {
                              _onTapBubble(details.localPosition);
                            },
                            child: Center(
                              child: SizedBox(
                                width: screenSize.width,
                                height: screenSize.height - 200,
                                child: AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _zoom,
                                      child: CustomPaint(
                                        size: Size(
                                          screenSize.width,
                                          screenSize.height - 200,
                                        ),
                                        painter: BubblePainter(
                                          bubbles: bubbles,
                                          timeframe: _selectedTimeframe,
                                          imageCache: _imageCache,
                                          sortBy: _selectedSort,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint("Build error: $e\n$stack");
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "An error occurred while building the UI",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
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

/// Custom painter to draw crypto bubbles with a radial gradient for better aesthetics.
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final String timeframe;
  final Map<String, ui.Image> imageCache;
  final String sortBy;

  BubblePainter({
    required this.bubbles,
    required this.timeframe,
    required this.imageCache,
    required this.sortBy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      debugPrint("Invalid canvas size: $size");
      return;
    }

    // Clip rect to avoid painting outside
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (final bubble in bubbles) {
      // Skip if out of bounds
      if (bubble.currentPosition.dx < -bubble.size ||
          bubble.currentPosition.dx > size.width + bubble.size ||
          bubble.currentPosition.dy < -bubble.size ||
          bubble.currentPosition.dy > size.height + bubble.size) {
        continue;
      }

      double performance = bubble.model.performance[timeframe] ?? 0.0;

      // Create a radial gradient for each bubble
      final gradientColors = performance >= 0
          ? [Colors.greenAccent, Colors.green.shade700]
          : [Colors.redAccent, Colors.red.shade700];

      final Paint paint = Paint()
        ..shader = RadialGradient(
          colors: gradientColors,
        ).createShader(
          Rect.fromCircle(
            center: bubble.currentPosition,
            radius: bubble.size / 2,
          ),
        );

      // Draw shadow
      final circlePath = Path()
        ..addOval(
          Rect.fromCircle(
            center: bubble.currentPosition,
            radius: bubble.size / 2,
          ),
        );
      canvas.drawShadow(circlePath, Colors.black, 4.0, true);

      // Draw the bubble (circle)
      canvas.drawCircle(bubble.currentPosition, bubble.size / 2, paint);

      // Determine display text based on sort filter
      String displayText;
      switch (sortBy) {
        case "Rank":
          displayText = bubble.model.rank.toString();
          break;
        case "Price":
          displayText = "\$${bubble.model.price.toStringAsFixed(2)}";
          break;
        case "Volume":
          displayText = bubble.model.volume.toString();
          break;
        case "Market Cap":
          displayText = "\$${bubble.model.marketcap}";
          break;
        default:
          displayText = bubble.model.symbol;
      }

      // Try to draw the coin image if available
      ui.Image? coinImage = imageCache[bubble.model.id];
      if (coinImage != null) {
        final rect = Rect.fromCenter(
          center: bubble.currentPosition,
          width: bubble.size * 0.8,
          height: bubble.size * 0.8,
        );
        try {
          paintImage(
            canvas: canvas,
            rect: rect,
            image: coinImage,
            fit: BoxFit.contain,
          );
        } catch (e) {
          debugPrint("Error painting image: $e");
          _drawFallbackText(canvas, bubble, displayText);
        }
      } else {
        _drawFallbackText(canvas, bubble, displayText);
      }

      // Draw performance text below the center of the bubble
      _drawPerformanceText(canvas, bubble, performance);
    }
  }

  /// Draw fallback text if there's no image or an error occurred.
  void _drawFallbackText(Canvas canvas, Bubble bubble, String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: bubble.size / 5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      bubble.currentPosition -
          Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  /// Draw performance text below the center of the bubble
  void _drawPerformanceText(Canvas canvas, Bubble bubble, double performance) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
