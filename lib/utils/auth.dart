import 'dart:io';

import 'package:auth_test/constants.dart';
import 'package:auth_test/utils/browser_launcher.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthHelper {
  static Future<oauth2.Client> getClient() async {
    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (await checkStoredCredentials()) {
      return loadCredentials();
    }

    Uri aEndpoint = createAppUrl(path: authorizationEndpoint);
    Uri tEndpoint = createAppUrl(path: tokenEndpoint);
    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    var grant = new oauth2.AuthorizationCodeGrant(
        clientId, aEndpoint, tEndpoint,
        secret: clientSecret);

    Uri redirectUrl = Uri.parse(redirectUri);

    var authorizeRequest =
        grant.getAuthorizationUrl(redirectUrl, scopes: scopes);

    Uri callbackUri = await openBrowserForResult(authorizeRequest);

    return await grant.handleAuthorizationResponse(callbackUri.queryParameters);
  }

  static Future<oauth2.Client> getSanitatClient() async {
    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (await checkStoredCredentials()) {
      return loadCredentials();
    }

    Uri aEndpoint = createAppUrl(path: authorizationEndpoint);
    Uri tEndpoint = createAppUrl(path: tokenEndpoint);
    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    var client = oauth2.clientCredentialsGrant(
        tEndpoint, sanitatClientId, sanitatClientSecret,
        basicAuth: true, scopes: sanitatScopes);

    return client;
  }

  static Future<Uri> listen() async {
    return await getUriLinksStream().first;
  }

  static Future logout(String idToken) async {
    var uri = createAppUrl(path: logoutEndpoint, queryParameters: {
      "id_token_hint": idToken,
      "post_logout_redirect_uri": redirectUri
    });

    await openBrowserForResult(uri);
    // var browser = BrowserLauncher();
    // await browser.openForResult(url: uri.toString());
    // await browser.close();
  }

  static Future<bool> checkStoredCredentials() async {
    File file = new File(credentialsFileLocation);
    return file.exists();
  }

  static Future<oauth2.Client> loadCredentials() async {
    File file = new File(credentialsFileLocation);
    oauth2.Credentials credentials =
        oauth2.Credentials.fromJson(await file.readAsString());
    return new oauth2.Client(credentials,
        identifier: clientId, secret: clientSecret);
  }

  static Future<void> saveCredentials(oauth2.Client client) async {
    File file = new File(credentialsFileLocation);
    await file.writeAsString(client.credentials.toJson());
  }

  static Uri createAppUrl({String path, Map<String, String> queryParameters}) {
    return Uri(
        scheme: protocol,
        host: host,
        port: port,
        path: path,
        queryParameters: queryParameters);
  }

  static Future<Uri> openBrowserForResult(Uri uri) async {
    Uri callbackUri;
    if (Platform.isAndroid) {
      var browser = BrowserLauncher();
      callbackUri = await browser.openForResult(url: uri.toString());
      await browser.close();
    } else if (Platform.isIOS) {
      callbackUri = await launchInSafariVCForResult(uri: uri);
    }

    return callbackUri;
  }

  static Future launchInSafariVC(Uri uri) async {
    await launch(uri.toString(), forceSafariVC: true, forceWebView: true);
  }

  static Future<Uri> launchInSafariVCForResult(
      {Uri uri, bool closeBrowserOnResult = true}) async {
    await launchInSafariVC(uri);
    var response = await listen();
    print('Received:$response');
    if (closeBrowserOnResult) {
      print('Close browser.');
      await closeWebView();
    }
    return response;
  }
}
