import 'dart:ui';
import 'dart:io';
import 'package:bgisapp/createaccount.dart';
import 'package:bgisapp/google-signin.dart';
import 'package:bgisapp/sign-in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:bgisapp/createaccount.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print("onBackgroundMessage: $message");
  return Future<void>.value();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  bool canAppleSignIn = false;
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
          backgroundColor: Colors.red[900],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 100),
                Image(image: AssetImage("assets/new_logo.png"), height: 100.0),
                SizedBox(height: 20),
                Text(
                  "Barbados Government",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Text(
                  "Information Service",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                SizedBox(height: 30),
                Text(
                  "Keeping you informed is",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.normal),
                ),
                RichText(
                  text: new TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: new TextStyle(
                      fontSize: 25.0,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      new TextSpan(
                          text: 'is the heart of',
                          style: new TextStyle(fontWeight: FontWeight.normal)),
                      new TextSpan(
                          text: ' who we are',
                          style: new TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                //START THE BUTTONS***************************************************************************************************************
                SizedBox(
                  width: 300.0,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    color: Colors.amber[800],
                    onPressed: () {
                      //push create account() page then pop it when user clicks Done and push SavedDisplay
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => CreateAccount()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Create An Account',
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

                //STARTS DIVIDERS***************************************************************************************************************
                Row(children: <Widget>[
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 85.0, right: 20.0),
                        child: Divider(
                          color: Colors.white,
                          height: 36,
                          thickness: 2,
                        )),
                  ),
                  Text(
                    "OR",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 85.0),
                        child: Divider(
                          color: Colors.white,
                          height: 36,
                          thickness: 2,
                        )),
                  ),
                ]),
                SizedBox(
                  width: 300.0,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    color: Colors.amber[800],
                    onPressed: () {
                      //push create account() page then pop it when user clicks Done and push SavedDisplay
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => RegularSignIn()),
                      );
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
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //LOG IN WITH APPLE*****************************************************************************************
                SizedBox(
                  width: 300.0,
                  child: FlatButton(
                    color: Colors.grey[900],
                    onPressed: () async {

                      bool supportsAppleSignIn = await AppleSignIn.isAvailable();

                      if (supportsAppleSignIn){
                      final AuthorizationResult result = await AppleSignIn.performRequests([
                        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
                      ]);

                      switch (result.status) {
                        case AuthorizationStatus.authorized:
                        // here we're going to sign in the user within firebase
                          print("successfull sign in");
                          final AppleIdCredential appleIdCredential = result.credential;

                          OAuthProvider oAuthProvider =
                          new OAuthProvider(providerId: "apple.com");
                          final AuthCredential credential = oAuthProvider.getCredential(
                            idToken:
                            String.fromCharCodes(appleIdCredential.identityToken),
                            accessToken:
                            String.fromCharCodes(appleIdCredential.authorizationCode),
                          );

                          final AuthResult  = await _firebaseAuth.signInWithCredential(credential);

                          _firebaseAuth.currentUser().then((val) async {
                            UserUpdateInfo updateUser = UserUpdateInfo();
                            updateUser.displayName =
                            "${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}";
                            updateUser.photoUrl = "null";
                            await val.updateProfile(updateUser);
                            print("HEY: " + updateUser.displayName);
                            bool userInDB;
                            print(val.email);
                            print(updateUser.displayName);
                            userExists(val.email).then((u) {
                              userInDB = u;
                              //2. SEND EMAIL ADDY TO DATABASE/CHECK IF ADDY ALREADY EXISTS
                              if (userInDB == false) {
                                createRecord(val.email, updateUser.displayName);
                              }
                              _saveDeviceToken(val.email);
                            });
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SavedDisplayAlerts(val.email, updateUser.displayName)),
                            );
                          });




                          break;
                        case AuthorizationStatus.error:
                        // do something
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: ListTile(
                                title: Text("Try Again"),
                                subtitle: Text(
                                    "There was an error authenticating your sign-in. Please try again or continue as a guest."),
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
                          break;

                        case AuthorizationStatus.cancelled:
                          print('User cancelled');
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: ListTile(
                                title: Text("Try Again"),
                                subtitle: Text(
                                    "There was an error authenticating your sign-in. Please try again or continue as a guest."),
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
                          break;
                      }
                      }
                      else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: ListTile(
                              title: Text("Try Again"),
                              subtitle: Text(
                                  "There was an error authenticating your sign-in. Please try again or continue as a guest."),
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

                  },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                              image: AssetImage("assets/apple_logo.png"),
                              height: 22.5),

                          Padding(

                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Connect With Apple',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 300.0,
                  child: FlatButton(
                    color: Colors.white,
                    onPressed: () {
                      //TODO: MUST MAKE A CASE FOR WHEN SIGN-IN IS FAILED... try catch?

                      //1. OPEN GOOGLE SIGN-IN WIDGET
                      signInWithGoogle(context).whenComplete(() {
                        //check if user exists
                        //if no -> create user
                        if (getGS()) {
                          bool userInDB;
                          userExists(getEmail()).then((u) {
                            userInDB = u;
                            //2. SEND EMAIL ADDY TO DATABASE/CHECK IF ADDY ALREADY EXISTS
                            if (userInDB == false) {
                              createRecord(getEmail(), getName());
                            }
                            _saveDeviceToken(getEmail());
                          });
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    SavedDisplayAlerts(getEmail(), getName())),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: ListTile(
                                title: Text("Try Again"),
                                subtitle: Text(
                                    "There was an error authenticating your sign-in. Please try again or continue as a guest."),
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

                      //3. LOAD PRE-SELECTED USER FILTERS
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                              image: AssetImage("assets/google_logo.png"),
                              height: 20.0),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Connect With Google',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.normal),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
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
        if (qs.documents[i].data["Weather"].toString().contains("true")) {
          _fcm.subscribeToTopic('Weather');
        } else {
          _fcm.unsubscribeFromTopic('Weather');
        }
        if (qs.documents[i].data["Closure"].toString().contains("true")) {
          _fcm.subscribeToTopic('Closure');
        } else {
          _fcm.unsubscribeFromTopic('Closure');
        }
        if (qs.documents[i].data["School Info"].toString().contains("true")) {
          _fcm.subscribeToTopic('School');
        } else {
          _fcm.unsubscribeFromTopic('School');
        }
        if (qs.documents[i].data["Traffic"].toString().contains("true")) {
          _fcm.subscribeToTopic('Traffic');
        } else {
          _fcm.unsubscribeFromTopic('Traffic');
        }
        if (qs.documents[i].data["Events"].toString().contains("true")) {
          _fcm.subscribeToTopic('Events');
        } else {
          _fcm.unsubscribeFromTopic('Events');
        }
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

  //if no --> create data
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

  @override
  void initState() {

    if (Platform.isIOS) {
      String _homeScreenText = "Waiting for token...";
      String _messageText = "Waiting for message...";
      canAppleSignIn = true;
      iosSubscription = _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
        // save the token  OR subscribe to a topic here
        print("Settings registered: $settings");
        // _fcm.unsubscribeFromTopic('Closure');
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));

      _fcm.getToken().then((String token) {
        assert(token != null);
        setState(() {
          _homeScreenText = "Push Messaging token: $token";
        });
        print(_homeScreenText);
      });

      _fcm.configure(
          onBackgroundMessage: myBackgroundMessageHandler,

        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(message['notification']['title']),
                subtitle: Text(message['notification']['body']),
              ),
              actions: <Widget>[
                FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReadAlerts(
                                message['notification']['title'],
                                message['alert'],
                                message["date"])),
                      );
                    }),
              ],
            ),
          );
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReadAlerts(
                    message['title'], message['alert'], message["date"])),
          );
          // TODO optional
        },

        onResume: (Map<String, dynamic> message) async {
          //App is in background
          print("onResume: $message");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReadAlerts(
                    message['title'], message['alert'], message["date"])),
          );
          // TODO optional
        },

      );
    } else {
      _fcm.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(message['notification']['title']),
                subtitle: Text(message['notification']['body']),
              ),
              actions: <Widget>[
                FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReadAlerts(
                                message['notification']['title'],
                                message['data']['alert'],
                                message['data']["date"])),
                      );
                    }),
              ],
            ),
          );
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReadAlerts(message['data']['title'],
                    message['data']['alert'], message['data']["date"])),
          );
          // TODO optional
        },
        onResume: (Map<String, dynamic> message) async {
          //App is in background
          print("onResume: $message");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReadAlerts(message['data']['title'],
                    message['data']['alert'], message['data']["date"])),
          );
          // TODO optional
        },
      );
    }
  } //init state(context)

  /// Get the token, save it to the database for current user
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
  } //saveDeviceToken

}



