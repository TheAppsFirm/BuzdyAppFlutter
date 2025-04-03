import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:buzdy/core/enhanced_bubble_painter.dart';
import 'package:buzdy/data/models/bubble.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/presentation/widgets/filter_panel.dart';
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

  // Filter state.
  String _searchQuery = "";
  String _selectedTimeframe = "hour";
  String _selectedSort = "Market Cap";
  int _coinRange = 50;
  double _minPercentChange = 0.0;
  double _zoom = 1.0;

  // Image cache.
  final Map<String, ui.Image> _imageCache = {};
  bool _isLoading = true;

  // Scroll controller for filter panel.
  final ScrollController _filterScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
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

  Future<ui.Image> _loadImage(String url) async {
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

  void _updateBubbles() {
    if (!mounted) return;
    final screenSize = MediaQuery.of(context).size;
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    if (userVM.bubbleCoins.isEmpty) {
      setState(() => bubbles = []);
      return;
    }

    // Apply filters.
    List<BubbleCoinModel> filteredCoins = userVM.bubbleCoins.where((coin) {
      final query = _searchQuery.toLowerCase();
      return coin.name.toLowerCase().contains(query) ||
          coin.symbol.toLowerCase().contains(query);
    }).toList();

    filteredCoins = filteredCoins.where((coin) {
      double value = coin.performance[_selectedTimeframe] ?? 0.0;
      return value.abs() >= _minPercentChange;
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

    if (filteredCoins.length > _coinRange) {
      filteredCoins = filteredCoins.take(_coinRange).toList();
    }

    setState(() {
      bubbles = _generateBubbles(screenSize, filteredCoins);
    });
  }

  List<Bubble> _generateBubbles(Size screenSize, List<BubbleCoinModel> bubbleCoins) {
    final List<Bubble> generatedBubbles = [];
    if (bubbleCoins.isEmpty || screenSize.width <= 0 || screenSize.height <= 0) {
      debugPrint("Invalid screen size or empty bubbleCoins");
      return [];
    }
    const double padding = 20;
    const double bottomPadding = 200;
    final double availableWidth = max(screenSize.width - 2 * padding, 100);
    final double availableHeight = max(screenSize.height - 2 * padding - bottomPadding, 100);
    const int maxAttempts = 50;

    for (final coin in bubbleCoins) {
      double performanceMetric = coin.performance[_selectedTimeframe] ?? 0.0;
      double baseSize = max(screenSize.width / 12, 30.0);
      double adjustedSize = baseSize + min(performanceMetric.abs() * 15, 100.0);
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
          if ((position - other.origin).distance < (bubbleSize / 2 + other.size / 2)) {
            overlaps = true;
            break;
          }
        }
        attempts++;
        if (attempts >= maxAttempts) {
          bubbleSize *= 0.8;
          attempts = 0;
          if (bubbleSize < 10) {
            overlaps = false;
            continue;
          }
        }
      } while (overlaps);

      generatedBubbles.add(Bubble(
        model: coin,
        origin: position,
        currentPosition: position,
        size: bubbleSize,
        velocity: Offset(
          (_random.nextDouble() * 2 - 1) * 0.2,
          (_random.nextDouble() * 2 - 1) * 0.2,
        ),
      ));

      if (generatedBubbles.length >= 100) break;
    }
    return generatedBubbles;
  }

  void _updateBubblePositions() {
    for (final bubble in bubbles) {
      final newPosition = bubble.currentPosition + bubble.velocity;
      if ((newPosition - bubble.origin).distance > bubble.size / 5) {
        bubble.velocity = -bubble.velocity;
      }
      bubble.currentPosition = newPosition;
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
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageCache.containsKey(bubble.model.id))
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: ClipOval(
                    child: RawImage(
                      image: _imageCache[bubble.model.id],
                      fit: BoxFit.contain,
                    ),
                  ),
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
              // Use your helper widget method to build rows.
              _buildDetailRow("Symbol", bubble.model.symbol, Icons.label_outline),
              const Divider(color: Colors.white24),
              _buildDetailRow("Price", "\$${bubble.model.price.toStringAsFixed(2)}", Icons.attach_money),
              const Divider(color: Colors.white24),
              _buildDetailRow("${_selectedTimeframe.capitalize()} Change",
                  "${performance.toStringAsFixed(2)}%", Icons.timeline,
                  valueColor: performance > 0 ? Colors.green : Colors.red),
              const Divider(color: Colors.white24),
              _buildDetailRow("Market Cap", "\$${_formatLargeNumber(bubble.model.marketcap)}", Icons.equalizer),
              const Divider(color: Colors.white24),
              _buildDetailRow("Rank", "#${bubble.model.rank}", Icons.military_tech),
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
        );
      },
    );
  }

  String _formatLargeNumber(num number) {
    if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return number.toString();
    }
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

  @override
  void dispose() {
    _controller.dispose();
    _filterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bubble_chart, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Crypto Bubbles",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.blueGrey.shade900.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                FilterPanel(
                  searchQuery: _searchQuery,
                  selectedTimeframe: _selectedTimeframe,
                  selectedSort: _selectedSort,
                  coinRange: _coinRange,
                  minPercentChange: _minPercentChange,
                  zoom: _zoom,
                  onSearchChanged: (value) {
                    _searchQuery = value;
                    _updateBubbles();
                  },
                  onTimeframeChanged: (value) {
                    setState(() {
                      _selectedTimeframe = value;
                      _updateBubbles();
                    });
                  },
                  onSortChanged: (value) {
                    setState(() {
                      _selectedSort = value;
                      _updateBubbles();
                    });
                  },
                  onCoinRangeChanged: (value) {
                    setState(() {
                      _coinRange = value;
                      _updateBubbles();
                    });
                  },
                  onMinPercentChangeChanged: (value) {
                    setState(() {
                      _minPercentChange = value;
                      _updateBubbles();
                    });
                  },
                  onZoomChanged: (value) {
                    setState(() => _zoom = value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "Displaying ${bubbles.length} coins",
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        "Tap on a bubble for details",
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                              ),
                              const SizedBox(height: 16),
                              Text("Loading crypto data...", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                            ],
                          ),
                        )
                      : bubbles.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search_off, color: Colors.white54, size: 48),
                                  const SizedBox(height: 16),
                                  const Text("No coins match your filter criteria", style: TextStyle(color: Colors.white, fontSize: 18)),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = "";
                                        _selectedTimeframe = "hour";
                                        _selectedSort = "Market Cap";
                                        _coinRange = 50;
                                        _minPercentChange = 0.0;
                                        _updateBubbles();
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text("Reset Filters"),
                                    style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTapDown: (details) {
                                _onTapBubble(details.localPosition);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _zoom,
                                        child: CustomPaint(
                                          painter: EnhancedBubblePainter(
                                            bubbles: bubbles,
                                            timeframe: _selectedTimeframe,
                                            imageCache: _imageCache,
                                            sortBy: _selectedSort,
                                          ),
                                          child: Container(),
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
        ),
      ),
    );
  }
}
