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
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  bool _isFilterExpanded = false;
  Timer? _zoomDebounce;

  @override
  void dispose() {
    _zoomDebounce?.cancel();
    super.dispose();
  }

  Widget _buildTimeButton(String value, String label) {
    final bool isSelected = widget.selectedTimeframe == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onTimeframeChanged(value);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16), // Smaller border radius
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade300,
            fontWeight: FontWeight.w600,
            fontSize: 12, // Reduced font size
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
      width: 110, // Slightly reduced width
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12), // Smaller border radius
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
          Icon(icon, color: Colors.blueAccent, size: 16), // Reduced icon size
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              items: items.map((e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 12), // Reduced font size
                ),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  onChanged(val);
                }
              },
              style: const TextStyle(color: Colors.white, fontSize: 12),
              dropdownColor: Colors.grey.shade800,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent, size: 20),
              hint: Text(hint, style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36, // Reduced height
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent, size: 18),
                  hintText: "Search coins...",
                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: widget.onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _buildExpandedFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isFilterExpanded ? 180 : 0, // Reduced height
      color: Colors.grey.shade900,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 8), // Reduced spacing
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown<String>(
                    value: widget.selectedSort,
                    items: const ["Market Cap", "Rank", "Price", "Volume"],
                    onChanged: (value) {
                      widget.onSortChanged(value);
                    },
                    hint: "Sort By",
                    icon: Icons.sort,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterDropdown<int>(
                    value: widget.coinRange,
                    items: const [10, 25, 50, 100, 200, 500, 1000],
                    onChanged: (value) {
                      widget.onCoinRangeChanged(value);
                    },
                    hint: "Coins",
                    icon: Icons.format_list_numbered,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Reduced spacing
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown<String>(
                    value: widget.selectedRankRange,
                    items: const [
                      "All",
                      "0-100",
                      "100-200",
                      "200-300",
                      "300-400",
                      "400-500",
                      "500-600",
                      "600-700",
                      "700-800",
                      "800-900",
                      "900-1000",
                    ],
                    onChanged: (value) {
                      widget.onRankRangeChanged(value);
                    },
                    hint: "Rank Range",
                    icon: Icons.filter_list,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Reduced spacing
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
                          activeTrackColor: Colors.blueAccent,
                          inactiveTrackColor: Colors.grey.shade700,
                          thumbColor: Colors.white,
                          overlayColor: Colors.blueAccent.withOpacity(0.2),
                          trackHeight: 3, // Reduced track height
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
                            if (_zoomDebounce?.isActive ?? false) _zoomDebounce!.cancel();
                            _zoomDebounce = Timer(const Duration(milliseconds: 100), () {
                              widget.onZoomDebounceChanged(_zoomDebounce);
                            });
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(child: _buildCompactFilterBar()),
        _buildExpandedFilters(),
      ],
    );
  }
}