import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:auth_test/constants.dart';
import 'package:auth_test/utils/auth.dart';
import 'package:auth_test/utils/extract_token_info.dart';

class MyHomePage extends StatefulWidget {
  static String id = 'home';

  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client client;
  String userInfo;
  List<dynamic> kupci = [];

  void _login() async {
    var c = await AuthHelper.getClient();
    setState(() {
      client = c;
    });
  }

  void _loginSanitat() async {
    var c = await AuthHelper.getSanitatClient();
    setState(() {
      client = c;
    });
  }

  void _logout() async {
    await AuthHelper.logout(client.credentials.idToken);
    setState(() {
      client = null;
      userInfo = null;
      kupci = [];
    });
  }

  void _getUserInfo() async {
    var res = await client.get('http://192.168.5.10:5000$userInfoEndpoint');
    setState(() {
      if (res.statusCode == 200) {
        userInfo = res.body;
      } else {
        userInfo = res.statusCode.toString();
      }
    });
  }

  void _getKupci() async {
    var res = await client.get('http://192.168.5.10:5000/api/Kupci');

    setState(() {
      if (res.statusCode == 200) {
        kupci = jsonDecode(res.body);
      } else {
        kupci = [];
      }
    });
  }

  void _getSanitatKupci() async {
    var res = await client.get('http://192.168.5.10:5000/api/Sanitat/Kupci');

    setState(() {
      if (res.statusCode == 200) {
        kupci = jsonDecode(res.body);
      } else {
        kupci = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print('HELLO2');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text('Login'),
              color: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: _login,
            ),
            FlatButton(
              child: Text('Logout'),
              color: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: _logout,
            ),
            FlatButton(
              child: Text('UserInfo'),
              color: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: _getUserInfo,
            ),
            FlatButton(
              child: Text('Get Kupci'),
              color: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: _getKupci,
            ),
            FlatButton(
              child: Text('Login Sanitat'),
              color: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: _loginSanitat,
            ),
            FlatButton(
              child: Text('Get Sanitat kupci'),
              color: Colors.blueGrey,
              textColor: Colors.white,
              onPressed: _getSanitatKupci,
            ),
            Text(
              'Sub:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ExtractTokenInfo(
              token: client?.credentials?.accessToken,
            ),
            Text(
              'User Info:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('$userInfo'),
            Text(
              'Kupci:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: kupci.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 20.0,
                    child: Center(
                      child: Text('${kupci[index]["naziv1"]}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
