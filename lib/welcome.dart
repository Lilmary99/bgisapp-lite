import 'dart:ui';
import 'dart:io';
import 'package:bgisapp/google-signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'anon-display.dart';
import 'saved-display.dart';
import 'package:bgisapp/sign-in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push-notif-service.dart';
import 'package:bgisapp/read-alerts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:bgisapp/home.dart';
import 'package:firebase_auth/firebase_auth.dart';


class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Center(
        child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),

            width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    alignment: Alignment.bottomRight,
    decoration: BoxDecoration(
    image: DecorationImage(
    fit: BoxFit.fill,
    image: new ExactAssetImage("assets/welcome_splash.png"),

        ),
    ),
      child: FlatButton(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(40)),
    color: Colors.amber[800],
    onPressed: () {
    //push create account() page then pop it when user clicks Done and push SavedDisplay
    Navigator.of(context).pushReplacement(
    MaterialPageRoute(
    builder: (context) => MyHomePage()),
    );
    },
    child: Padding(
    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
    Text(
    'Continue',
    textAlign: TextAlign.center,
    style: TextStyle(
    fontSize: 20,
    color: Colors.white,
    fontWeight: FontWeight.normal),
    ),
    ],
    ),
    ),
    ),
        ),
          Container(
              padding: EdgeInsets.fromLTRB(20, 250, 20, 0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut \nlabore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation'
                ,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
              )),

]
    )
        )
    );
  }
}