import 'dart:async';
import 'package:flutter/material.dart';

class FilterPanel extends StatefulWidget {
  final String searchQuery;
  final String selectedTimeframe;
  final String selectedSort;
  final int coinRange;
  final String selectedRankRange;
  final double localZoom;
  final Function(String) onSearchChanged;
  final Function(String) onTimeframeChanged;
  final Function(String) onSortChanged;
  final Function(int) onCoinRangeChanged;
  final Function(String) onRankRangeChanged;
  final Function(double) onZoomChanged;
  final Function(Timer?) onZoomDebounceChanged;

  const FilterPanel({
    Key? key,
    required this.searchQuery,
    required this.selectedTimeframe,
    required this.selectedSort,
    required this.coinRange,
    required this.selectedRankRange,
    required this.localZoom,
    required this.onSearchChanged,
    required this.onTimeframeChanged,
    required this.onSortChanged,
    required this.onCoinRangeChanged,
    required this.onRankRangeChanged,
    required this.onZoomChanged,
    required this.onZoomDebounceChanged,
  }) : super(key: key);

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  bool _isFilterExpanded = false;
  Timer? _zoomDebounce;
  
  // Common styles
  static const _borderRadius = 16.0;
  static const _smallBorderRadius = 12.0;
  static const _animDuration = Duration(milliseconds: 200);
  
  // Theme colors
  late final _accentColor = Colors.blueAccent;
  late final _darkGrey = Colors.grey.shade800;
  late final _darkerGrey = Colors.grey.shade900;
  late final _lightGrey = Colors.grey.shade300;
  late final _mediumGrey = Colors.grey.shade600;

  @override
  void dispose() {
    _zoomDebounce?.cancel();
    super.dispose();
  }

  Widget _buildTimeButton(String value, String label) {
    final isSelected = widget.selectedTimeframe == value;
    
    return GestureDetector(
      onTap: () => widget.onTimeframeChanged(value),
      child: AnimatedContainer(
        duration: _animDuration,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : _darkGrey,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: isSelected ? [
            BoxShadow(
              color: _accentColor.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _lightGrey,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required List<T> items,
    required Function(T) onChanged,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _darkGrey,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: _accentColor, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              items: items.map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.toString(), style: const TextStyle(fontSize: 12)),
              )).toList(),
              onChanged: (val) => val != null ? onChanged(val) : null,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              dropdownColor: _darkGrey,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent, size: 20),
              hint: Text(hint, style: TextStyle(color: _lightGrey, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // Combined methods for filter bar and expanded filters
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Compact Filter Bar
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _darkerGrey,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: _darkGrey,
                      borderRadius: BorderRadius.circular(_borderRadius),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent, size: 18),
                        hintText: "Search coins...",
                        hintStyle: TextStyle(color: _mediumGrey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: widget.onSearchChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(_borderRadius),
                    ),
                    child: Icon(
                      _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Expanded Filters
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isFilterExpanded ? 180 : 0,
          color: _darkerGrey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeframe buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTimeButton('hour', '1H'),
                      _buildTimeButton('day', '1D'),
                      _buildTimeButton('week', '1W'),
                      _buildTimeButton('month', '1M'),
                      _buildTimeButton('year', '1Y'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // First row of dropdowns
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown<String>(
                        value: widget.selectedSort,
                        items: const ["Market Cap", "Rank", "Price", "Volume"],
                        onChanged: widget.onSortChanged,
                        hint: "Sort By",
                        icon: Icons.sort,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterDropdown<int>(
                        value: widget.coinRange,
                        items: const [10, 25, 50, 100],
                        onChanged: widget.onCoinRangeChanged,
                        hint: "Coins",
                        icon: Icons.format_list_numbered,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Rank range dropdown
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown<String>(
                        value: widget.selectedRankRange,
                        items: const [
                          "All", "0-100", "100-200", "200-300", "300-400", "400-500",
                          "500-600", "600-700", "700-800", "800-900", "900-1000",
                        ],
                        onChanged: widget.onRankRangeChanged,
                        hint: "Rank Range",
                        icon: Icons.filter_list,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Zoom slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Zoom",
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _accentColor,
                              inactiveTrackColor: Colors.grey.shade700,
                              thumbColor: Colors.white,
                              overlayColor: _accentColor.withOpacity(0.2),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: widget.localZoom,
                              min: 0.5,
                              max: 2.0,
                              divisions: 30,
                              label: "${(widget.localZoom * 100).toInt()}%",
                              onChanged: (value) {
                                widget.onZoomChanged(value);
                                _zoomDebounce?.cancel();
                                _zoomDebounce = Timer(
                                  const Duration(milliseconds: 100), 
                                  () => widget.onZoomDebounceChanged(_zoomDebounce)
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${(widget.localZoom * 100).toInt()}%",
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}