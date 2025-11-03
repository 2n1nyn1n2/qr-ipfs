// 1. Dart SDK Imports
// (Keep these commented as they aren't needed for the final code)
// import 'dart:convert'; 
// import 'dart:io';

// 2. Flutter/Package Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  // --- New: Define the Javascript Channel for logging ---
  JavascriptChannel _printChannel() {
    return JavascriptChannel(
      name: 'Print', // This is the channel name JavaScript will use
      onMessageReceived: (JavascriptMessage message) {
        // Output the message to the Flutter/Dart console
        debugPrint('JS_CONSOLE: ${message.message}');
      },
    );
  }
  // --------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // 1. Create a WebViewController instance.
    controller = WebViewController()
      // 2. Configure the controller (JavaScript mode, navigation delegate, etc.).
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      
      // --- Update: Add the Javascript Channel for logging ---
      ..addJavaScriptChannel(
        'Print', 
        onMessageReceived: (message) {
          debugPrint('JS_CONSOLE: ${message.message}');
        },
      )
      // ----------------------------------------------------

      // Optional: Set platform details for Android for explicit debugging enablement
      // (This is often not needed in debug mode, but doesn't hurt)
      ..setPlatformDetails(AndroidWebViewControllerDetails(
          debuggingEnabled: true,
      ))

      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: Handle progress updates
          },
          onPageStarted: (String url) {
            // Optional: Handle page start
          },
          onPageFinished: (String url) {
            // This is a good place to inject a function to intercept console.log()
            // if you want to automatically redirect ALL JS console messages.
            // For now, we rely on the JS file calling 'Print.postMessage()'.
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web Resource Error: ${error.description}');
          },
        ),
      )
      // 3. Load the HTML string using loadHtmlString.
      ..loadHtmlString(
        widget.htmlContent,
        // Using 'http://localhost' as a virtual base URL can help some web 
        // technologies (like history API) function better, even for local content.
        baseUrl: 'http://localhost', 
      );
  }

  @override
  Widget build(BuildContext context) {
    // 4. Return the WebViewWidget, passing the configured controller.
    return WebViewWidget(controller: controller);
  }
}
