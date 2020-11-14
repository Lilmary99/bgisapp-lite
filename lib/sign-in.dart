import 'dart:ui';
import 'dart:io';
import 'package:bgisapp/google-signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'anon-display.dart';
import 'saved-display.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push-notif-service.dart';
import 'package:bgisapp/read-alerts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:bgisapp/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user-settings.dart';

class RegularSignIn extends StatefulWidget {
  @override
  RegSignInState createState() => RegSignInState();
}
bool signedIn = false;
String name = "";
String FbEmail = "";

String getRegName(){
  return name;
}

String getFbEmail(){
  return FbEmail;
}
bool getSuccess(){
  return signedIn;
}

class RegSignInState extends State<RegularSignIn> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwdController = new TextEditingController();
  TextEditingController resetPassController = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 100),
            Image(image: AssetImage("assets/new_logo.png"), height: 100.0),
            SizedBox(height: 20),
            Text("Barbados Government", style: TextStyle(color: Colors.white, fontSize: 15),),
            Text("Information Service", style: TextStyle(color: Colors.white, fontSize: 15),),
            SizedBox(height: 30),

            Flexible(
              child: Container(
                width: 300.0,
                child:
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: Colors.white,
                        size: 30,
                      ),
                      border: UnderlineInputBorder(),
                      enabledBorder: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white)),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white)),
                ),),),
            SizedBox(height: 10.0),

            Flexible(
                child:Container(
                  width: 300.0,
                  child:
                  TextField(
                    controller: passwdController,
                    obscureText: true,
                    style: TextStyle(decorationColor: Colors.white),
                    decoration: InputDecoration(
                        icon: Icon(Icons.lock,color: Colors.white, size: 30,),
                        border: UnderlineInputBorder(),
                        enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white)),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white)),
                  ),)),

            SizedBox(height: 50,),
            Flexible(
                child: Container(
                  width: 200.0,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    color: Colors.amber[800],
                    onPressed: () {
                      //push create account() page then pop it when user clicks Done and push SavedDisplay
                      //Navigator.pop(context);

                      setState(() {
                        signIn(emailController.text, passwdController.text).whenComplete(() {
                          if(getSuccess()){
                            //TODO: 1. FORGOT PASSWORD? 2. USER EXISTS() METHOD FROM HOME.DART 3. ADJUST PROFILE PAGE 4. SIGN-OUT FOR APPROPRIATE CASES 5. APPLE BUTTON SHOWN ONLY FOR IOS

                            userExists(emailController.text);
                            _saveDeviceToken(emailController.text);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SavedDisplayAlerts(emailController.text, getRegName())),
                            );
                          }
                          else{
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: ListTile(
                                  title: Text("Try Again"),
                                  subtitle: Text("There was an error signing into your account. Please try again."),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                      child: Text('Ok'),
                                      onPressed: () {

                                        Navigator.of(context).pop();
                                      }),
                                ],
                              ),
                            );
                          }
                        }

                        );
                      });

                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Sign In',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),)),
            SizedBox(height: 50,),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              InkWell(
                child: Text("Forgot password?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
                onTap: () {  showDialog(
                  context: context,
                  builder: (context)
                {
                  return Flexible(
                      child: Container(
                      child: AlertDialog(
                      title: Text("Reset Password"),
                      content: TextField(
                        controller: resetPassController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: new UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black)),
                          hintText: "Email",
                         // helperText: "Enter email of account where you would like password reset link to be sent.",
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                            child: Text("Send Password Reset Link"),
                            onPressed: () {
                              resetPassword(resetPassController.text);
                              Navigator.pop(context);
                            })
                      ]))
                  );
                });
            },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  _saveDeviceToken(String email) async {
    // Must be called after email is authenticated

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = Firestore.instance
          .collection('auth-users')
          .document(email)
          .collection('tokens')
          .document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }//saveDeviceToken

  Future <FirebaseUser> signIn(String email, String password) async {
    try {
      FirebaseUser user = (await auth.signInWithEmailAndPassword(email: email, password: password)).user;
      assert(user != null);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);
      name = user.displayName;
      FbEmail = user.email;
      signedIn = true;
      return user;
    } catch (e) {
      signedIn = false;
      print(e);
      return null;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  //check if user exists
  //if yes --> load their data
  Future<bool> userExists(String email) async {
    QuerySnapshot qs =
    await Firestore.instance.collection("auth-users").getDocuments();
    for (int i = 0; i < qs.documents.length; i++) {
      if (qs.documents[i].documentID.toString().contains(email)) {
        //TODO: add condition where requestNotifs = true
        //subscribe to the user's topics as well
        if (qs.documents[i].data["Weather"].toString().contains("true")){
          _fcm.subscribeToTopic('Weather');
        }
        else{
          _fcm.unsubscribeFromTopic('Weather');
        }
        if (qs.documents[i].data["Closure"].toString().contains("true")){
          _fcm.subscribeToTopic('Closure');
        }
        else{
          _fcm.unsubscribeFromTopic('Closure');
        }
        if (qs.documents[i].data["School Info"].toString().contains("true")){
          _fcm.subscribeToTopic('School');
        }
        else{
          _fcm.unsubscribeFromTopic('School');
        }
        if (qs.documents[i].data["Traffic"].toString().contains("true")){
          _fcm.subscribeToTopic('Traffic');
        }
        else{
          _fcm.unsubscribeFromTopic('Traffic');
        }
        if (qs.documents[i].data["Events"].toString().contains("true")){
          _fcm.subscribeToTopic('Events');
        }
        else{
          _fcm.unsubscribeFromTopic('Events');
        }
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

}
