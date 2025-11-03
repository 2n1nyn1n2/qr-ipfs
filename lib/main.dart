// 1. Flutter/Package Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
// Package to handle runtime permissions (must be added to pubspec.yaml)
import 'package:permission_handler/permission_handler.dart';
// We still need the Android package to access platform-specific configurations
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Note: webview_flutter_platform_interface is no longer directly needed, so we
// remove the import to resolve the 'depend_on_referenced_packages' warning.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QrIpfsApp());
}

// Data structure to hold both the permission status and the HTML content
class WebViewData {
  final String htmlContent;
  final bool isPermissionGranted;

  WebViewData({required this.htmlContent, required this.isPermissionGranted});
}

class QrIpfsApp extends StatelessWidget {
  const QrIpfsApp({super.key});

  // New combined function to request permission and load HTML
  Future<WebViewData> _requestPermissionsAndLoadHtml() async {
    // 1. Request Camera Permission
    final status = await Permission.camera.request();
    final isGranted = status.isGranted;

    // 2. Load HTML Content (we load it regardless, but use the permission status)
    String htmlContent;
    try {
      // Ensure 'docs/index.html' is correctly listed in your pubspec.yaml assets section.
      htmlContent = await rootBundle.loadString('docs/index.html');
    } catch (e) {
      debugPrint('Error loading HTML: $e');
      htmlContent =
          '<html><body><h1>Error loading local content.</h1></body></html>';
    }

    return WebViewData(
      htmlContent: htmlContent,
      isPermissionGranted: isGranted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR-IPFS',
      home: Scaffold(
        appBar: AppBar(title: const Text('QR-IPFS SPA')),
        body: FutureBuilder<WebViewData>(
          future: _requestPermissionsAndLoadHtml(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(
                child: Text("Failed to initialize app data."),
              );
            }

            if (!data.isPermissionGranted) {
              // Show a message if the user denied the permission
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Camera permission is required to scan QR codes. Please enable it in app settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            // If permission is granted and HTML is loaded, show the WebView
            return QrIpfsWebView(htmlContent: data.htmlContent);
          },
        ),
      ),
    );
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
        // Use 'http://localhost' for a trustworthy origin that enables camera access
        baseUrl: 'http://localhost',
      );

    // --- PLATFORM-SPECIFIC PERMISSION HANDLING (Android Only) ---
    if (webController.platform is AndroidWebViewController) {
      final androidController =
          webController.platform as AndroidWebViewController;

      // 1. Enable Zoom (Example of Android-specific setting)
      androidController.enableZoom(true);

      // 2. Add the crucial permission request handler for the Camera/Mic
      // FIX: Replaced setOnPermissionRequest with setPermissionRequestHandler
      androidController.setPermissionRequestHandler(
        (WebViewPermissionRequest request) {
          // Log the request
          debugPrint('Webview Permission Request for: ${request.resources}');

          // This grants the permission from the WebView perspective.
          // It relies on the app having already obtained the OS-level permission
          // using permission_handler (handled in QrIpfsApp).
          request.grant();
        },
      );
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
