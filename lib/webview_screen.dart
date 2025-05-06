import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  /// [MEMO] 채널명은 유니크하게 바꾸셔도 됩니다.
  static const channel = MethodChannel("com.flutter.webview");
  final webviewUrl = '웹뷰로 구현한 url 넣기';

  late final _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          final Uri uri = Uri.parse(request.url);
          final String finalUrl = request.url;
          if (uri.scheme == "http" || uri.scheme == 'https') {
            return NavigationDecision.navigate;
          }

          // Intent URL일 경우, OS별로 구분하여 실행
          if (defaultTargetPlatform == TargetPlatform.android) {
            /// [MEMO] Android의 경우, Native(kotlin)으로 url을 전달해 INTENT처리 후 리턴받는다.
            final appScheme = await _convertIntentToAppUrl(request.url);
            try {
              if (appScheme != null) {
                await launchUrlString(
                  appScheme,
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (e) {
              // 앱이 설치되어 있지 않는 경우, playStore로 이동
              final appMarketUrl = await _convertIntentToMarketURl(request.url);
              if (appMarketUrl != null) {
                await launchUrlString(
                  appMarketUrl,
                  mode: LaunchMode.externalApplication,
                );
              }
            }
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            launchUrlString(finalUrl);
          }
          return NavigationDecision.prevent;
        },
      ),
    )
    ..loadRequest(
      Uri.parse(webviewUrl),
    )

    /// javascriptChannel 사용시
    ..addJavaScriptChannel(
      '채널명',
      onMessageReceived: (_) {},
    );

  Future<String?> _convertIntentToAppUrl(String text) async {
    if (!kIsWeb) {
      final message = await channel.invokeMethod<String>(
        "getAppUrl",
        {'url': text},
      );
      return message;
    }
    return null;
  }

  Future<String?> _convertIntentToMarketURl(String text) async {
    if (!kIsWeb) {
      final message =
          await channel.invokeMethod<String>("getMarketUrl", {'url': text});
      return message;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
