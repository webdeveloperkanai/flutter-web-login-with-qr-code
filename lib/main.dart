import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_with_qr/config.dart';
import 'package:web_with_qr/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginCheck(),
    );
  }
}

class LoginCheck extends StatefulWidget {
  const LoginCheck({Key? key}) : super(key: key);

  @override
  State<LoginCheck> createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck> {
  var uid, session;
  bool logedin = false;
  getUserData() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    try {
      session = pre.getString("session");
      uid = pre.getString("uid");
      if (session.toString().isNotEmpty && uid.toString().isNotEmpty) {
        http.Response res = await http.post(Uri.parse(APP_SERVER),
            body: {"getSessionData": session, "uid": uid});
        print("SESSION Response " + res.body.toString());
        if (res.body.toString() == "Active") {
          logedin = true;
          setState(() {});
        } else {
          pre.remove("uid");
          pre.remove("session");
          print("Wrong session ");
          print("Last session " + session.toString());
          print("Last uid " + uid.toString());
        }
      }
    } catch (e) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MyHomePage()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserData();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => logedin
                  ? HomePage(
                      uid: uid,
                    )
                  : MyHomePage()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var qr = "";
  var qrcode = "";
  List user = [];
  setQR() {
    DateTime now = DateTime.now();
    var code = now
        .toString()
        .replaceAll(" ", "")
        .replaceAll("-", "")
        .replaceAll(":", "")
        .replaceAll(".", "");
    qr = APP_SERVER + "?session=" + code + "&uid=1";
    qrcode = code;
    setState(() {});
  }

  var oneSec = Duration(seconds: 5);
  getLogin() async {
    Timer.periodic(oneSec, (Timer timer) {
      print("I'm working");
      http
          .post(Uri.parse(APP_SERVER),
              headers: {
                "Accept": "application/json",
                "Access-Control_Allow_Origin": "*"
              },
              encoding: Encoding.getByName('utf8'),
              body: {"getLogin": qr.toString()})
          .then((response) async {
        print("Server response " + response.body.toString());

        if (response.body.toString() != "failed") {
          user = jsonDecode(response.body);
          print("JSON Decode success");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("uid", user[0]['uid']);
          prefs.setString("session", qrcode.toString());
          // setState(() {});
          timer.cancel();
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => HomePage(uid: user[0]['uid'])));
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initSta   if ( == false) {
    getLogin();
    setQR();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
          ),
          Text(
            "WEB LOGIN",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Center(
            child: QrImage(
              data: qr.toString(),
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Scan code to auto login",
            style: TextStyle(fontSize: 21),
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                setQR();
                setState(() {});
                print(now
                    .toString()
                    .replaceAll(" ", "")
                    .replaceAll("-", "")
                    .replaceAll(":", "")
                    .replaceAll(".", ""));
              },
              child: Text("Refresh")),
        ],
      ),
    );
  }
}
