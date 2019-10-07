import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cipher2/cipher2.dart';
import 'config.dart' as config;
import 'package:http/http.dart' as http;

TextEditingController codeController = TextEditingController(text: "klik035046001");
TextEditingController userController = TextEditingController();
TextEditingController passController = TextEditingController();
var status = "No status";
var i = 0;


void auth() async{
  String code = codeController.text;
  String user = userController.text;
  String pass = passController.text;
  var url = 'https://novy.vip/api/login.php?code=$code&user=$user&pass=$pass';
  var response = await http.get(url);
  if(response.statusCode == 200){
    var parsedJson = json.decode(response.body);
    print('Response body: ${response.body}');
    status = parsedJson['Status'];
    print(status);
  }else{
    status = "Error:"+status;
    print('Response status: ${response.statusCode}');
  }
}

void save() async{
  //Inputs
  String key = config.key;
  String code = codeController.text;
  String user = userController.text;
  String pass = passController.text;
  //Encryption
  String iv = 'yyyyyyyyyyyyyyyy';
  String nonce = await Cipher2.generateNonce();   // generate a nonce for gcm mode we use later
  if(status == "OK"){
    String encryptedString = await Cipher2.encryptAesCbc128Padding7(pass, key, iv);
    String decryptedString = await Cipher2.decryptAesCbc128Padding7(encryptedString, key, iv);
    print(decryptedString);
  }
}



class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.black,
        radius: 60.0,
        child: Image.asset('assets/home.png'),
      ),
    );

    final code = TextFormField(
      controller: codeController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'InstituteCode',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final user = TextFormField(
      controller: userController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: passController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          auth();
          /*
          Navigator.of(context).pushNamed(HomePage.tag);
          runApp(HomePage(post: fetchPost()));
          */
          new Timer(const Duration(seconds: 3), ()=>_ackAlert(context));
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );


    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            code,
            SizedBox(height: 8.0),
            user,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
          ],
        ),
        
      ),
    );
  }
}

Future<void> _ackAlert(BuildContext context) {;
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Status'),
        content: Text(status),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
              save();
            },
          ),
        ],
      );
    },
  );
}
