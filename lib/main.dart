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
      androidController.setPermissionRequestHandler((
        WebViewPermissionRequest request,
      ) {
        // Log the request
        debugPrint('Webview Permission Request for: ${request.resources}');

        // This grants the permission from the WebView perspective.
        // It relies on the app having already obtained the OS-level permission
        // using permission_handler (handled in QrIpfsApp).
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
