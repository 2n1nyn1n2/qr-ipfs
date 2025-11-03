// 1. Dart SDK Imports
// (Keep these commented as they aren't needed for the final code)
// import 'dart:convert';
// import 'dart:io';

// 2. Flutter/Package Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
// We still need the Android package to access platform-specific configurations
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Note: webview_flutter_platform_interface is no longer directly needed, so we
// remove the import to resolve the 'depend_on_referenced_packages' warning.

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
    // Assuming 'docs/index.html' is in your assets
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

  // Removed the unused, outdated _printChannel method definition.

  @override
  void initState() {
    super.initState();

    // 1. Create a WebViewController instance.
    final WebViewController webController = WebViewController()
      // 2. Configure the controller (JavaScript mode, navigation delegate, etc.).
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // --- FIX: Use JavaScriptChannel (capital J) and JavaScriptMessage ---
      ..addJavaScriptChannel(
        'Print', // This name must match the one used in JavaScript
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('JS_CONSOLE: ${message.message}');
        },
      )
      // --------------------------------------------------------------------
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: Handle progress updates
          },
          onPageStarted: (String url) {
            // Optional: Handle page start
          },
          onPageFinished: (String url) {
            // Optional: Handle page finished
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

    // --- FIX: Platform-specific settings are now accessed via the platform property ---
    // This resolves the 'setPlatformDetails' and 'AndroidWebViewControllerDetails' errors.
    if (webController.platform is AndroidWebViewController) {
      final androidController = webController.platform as AndroidWebViewController;
      
      // 1. Enable Zoom (Example of Android-specific setting)
      androidController.enableZoom(true);

      // 2. Add the crucial permission request handler for the Camera/Mic
      androidController.setOnPermissionRequest((request) {
        // Log the request to see what resources are being asked for (e.g., 'VIDEO_CAPTURE')
        debugPrint('Webview Permission Request for: ${request.resources}');

        // Grant permission for all requested resources automatically.
        // In a production app, you might want to check the origin 
        // (request.origin) and perform a native runtime permission check first.
        request.grant();
      });
    }
    // -------------------------------------------------------------------------

    controller = webController;
  }

  @override
  Widget build(BuildContext context) {
    // 4. Return the WebViewWidget, passing the configured controller.
    return WebViewWidget(controller: controller);
  }
}
