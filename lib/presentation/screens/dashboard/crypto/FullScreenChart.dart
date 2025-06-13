import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FullScreenChart extends StatelessWidget {
  final String url;
  const FullScreenChart({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: InAppWebView(initialUrlRequest: URLRequest(url: WebUri(url))),
    );
  }
}
