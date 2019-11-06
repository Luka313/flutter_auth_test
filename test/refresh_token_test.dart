import 'package:flutter_test/flutter_test.dart';
import 'package:mock_web_server/mock_web_server.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

MockWebServer _server;

void main() {
  setUp(() {
    _server = new MockWebServer();
    _server.start();
  });

  tearDown(() {
    _server.shutdown();
  });

  test('Shoud refresh token on new request', () async {
    Map<String, String> headers = new Map();
    headers["Content-Type"] = "application/json";

    _server.enqueue(
        body:
            '{"access_token": "new_access_token","refresh_token": "new_refresh_token","token_type": "bearer","expires": 3600}',
        headers: headers);

    _server.enqueue(body: 'resurs');

    var refreshToken = 'refresh_token';
    var accessToken = 'access_token';

    var expiration = new DateTime.now().subtract(new Duration(hours: 1));
    var credentials = new oauth2.Credentials(accessToken,
        refreshToken: refreshToken,
        tokenEndpoint: Uri.parse(_server.url),
        expiration: expiration);

    var client = new oauth2.Client(credentials,
        identifier: 'identifier', secret: 'secret');

    await client.get(_server.url);

    expect(client.credentials.refreshToken, equals("new_refresh_token"));
    expect(client.credentials.accessToken, equals("new_access_token"));
  });
}
