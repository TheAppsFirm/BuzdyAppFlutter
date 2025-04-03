import 'package:buzdy/utils/string_extension.dart';
import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final String searchQuery;
  final String selectedTimeframe;
  final String selectedSort;
  final int coinRange;
  final double minPercentChange;
  final double zoom;
  final Function(String) onSearchChanged;
  final Function(String) onTimeframeChanged;
  final Function(String) onSortChanged;
  final Function(int) onCoinRangeChanged;
  final Function(double) onMinPercentChangeChanged;
  final Function(double) onZoomChanged;

  const FilterPanel({
    Key? key,
    required this.searchQuery,
    required this.selectedTimeframe,
    required this.selectedSort,
    required this.coinRange,
    required this.minPercentChange,
    required this.zoom,
    required this.onSearchChanged,
    required this.onTimeframeChanged,
    required this.onSortChanged,
    required this.onCoinRangeChanged,
    required this.onMinPercentChangeChanged,
    required this.onZoomChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const List<int> coinRangeOptions = [10, 25, 50, 100, 200];
    const List<double> minChangeOptions = [0.0, 1.0, 2.0, 5.0, 10.0];

    Widget buildFilterCard({required double width, required Widget child}) {
      return Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: child,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        children: [
          // Search Field
          buildFilterCard(
            width: 150,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Search",
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white38),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),

          // Timeframe Filter
          buildFilterCard(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    "Timeframe",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'hour', label: Text('1H', style: TextStyle(fontSize: 10))),
                      ButtonSegment(value: 'day', label: Text('1D', style: TextStyle(fontSize: 10))),
                      ButtonSegment(value: 'week', label: Text('1W', style: TextStyle(fontSize: 10))),
                      ButtonSegment(value: 'month', label: Text('1M', style: TextStyle(fontSize: 10))),
                      ButtonSegment(value: 'year', label: Text('1Y', style: TextStyle(fontSize: 10))),
                    ],
                    selected: {selectedTimeframe},
                    onSelectionChanged: (Set<String> newSelection) {
                      onTimeframeChanged(newSelection.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return states.contains(MaterialState.selected) ? Colors.blueAccent : Colors.transparent;
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return states.contains(MaterialState.selected) ? Colors.white : Colors.white70;
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sort Dropdown
          buildFilterCard(
            width: 130,
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Sort by",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white38),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              value: selectedSort,
              items: const [
                DropdownMenuItem(value: "Market Cap", child: Text("Market Cap", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: "Rank", child: Text("Rank", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: "Price", child: Text("Price", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: "Volume", child: Text("Volume", style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
            ),
          ),

          // Coin Range Dropdown
          buildFilterCard(
            width: 120,
            child: DropdownButtonFormField<int>(
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Top coins",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white38),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              value: coinRange,
              items: coinRangeOptions
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text("$e", style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) onCoinRangeChanged(value);
              },
            ),
          ),

          // Min Change Dropdown
          buildFilterCard(
            width: 140,
            child: DropdownButtonFormField<double>(
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Min ${selectedTimeframe.capitalize()} %",
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white38),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              value: minPercentChange,
              items: minChangeOptions
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text("${e.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) onMinPercentChangeChanged(value);
              },
            ),
          ),

          // Zoom Slider
          buildFilterCard(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  child: Text("Zoom", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.zoom_out, color: Colors.white60, size: 18),
                      Expanded(
                        child: Slider(
                          min: 0.5,
                          max: 2.0,
                          divisions: 15,
                          label: zoom.toStringAsFixed(1),
                          activeColor: Colors.blueAccent,
                          inactiveColor: Colors.grey,
                          value: zoom,
                          onChanged: onZoomChanged,
                        ),
                      ),
                      const Icon(Icons.zoom_in, color: Colors.white60, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
