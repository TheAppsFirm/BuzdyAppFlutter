import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FullScreenChart extends StatefulWidget {
  final String url;
  const FullScreenChart({Key? key, required this.url}) : super(key: key);

  @override
  State<FullScreenChart> createState() => _FullScreenChartState();
}

class _FullScreenChartState extends State<FullScreenChart> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Scaffold(
          appBar: isLandscape ? null : AppBar(),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          ),
        );
      },
    );
  }
}
