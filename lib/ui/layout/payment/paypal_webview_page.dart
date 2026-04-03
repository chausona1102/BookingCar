import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:booking_app/services/paypal_service.dart';

class PaypalWebviewPage extends StatefulWidget {
  final String approvalUrl;
  final String orderId;
  final Function(Map<String, dynamic>) onSuccess;
  final VoidCallback onCancel;

  const PaypalWebviewPage({
    super.key,
    required this.approvalUrl,
    required this.orderId,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<PaypalWebviewPage> createState() => _PaypalWebviewPageState();
}

class _PaypalWebviewPageState extends State<PaypalWebviewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _captured = false; // tránh capture 2 lần

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) => _handleNavigation(request),
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;
    // print('WebView URL: $url');

    // Detect khi PayPal redirect về return_url
    if (url.contains('payment/success') || url.contains('token=')) {
      final uri = Uri.parse(url);
      final token = uri.queryParameters['token'];

      // print('Token found: $token');

      if (token != null && !_captured) {
        _captured = true;
        _capturePayment(token);
        return NavigationDecision.prevent;
      }
    }

    // Detect khi user bấm Cancel
    if (url.contains('payment/cancel')) {
      print('❌ Payment cancelled');
      widget.onCancel();
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _capturePayment(String orderId) async {
    // Hiện loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await PaypalService.captureOrder(orderId);

    if (!mounted) return;
    Navigator.pop(context); // đóng loading

    if (result != null && result['status'] == 'COMPLETED') {
      widget.onSuccess(result);
    } else {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán PayPal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
