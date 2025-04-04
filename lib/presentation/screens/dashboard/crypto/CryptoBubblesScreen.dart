import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:buzdy/core/enhanced_bubble_painter.dart';
import 'package:buzdy/data/models/bubble.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';

class CryptoBubblesScreen extends StatefulWidget {
  const CryptoBubblesScreen({Key? key}) : super(key: key);

  @override
  State<CryptoBubblesScreen> createState() => _CryptoBubblesScreenState();
}

class _CryptoBubblesScreenState extends State<CryptoBubblesScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _controller;
  List<Bubble> bubbles = [];
  List<BubbleCoinModel> allCoins = [];
  Timer? _debounce;
  Timer? _zoomDebounce;

  // Filter state
  String _searchQuery = "";
  String _selectedTimeframe = "hour";
  String _selectedSort = "Market Cap";
  int _coinRange = 25;
  double _zoom = 1.0;
  double _localZoom = 1.0;

  // Image cache
  final Map<String, ui.Image> _imageCache = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();

    _controller.addListener(() {
      if (mounted) {
        _updateBubblePositions();
        setState(() {});
      }
    });

    _localZoom = _zoom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      final fetchedCoins = await userVM.fetchBubbleCoins();
      if (fetchedCoins.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "No data available. Please try again.";
        });
        return;
      }

      allCoins = fetchedCoins;
      final initialCoins = allCoins.take(_coinRange).toList();
      _updateBubbles(initialCoins);

      if (mounted) {
        setState(() => _isLoading = false);
      }

      _loadInitialImages(initialCoins);
      _loadRemainingImagesInBackground();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load data: $e";
        });
      }
    }
  }

  Future<void> _loadInitialImages(List<BubbleCoinModel> coins) async {
    for (var coin in coins) {
      if (!_imageCache.containsKey(coin.id)) {
        final image = await _loadImage(coin.image);
        if (mounted) {
          setState(() {
            _imageCache[coin.id] = image;
          });
        }
      }
    }
  }

  Future<void> _loadRemainingImagesInBackground() async {
    final remainingCoins = allCoins.skip(_coinRange).toList();
    const int batchSize = 50;
    for (int i = 0; i < remainingCoins.length; i += batchSize) {
      final batch = remainingCoins.skip(i).take(batchSize).toList();
      await Future.wait(batch.map((coin) async {
        if (!_imageCache.containsKey(coin.id)) {
          final image = await _loadImage(coin.image);
          if (mounted) {
            setState(() {
              _imageCache[coin.id] = image;
            });
          }
        }
      }));
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<ui.Image> _loadImage(String url) async {
    if (url.isEmpty) return _createFallbackImage();
    try {
      if (url.startsWith('data/logos/') || !url.startsWith('http')) {
        url = 'https://cryptobubbles.net/backend/' + url;
      }
      final completer = Completer<ui.Image>();
      final networkImage = NetworkImage(url);
      final stream = networkImage.resolve(const ImageConfiguration());
      stream.addListener(ImageStreamListener(
        (info, _) => completer.complete(info.image),
        onError: (error, _) => completer.complete(_createFallbackImage()),
      ));
      return await completer.future;
    } catch (e) {
      return _createFallbackImage();
    }
  }

  Future<ui.Image> _createFallbackImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Rect.fromLTWH(0, 0, 1, 1), Paint()..color = Colors.transparent);
    return (recorder.endRecording()).toImage(1, 1);
  }

  void _updateBubbles([List<BubbleCoinModel>? coins]) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final screenSize = MediaQuery.of(context).size;
      List<BubbleCoinModel> coinsToUse = coins ?? allCoins;

      if (coinsToUse.isEmpty) {
        setState(() => bubbles = []);
        return;
      }

      List<BubbleCoinModel> filteredCoins = coinsToUse.where((coin) {
        final query = _searchQuery.toLowerCase();
        return coin.name.toLowerCase().contains(query) || coin.symbol.toLowerCase().contains(query);
      }).toList();

      if (_selectedSort == "Market Cap") {
        filteredCoins.sort((a, b) => b.marketcap.compareTo(a.marketcap));
      } else if (_selectedSort == "Rank") {
        filteredCoins.sort((a, b) => a.rank.compareTo(b.rank));
      } else if (_selectedSort == "Price") {
        filteredCoins.sort((a, b) => b.price.compareTo(a.price));
      } else if (_selectedSort == "Volume") {
        filteredCoins.sort((a, b) => b.volume.compareTo(a.volume));
      }

      filteredCoins = filteredCoins.take(_coinRange).toList();

      setState(() {
        bubbles = _generateBubbles(screenSize, filteredCoins);
      });
    });
  }

  List<Bubble> _generateBubbles(Size screenSize, List<BubbleCoinModel> bubbleCoins) {
    final List<Bubble> generatedBubbles = [];
    if (bubbleCoins.isEmpty || screenSize.width <= 0 || screenSize.height <= 0) return [];

    const double repulsionForce = 12.0;
    const double centeringForce = 0.002; // Further reduced to allow more spread
    const int simulationSteps = 200;

    const double topBarHeight = 140.0;
    const double bottomNavHeight = 80;
    final double availableHeight = screenSize.height - topBarHeight - bottomNavHeight;
    // Center the bubbles in the available space
    final Offset center = Offset(
      screenSize.width / 2,
      topBarHeight + (availableHeight / 2), // Center between top bar and bottom nav
    );

    double minMarketCap = double.maxFinite;
    double maxMarketCap = 0;
    for (final coin in bubbleCoins) {
      if (coin.marketcap > 0) {
        minMarketCap = min(minMarketCap, coin.marketcap.toDouble());
        maxMarketCap = max(maxMarketCap, coin.marketcap.toDouble());
      }
    }
    minMarketCap = minMarketCap == double.maxFinite ? 1000000 : minMarketCap;
    maxMarketCap = maxMarketCap == 0 ? 1000000000000 : maxMarketCap;

    final double bubbleAreaMultiplier = _zoom;
    final double minSize = 40.0 * bubbleAreaMultiplier;
    final double maxSize = min(screenSize.width * 0.2, 120.0) * bubbleAreaMultiplier;

    for (final coin in bubbleCoins) {
      if (coin.marketcap <= 0) continue;

      double bubbleSize = minSize;
      try {
        double logMin = log(minMarketCap);
        double logMax = log(maxMarketCap);
        double logVal = log(coin.marketcap.toDouble());
        double ratio = (logVal - logMin) / (logMax - logMin);
        ratio = ratio.clamp(0.0, 1.0);
        bubbleSize = minSize + ratio * (maxSize - minSize);
      } catch (_) {}

      // Increase radius to use more of the available space
      final double radius = min(screenSize.width, availableHeight) * 0.8; // Increased radius
      final double angle = _random.nextDouble() * 2 * pi;
      final double distance = _random.nextDouble() * radius;

      final Offset initialPosition = center + Offset(cos(angle) * distance, sin(angle) * distance);
      generatedBubbles.add(Bubble(
        model: coin,
        origin: initialPosition,
        currentPosition: initialPosition,
        size: bubbleSize,
        velocity: Offset.zero,
      ));
    }

    for (int step = 0; step < simulationSteps; step++) {
      for (int i = 0; i < generatedBubbles.length; i++) {
        final Bubble bubbleA = generatedBubbles[i];
        Offset totalForce = (center - bubbleA.currentPosition) * centeringForce;

        for (int j = 0; j < generatedBubbles.length; j++) {
          if (i == j) continue;
          final Bubble bubbleB = generatedBubbles[j];
          final Offset direction = bubbleA.currentPosition - bubbleB.currentPosition;
          final double distance = max(direction.distance, 0.1);
          final double minDistance = (bubbleA.size + bubbleB.size) / 2;

          if (distance < minDistance * 1.05) {
            final double forceMagnitude = repulsionForce * (minDistance * 1.05 - distance) / (minDistance * 1.05);
            totalForce += Offset(direction.dx / distance * forceMagnitude, direction.dy / distance * forceMagnitude);
          }
        }

        bubbleA.currentPosition += totalForce * (1.0 - step / simulationSteps);
        final double padding = bubbleA.size / 2;
        bubbleA.currentPosition = Offset(
          bubbleA.currentPosition.dx.clamp(padding, screenSize.width - padding),
          bubbleA.currentPosition.dy.clamp(topBarHeight + padding, screenSize.height - bottomNavHeight - padding),
        );
        if (step == simulationSteps - 1) bubbleA.origin = bubbleA.currentPosition;
      }
    }

    for (final bubble in generatedBubbles) {
      bubble.velocity = Offset((_random.nextDouble() * 2 - 1) * 0.1, (_random.nextDouble() * 2 - 1) * 0.1);
    }

    return generatedBubbles;
  }

  void _updateBubblePositions() {
    final screenSize = MediaQuery.of(context).size;
    const double topBarHeight = 140.0;
    const double bottomNavHeight = 80;

    for (final bubble in bubbles) {
      final newPosition = bubble.currentPosition + bubble.velocity;
      if ((newPosition - bubble.origin).distance > bubble.size / 8) {
        bubble.velocity = -bubble.velocity * 0.95;
      }
      bubble.currentPosition = newPosition;

      final double padding = bubble.size / 2;
      if (bubble.currentPosition.dx < padding || bubble.currentPosition.dx > screenSize.width - padding) {
        bubble.velocity = Offset(-bubble.velocity.dx, bubble.velocity.dy);
      }
      if (bubble.currentPosition.dy < topBarHeight + padding || bubble.currentPosition.dy > screenSize.height - bottomNavHeight - padding) {
        bubble.velocity = Offset(bubble.velocity.dx, -bubble.velocity.dy);
      }
      bubble.currentPosition = Offset(
        bubble.currentPosition.dx.clamp(padding, screenSize.width - padding),
        bubble.currentPosition.dy.clamp(topBarHeight + padding, screenSize.height - bottomNavHeight - padding),
      );
    }
  }

  void _onTapBubble(Offset tapPosition) {
    for (final bubble in bubbles) {
      if ((tapPosition - bubble.currentPosition).distance < bubble.size / 2) {
        _showBubbleDetails(bubble);
        break;
      }
    }
  }

  void _showBubbleDetails(Bubble bubble) {
    double performance = bubble.model.performance[_selectedTimeframe] ?? 0.0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageCache.containsKey(bubble.model.id))
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                child: ClipOval(child: RawImage(image: _imageCache[bubble.model.id], fit: BoxFit.contain)),
              ),
            Flexible(
              child: Text(
                bubble.model.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow("Symbol", bubble.model.symbol, Icons.label_outline),
            const Divider(color: Colors.white24),
            _buildDetailRow("Price", "\$${bubble.model.price.toStringAsFixed(2)}", Icons.attach_money),
            const Divider(color: Colors.white24),
            _buildDetailRow("${_selectedTimeframe.capitalize()} Change", "${performance.toStringAsFixed(2)}%",
                Icons.timeline,
                valueColor: performance > 0 ? Colors.green : Colors.red),
            const Divider(color: Colors.white24),
            _buildDetailRow("Market Cap", "\$${_formatLargeNumber(bubble.model.marketcap)}", Icons.equalizer),
            const Divider(color: Colors.white24),
            _buildDetailRow("Rank", "#${bubble.model.rank}", Icons.military_tech),
            const Divider(color: Colors.white24),
            _buildDetailRow("Volume", "\$${_formatLargeNumber(bubble.model.volume)}", Icons.bar_chart),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatLargeNumber(num number) {
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(2)}M';
    if (number >= 1e3) return '${(number / 1e3).toStringAsFixed(2)}K';
    return number.toString();
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Text("$label:", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String value, String label) {
    final bool isSelected = _selectedTimeframe == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = value;
          _updateBubbles();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade300,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(String label, T value, List<T> items, Function(T) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: DropdownButton<T>(
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
            onChanged: (val) => onChanged(val as T),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            dropdownColor: Colors.grey.shade800,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    _zoomDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Custom Top Bar with Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: SafeArea(
              child: Column(
                children: [
                  // First Row: Search Bar
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                      hintText: "Search coins...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _updateBubbles();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Second Row: Filters with Horizontal Scroller
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTimeButton('hour', '1H'),
                        _buildTimeButton('day', '1D'),
                        _buildTimeButton('week', '1W'),
                        _buildTimeButton('month', '1M'),
                        _buildTimeButton('year', '1Y'),
                        const SizedBox(width: 8),
                        _buildDropdown("Sort By", _selectedSort, ["Market Cap", "Rank", "Price", "Volume"], (value) {
                          setState(() {
                            _selectedSort = value as String;
                            _updateBubbles();
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildDropdown("Coins", _coinRange, [10, 25, 50, 100, 200], (value) {
                          setState(() {
                            _coinRange = value as int;
                            _updateBubbles();
                          });
                        }),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Zoom",
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 150,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 6.0,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                        activeTrackColor: Colors.blueAccent,
                                        inactiveTrackColor: Colors.grey.shade700,
                                        thumbColor: Colors.blueAccent,
                                        overlayColor: Colors.blueAccent.withOpacity(0.3),
                                      ),
                                      child: Slider(
                                        value: _localZoom,
                                        min: 0.5,
                                        max: 2.0,
                                        divisions: 15,
                                        onChanged: (value) {
                                          setState(() {
                                            _localZoom = value;
                                          });
                                          if (_zoomDebounce?.isActive ?? false) _zoomDebounce!.cancel();
                                          _zoomDebounce = Timer(const Duration(milliseconds: 100), () {
                                            setState(() {
                                              _zoom = value;
                                              _updateBubbles();
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${(_localZoom * 100).toInt()}%",
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bubble Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [Colors.black, Colors.blueGrey.shade900],
                ),
              ),
              child: Stack(
                children: [
                  if (_isLoading)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.blueAccent),
                          SizedBox(height: 16),
                          Text('Loading bubbles...', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _initializeData,
                            child: const Text('Retry', style: TextStyle(color: Colors.blueAccent)),
                          ),
                        ],
                      ),
                    )
                  else if (bubbles.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bubble_chart, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No coins to display', style: TextStyle(color: Colors.white, fontSize: 18)),
                          TextButton(
                            onPressed: () => setState(() {
                              _searchQuery = "";
                              _updateBubbles();
                            }),
                            child: const Text('Reset Filters', style: TextStyle(color: Colors.blueAccent)),
                          ),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTapUp: (details) => _onTapBubble(details.localPosition),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => CustomPaint(
                          size: Size(screenSize.width, screenSize.height),
                          painter: EnhancedBubblePainter(
                            bubbles: bubbles,
                            timeframe: _selectedTimeframe,
                            imageCache: _imageCache,
                            sortBy: _selectedSort,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}