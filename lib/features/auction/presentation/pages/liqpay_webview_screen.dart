import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:lotex/core/theme/lotex_ui_tokens.dart';

class LiqPayWebViewScreen extends StatefulWidget {
  final String title;
  final String checkoutHtml;

  const LiqPayWebViewScreen({
    super.key,
    required this.title,
    required this.checkoutHtml,
  });

  @override
  State<LiqPayWebViewScreen> createState() => _LiqPayWebViewScreenState();
}

class _LiqPayWebViewScreenState extends State<LiqPayWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(
        widget.checkoutHtml,
        baseUrl: 'https://www.liqpay.ua',
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: LotexUiColors.slate950.withAlpha((0.85 * 255).round()),
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
          tooltip: 'Close',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
