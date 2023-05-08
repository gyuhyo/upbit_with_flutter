import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradeViewScreen extends StatelessWidget {
  final String marketCode;
  final String marketKorean;
  const TradeViewScreen({
    required this.marketCode,
    required this.marketKorean,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://kr.tradingview.com/chart/?symbol=UPBIT%3A${marketCode.replaceAll('KRW-', '')}KRW&theme=dark&allow_symbol_change=false'));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: Hero(
          tag: 'test${marketKorean}',
          key: ObjectKey(marketKorean),
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              marketKorean,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
