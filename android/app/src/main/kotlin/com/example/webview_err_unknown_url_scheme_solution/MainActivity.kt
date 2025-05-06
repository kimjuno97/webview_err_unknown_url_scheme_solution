package com.example.webview_err_unknown_url_scheme_solution

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity(){
    private val webviewChannel = "com.flutter.webview"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {  
        GeneratedPluginRegistrant.registerWith(flutterEngine);  

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, webviewChannel).setMethodCallHandler {
            call, result ->
            when {
                call.method.equals("getAppUrl") -> {
                    try {
                        val url: String = call.argument("url")!!
                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                        result.success(intent.dataString)
                    } catch (e: URISyntaxException) {
                        result.notImplemented()
                    } catch (e: ActivityNotFoundException) {
                        result.notImplemented()
                    }
                }
                call.method.equals("getMarketUrl") -> {
                    try {
                        val url: String = call.argument("url")!!
                        val packageName = Intent.parseUri(url, Intent.URI_INTENT_SCHEME).getPackage()
                        val marketUrl = Intent(
                            Intent.ACTION_VIEW,
                            Uri.parse("market://details?id=$packageName")
                        )
                        result.success(marketUrl.dataString)
                    } catch (e: URISyntaxException) {
                        result.notImplemented()
                    } catch (e: ActivityNotFoundException) {
                        result.notImplemented()
                    }
                }
            }
        }
    }
}
