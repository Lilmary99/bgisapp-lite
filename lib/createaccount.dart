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


class CreateAccount extends StatefulWidget {
  @override
  CreateAccountState createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwdController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  bool signedIn = true;
  bool getSuccess(){
    return signedIn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: Center(
        child: Column(
         // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 100.0),
            Text(
              "Set an email and password",
              style: TextStyle(color: Colors.white, fontSize: 25,fontWeight: FontWeight.normal),
            ),
            Text(
              "to create your account",
              style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 25.0),

            Flexible(
              child: Container(
                width: 300.0,
                child:
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                      border: UnderlineInputBorder(),
                      enabledBorder: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white)),
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.white)),
                ),),),
            SizedBox(height: 10.0),

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
helperText: "Must be at least 6 characters.",
                  helperStyle: TextStyle(color: Colors.white),
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
                    signUp(emailController.text,passwdController.text, nameController.text).whenComplete(() {

                    if(getSuccess()){
                        //TODO: 1. CREATE DOC IN FIRESTORE 2. OPEN SAVED DISPLAY
                        print(emailController.text);

                    setState(() {
                      createRecord(emailController.text, nameController.text);
                      _saveDeviceToken(emailController.text);
                      signIn(emailController.text, passwdController.text);
                    });
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              SavedDisplayAlerts(emailController.text, nameController.text)),
                    );
                  }
                    else{
                    Navigator.of(context).pop();
                    showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                    content: ListTile(
                    title: Text("Try Again"),
                    subtitle: Text("There was an error creating your account. Please try again."),
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
                    });
                  });



                  /**Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateAccount()),
                  );*/
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Sign Up',
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
          ],
        ),
      ),
    );
  }


  Future <FirebaseUser> signUp(email, password, name) async {
    try {
      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = name;

      await auth
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwdController.text,
      ).then((user) async {
        await user.user.updateProfile(updateInfo);
        FirebaseUser updatedUser = await auth.currentUser();
        print('USERNAME IS: ${updatedUser.displayName}');
        signedIn = true;
        return user;
      });

    } catch (e) {
      signedIn = false;
      print(e);
      return null;
    }
  }

  void createRecord(String email, String name) async {
    await Firestore.instance.collection("auth-users").document(email).setData({
      'Closure': 'true',
      'Events': 'true',
      'School Info': 'true',
      'Traffic': 'true',
      'Weather': 'true',
      'displayName': name,
      'isAdmin': 'false',
      'isSuper': 'false',
      'isUser': 'false',
      'requestNotifs': 'true'
    });

    _fcm.subscribeToTopic('Weather');
    _fcm.subscribeToTopic('Events');
    _fcm.subscribeToTopic('Traffic');
    _fcm.subscribeToTopic('Closure');
    _fcm.subscribeToTopic('School');
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
      signedIn = true;
      return user;

    } catch (e) {
    signedIn = false;
    print(e);
    return null;
    }
  }
}
