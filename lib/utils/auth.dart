import 'dart:io';

import 'package:auth_test/constants.dart';
import 'package:auth_test/constants.dart' as prefix0;
import 'package:auth_test/utils/browser_launcher.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:path_provider/path_provider.dart';
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

    Uri loginCallback = await openBrowserForResult(authorizeRequest);

    return await grant
        .handleAuthorizationResponse(loginCallback.queryParameters);
  }

  static Future<oauth2.Client> getSanitatClient() async {
    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (await checkStoredCredentials()) {
      return loadCredentials();
    }

    Uri tEndpoint = createAppUrl(path: tokenEndpoint);
    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    var client = oauth2.clientCredentialsGrant(
        tEndpoint, sanitatClientId, sanitatClientSecret,
        basicAuth: true, scopes: sanitatScopes);

    return client;
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
    final credentialsFile = await getCredentialsFile();
    return credentialsFile.exists();
  }

  static Future<oauth2.Client> loadCredentials() async {
    final credentialsFile = await getCredentialsFile();
    oauth2.Credentials credentials =
        oauth2.Credentials.fromJson(await credentialsFile.readAsString());
    return new oauth2.Client(credentials,
        identifier: clientId, secret: clientSecret);
  }

  static Future<void> saveCredentials(oauth2.Client client) async {
    final credentialsFile = await getCredentialsFile();
    await credentialsFile.writeAsString(client.credentials.toJson());
  }

  static Future<File> getCredentialsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return new File('${directory.path}/$credentialsFileLocation');
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
    if (Platform.isAndroid) {
      return openBrowserAndroid(uri);
    } else if (Platform.isIOS) {
      return openBrowserIOS(uri);
    } else
      throw 'Unsupported platform';
  }

  static Future<Uri> openBrowserAndroid(Uri authorizeRequest) async {
    var browser = BrowserLauncher();
    var result = await browser.openForResult(url: authorizeRequest.toString());
    await browser.close();
    return result;
  }

  static Future<Uri> openBrowserIOS(Uri authorizeRequest) async {
    return await launchInSafariVCForResult(uri: authorizeRequest);
  }

  static Future launchInSafariVC(Uri uri) async {
    await launch(uri.toString(), forceSafariVC: true);
  }

  static Future<Uri> launchInSafariVCForResult(
      {Uri uri, bool closeBrowserOnResult = true}) async {
    await launchInSafariVC(uri);
    var response = await getUriLinksStream().first;
    if (closeBrowserOnResult) {
      await closeWebView();
    }
    return response;
  }
}
