import 'dart:async';
import 'dart:io';

import 'package:auth_test/constants.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class BrowserLauncher extends InAppBrowser {
  StreamController<Uri> browserResultController;

  Future<Uri> openForResult(
      {String url = "about:blank",
      Map<String, String> headers = const {},
      Map<String, dynamic> options = const {}}) async {
    browserResultController = StreamController();

    var op = Map<String, dynamic>.from(options);
    op["useShouldOverrideUrlLoading"] = true;

    await super.open(url: url, headers: headers, options: op);
    return resultReceiver.first;
  }

  Stream<Uri> get resultReceiver => browserResultController.stream;

  @override
  void shouldOverrideUrlLoading(String url) async {
    print('Overload!');
    print(url);
    if (url.startsWith(redirectUri)) {
      browserResultController.add(Uri.parse(url));
    } else
      this.webViewController.loadUrl(url);
  }
}
