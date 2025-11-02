// 1. Dart SDK Imports
// import 'dart:convert';
// import 'dart:io';

// 2. Flutter/Package Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // The old platform-specific setup is no longer necessary for basic usage,
  // as Hybrid Composition is generally the default on modern versions.

  runApp(const QrIpfsApp());
}

class QrIpfsApp extends StatelessWidget {
  const QrIpfsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR-IPFS',
      home: Scaffold(
        appBar: AppBar(title: const Text('QR-IPFS SPA')),
        body: FutureBuilder<String>(
          future: loadLocalHtml(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return QrIpfsWebView(htmlContent: snapshot.data!);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<String> loadLocalHtml() async {
    // Ensure 'docs/index.html' is correctly listed in your pubspec.yaml assets section.
    return await rootBundle.loadString('docs/index.html');
  }
}

class QrIpfsWebView extends StatefulWidget {
  const QrIpfsWebView({super.key, required this.htmlContent});

  final String htmlContent;

  @override
  State<QrIpfsWebView> createState() => _QrIpfsWebViewState();
}

class _QrIpfsWebViewState extends State<QrIpfsWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    // 1. Create a WebViewController instance.
    controller = WebViewController()
      // 2. Configure the controller (JavaScript mode, navigation delegate, etc.).
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: Handle progress updates
            // print('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            // Optional: Handle page start
          },
          onPageFinished: (String url) {
            // Optional: Handle page finish
          },
          onWebResourceError: (WebResourceError error) {
            // Optional: Handle errors
          },
        ),
      )
      // 3. Load the HTML string using loadHtmlString.
      ..loadHtmlString(
        widget.htmlContent,
        // The base URL is often used to resolve relative paths for assets (like CSS/JS)
        // if they are bundled in a way the WebView can access.
        // For simple string loading without local asset linking, this can be null or 'about:blank'.
        // If your HTML links to local assets, consider using `loadFlutterAsset` or
        // setting up a local web server (a more complex solution).
        // Since the original code was loading from Uri.dataFromString, we stick to loadHtmlString.
      );
  }

  @override
  Widget build(BuildContext context) {
    // 4. Return the WebViewWidget, passing the configured controller.
    return WebViewWidget(controller: controller);
  }
}
