import 'dart:ui';
import 'dart:io';
import 'package:bgisapp/google-signin.dart';
import 'package:bgisapp/welcome.dart';
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
import 'package:apple_sign_in/apple_sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BGIS Alerts',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    Timer(
        Duration(seconds: 5), () {

          //checks if user is already signed into the app via Firebase auth (which includes Apple and Google auth)
          //... sends them to introduction screen if not signed in
          FirebaseAuth.instance.currentUser().then((firebaseUser) {
        if (firebaseUser != null) {
          print('kk');
          print(firebaseUser.email);
          print(firebaseUser.displayName);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) =>
                    SavedDisplayAlerts(
                        firebaseUser.email, firebaseUser.displayName)),
          );
        }
        else {
          //Welcome screen
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) =>
                  WelcomeScreen()));
        }
      });



        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            SizedBox(height: 250.0),
          Image(image: AssetImage("assets/new_logo.png"), height: 100.0),
          SizedBox(height: 250.0),
          Text("A Barbados Government Information Service", style: TextStyle(color: Colors.white, fontSize: 15),),
          ],),

      ),
    );
  }
}
