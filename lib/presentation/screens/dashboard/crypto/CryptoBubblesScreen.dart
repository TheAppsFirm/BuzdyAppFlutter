import 'dart:async';
import 'dart:ui' as ui;
import 'package:buzdy/data/models/bubble.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/model.dart/bubbleCoinModel.dart';
import 'package:buzdy/presentation/widgets/bubble_area.dart';
import 'package:buzdy/presentation/widgets/bubble_details_dialog.dart';
import 'package:buzdy/presentation/widgets/bubble_physics.dart';
import 'package:buzdy/presentation/widgets/filter_panel.dart';
import 'package:buzdy/utils/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/presentation/screens/dashboard/crypto/CoinDetailScreen.dart';

class CryptoBubblesScreen extends StatefulWidget {
  const CryptoBubblesScreen({Key? key}) : super(key: key);

  @override
  State<CryptoBubblesScreen> createState() => _CryptoBubblesScreenState();
}

class _CryptoBubblesScreenState extends State<CryptoBubblesScreen>
    with SingleTickerProviderStateMixin {
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
  String _selectedRankRange = "All";
  double _zoom = 1.5; // Default zoom set to 150% (1.5)
  double _localZoom = 1.5; // Default local zoom set to 150% (1.5)

  final Map<String, ui.Image> _imageCache = {};
  bool _isLoading = true;
  String? _errorMessage;

  final Duration _bubbleAnimationDuration = const Duration(milliseconds: 800);

  late BubblePhysics _bubblePhysics;
  late ImageLoader _imageLoader;

  // Key to measure the FilterPanel height
  final GlobalKey _filterPanelKey = GlobalKey();
  double _filterPanelHeight = 80.0; // Initial estimate
  double _bottomNavHeight = 0.0; // Will be calculated dynamically

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeHelperClasses();
    _loadInitialData();
    // Add a listener to update the filter panel height when it changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilterPanelHeight();
    });
  }

  void _initializeController() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();

    _controller.addListener(() {
      if (mounted) {
        _bubblePhysics.updateBubblePositions(
          bubbles,
          MediaQuery.of(context).size,
          filterPanelHeight: _filterPanelHeight,
          bottomNavHeight: _bottomNavHeight,
        );
        setState(() {});
      }
    });
  }

  void _initializeHelperClasses() {
    _bubblePhysics = BubblePhysics(zoom: _zoom);
    _imageLoader = ImageLoader(imageCache: _imageCache);
    _localZoom = _zoom; // Ensure _localZoom matches _zoom
  }

  void _loadInitialData() {
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

      await _imageLoader.loadInitialImages(initialCoins);
      _imageLoader.loadRemainingImagesInBackground(allCoins, _coinRange);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load data: $e";
        });
      }
    }
  }

  void _updateFilterPanelHeight() {
    final filterPanelRenderBox = _filterPanelKey.currentContext?.findRenderObject() as RenderBox?;
    final newHeight = filterPanelRenderBox?.size.height ?? 80.0;
    if (newHeight != _filterPanelHeight) {
      setState(() {
        _filterPanelHeight = newHeight;
      });
      // Regenerate bubbles immediately to ensure they fit within the new bounds
      _updateBubbles(allCoins);
    }
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

      List<BubbleCoinModel> filteredCoins = _filterAndSortCoins(coinsToUse);
      filteredCoins = filteredCoins.take(_coinRange).toList();

      setState(() {
        _bubblePhysics = BubblePhysics(zoom: _zoom);
        bubbles = _bubblePhysics.generateBubbles(
          screenSize,
          filteredCoins,
          filterPanelHeight: _filterPanelHeight,
          bottomNavHeight: _bottomNavHeight,
        );
      });
    });
  }

  List<BubbleCoinModel> _filterAndSortCoins(List<BubbleCoinModel> coins) {
    List<BubbleCoinModel> filteredCoins = coins.where((coin) {
      final query = _searchQuery.toLowerCase();
      return coin.name.toLowerCase().contains(query) || coin.symbol.toLowerCase().contains(query);
    }).toList();

    if (_selectedRankRange != "All") {
      final range = _selectedRankRange.split('-').map(int.parse).toList();
      final minRank = range[0];
      final maxRank = range[1];
      filteredCoins = filteredCoins.where((coin) {
        return coin.rank >= minRank && coin.rank <= maxRank;
      }).toList();
    }

    if (_selectedSort == "Market Cap") {
      filteredCoins.sort((a, b) => b.marketcap.compareTo(a.marketcap));
    } else if (_selectedSort == "Rank") {
      filteredCoins.sort((a, b) => a.rank.compareTo(b.rank));
    } else if (_selectedSort == "Price") {
      filteredCoins.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSort == "Volume") {
      filteredCoins.sort((a, b) => b.volume.compareTo(a.volume));
    }

    return filteredCoins;
  }

  void _onTapBubble(Offset tapPosition) {
    for (final bubble in bubbles) {
      if ((tapPosition - bubble.currentPosition).distance < bubble.size / 2) {
        showDialog(
          context: context,
          builder: (context) => BubbleDetailsDialog(
            bubble: bubble,
            selectedTimeframe: _selectedTimeframe,
            imageCache: _imageCache,
            onViewDetail: () => _openDetail(bubble),
          ),
        );
        break;
      }
    }
  }

  void _openDetail(Bubble bubble) async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final coin = await userVM.fetchCoinDetail(bubble.model.symbol);
    if (coin != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: coin)),
      );
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _updateBubbles();
    });
  }

  void _onTimeframeChanged(String value) {
    setState(() {
      _selectedTimeframe = value;
      _updateBubbles();
    });
  }

  void _onSortChanged(String value) {
    setState(() {
      _selectedSort = value;
      _updateBubbles();
    });
  }

  void _onCoinRangeChanged(int value) {
    setState(() {
      _coinRange = value;
      _updateBubbles();
    });
  }

  void _onRankRangeChanged(String value) {
    setState(() {
      _selectedRankRange = value;
      _updateBubbles();
    });
  }

  void _onZoomChanged(double value) {
    setState(() {
      _localZoom = value;
    });
  }

  void _onZoomDebounceChanged(Timer? debounce) {
    setState(() {
      _zoomDebounce = debounce;
      _zoom = _localZoom;
      // Regenerate bubbles immediately with the new zoom value
      _updateBubbles(allCoins);
    });
  }

  void _onResetFilters() {
    setState(() {
      _searchQuery = "";
      _selectedRankRange = "All";
      _updateBubbles();
    });
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
    // Get the padding for the safe area (includes status bar and bottom nav bar)
    final padding = MediaQuery.of(context).padding;
    // Update the bottom nav height based on the safe area padding
    _bottomNavHeight = padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Update the filter panel height whenever the layout changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateFilterPanelHeight();
          });

          return Column(
            children: [
              FilterPanel(
                key: _filterPanelKey,
                searchQuery: _searchQuery,
                selectedTimeframe: _selectedTimeframe,
                selectedSort: _selectedSort,
                coinRange: _coinRange,
                selectedRankRange: _selectedRankRange,
                localZoom: _localZoom,
                onSearchChanged: _onSearchChanged,
                onTimeframeChanged: _onTimeframeChanged,
                onSortChanged: _onSortChanged,
                onCoinRangeChanged: _onCoinRangeChanged,
                onRankRangeChanged: _onRankRangeChanged,
                onZoomChanged: _onZoomChanged,
                onZoomDebounceChanged: _onZoomDebounceChanged,
              ),
              Expanded(
                child: SafeArea(
                  top: false, // We already handle the top with FilterPanel
                  bottom: true, // Ensure the bottom respects the nav bar
                  child: BubbleArea(
                    bubbles: bubbles,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    selectedTimeframe: _selectedTimeframe,
                    imageCache: _imageCache,
                    sortBy: _selectedSort,
                    controller: _controller,
                    bubbleAnimationDuration: _bubbleAnimationDuration,
                    onTapBubble: _onTapBubble,
                    onRetry: _initializeData,
                    onResetFilters: _onResetFilters,
                    filterPanelHeight: _filterPanelHeight,
                    bottomNavHeight: _bottomNavHeight,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}