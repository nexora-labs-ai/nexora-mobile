import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MezonLoginWebView extends StatefulWidget {
  final String authUrl;
  final String redirectUri;

  const MezonLoginWebView({
    super.key,
    required this.authUrl,
    required this.redirectUri,
  });

  @override
  State<MezonLoginWebView> createState() => _MezonLoginWebViewState();
}

class _MezonLoginWebViewState extends State<MezonLoginWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WebViewCookieManager().clearCookies();
    _controller = WebViewController()
      ..clearCache()
      ..clearLocalStorage()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('WebView starting load: $url');
          },
          onPageFinished: (url) {
            debugPrint('WebView finished load: $url');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('WebView navigating to: ${request.url}');
            // Đánh chặn nếu URL bắt đầu bằng redirectUri (dù URL đó có die hay sống)
            if (request.url.startsWith(widget.redirectUri)) {
              final uri = Uri.parse(request.url);
              final code = uri.queryParameters['code'];
              if (code != null && code.isNotEmpty) {
                // Trả code về và đóng WebView
                Navigator.of(context).pop(code);
              } else {
                // Lỗi hoặc user huỷ
                Navigator.of(context).pop(null);
              }
              return NavigationDecision
                  .prevent; // Chặn trình duyệt load trang ảo này
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in with Mezon'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
