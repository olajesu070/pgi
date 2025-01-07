import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreadDetailScreen extends StatefulWidget {
  final String param;

  const ThreadDetailScreen({
    super.key, required this.param,
  });

  @override
  _ThreadDetailScreenState createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  late final WebViewController _controller;
  // final String viewUrl = dotenv.env['WHOVA_URL'] ?? 'https://pgi.org';

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController
    late final PlatformWebViewControllerCreationParams params;
    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // You can block or allow navigation here if needed
            debugPrint('Allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.param));

    // Set WebView background color
    if (!Platform.isMacOS) {
      controller.setBackgroundColor(const Color(0x80000000));
    }

    // Set platform-specific features
    // if (controller.platform is AndroidWebViewController) {
    //   AndroidWebViewController.enableDebugging(true);
    //   (controller.platform as AndroidWebViewController)
    //       .setMediaPlaybackRequiresUserGesture(false);
    // }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PGI'),
        backgroundColor: const Color(0xCC0A5338),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
