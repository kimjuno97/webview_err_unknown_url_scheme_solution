import 'package:flutter/material.dart';
import 'package:webview_err_unknown_url_scheme_solution/webview_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WebviewScreen(),
    );
  }
}
