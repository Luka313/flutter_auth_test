const String protocol = "http";
const String host = "192.168.5.10";
const int port = 5000;

const String tokenEndpoint = "/connect/token";
const String authorizationEndpoint = "/connect/authorize";
const String logoutEndpoint = "/connect/endsession";
const String userInfoEndpoint = "/connect/userinfo";

const String redirectUri = "hr.bla://callback";

const String clientId = "clientId";
const String sanitatClientId = "sanitatClientId";

const String clientSecret = "clientSecret";
const String sanitatClientSecret = "sanitatClientSecret";

const List<String> scopes = [
  "openid",
  "profile",
  "api1",
  "reports",
  "offline_access"
];
const List<String> sanitatScopes = ["sanitat"];

const String credentialsFileLocation = "credentials.json";
