import 'dart:ui';
import 'package:bgisapp/about.dart';
import 'package:bgisapp/google-signin.dart';
import 'package:bgisapp/home.dart';
import 'package:bgisapp/user-settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
import 'package:bgisapp/read-alerts.dart';
import 'package:bgisapp/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedDisplayAlerts extends StatefulWidget {
  final String title = 'BGIS Alerts';
  final String email;
  final String name;

  SavedDisplayAlerts(this.email, this.name);

  //pass email in like this:
  //SecondPage(email);

  @override
  DisplayAlertsState createState() => DisplayAlertsState(email, name);
}

class DisplayAlertsState extends State<SavedDisplayAlerts> {
  var topics;
  var messages;
  var dates;
  final String email;
  final String name;
  bool continueFiltering = false;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  DisplayAlertsState(this.email, this.name);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset('assets/new_logo.png', height: 35.0,),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: new Container(
      child: new SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 10.0),
      child: new Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Row(children: <Widget>[Text("Logged in as: " + name, style: TextStyle(fontSize: 20),),],),
                SizedBox(
                  height: 10,
                ),
                //PULL ALERTS FROM DATABASE HERE AND CREATES LISTVIEWS
                showAlerts(context),
              ],
            )
    ),
          ),

      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 25)),
              decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: AssetImage("assets/menu_background.png"),
                      fit: BoxFit.fill)
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                //open page afterward
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(title: 'BGIS Alerts')),
                );
              },
            ),
            ListTile(
              title: Text('Alerts'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SavedDisplayAlerts(email, name)),
                );
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Person(email,name)),
                );
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserSettings(email, name)),
                );
              },
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => About()),
                );
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () {

                //check if it was a Google Auth
                if(getGS()){
                  signOutGoogle();
                  _fcm.unsubscribeFromTopic("School");
                  _fcm.unsubscribeFromTopic("Events");
                  _fcm.unsubscribeFromTopic("Weather");
                  _fcm.unsubscribeFromTopic("Traffic");
                  _fcm.unsubscribeFromTopic("Closure");
                }
                //else if apple sign in worked
                else{
                FirebaseAuth.instance.signOut();
                _fcm.unsubscribeFromTopic("School");
                _fcm.unsubscribeFromTopic("Events");
                _fcm.unsubscribeFromTopic("Weather");
                _fcm.unsubscribeFromTopic("Traffic");
                _fcm.unsubscribeFromTopic("Closure");
                }
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(title: 'BGIS Alerts')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //generate all alerts
  List<Widget> alertBoxes = new List<Widget>();
  Widget showAlerts(BuildContext context) {
    var t = new List();
    var m = new List();
    var d = new List();

    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("alerts").snapshots(),
        builder: (context, snap) {

          if (snap.data == null) return CircularProgressIndicator();

          for (int i = 0; i < snap.data.documents.length; i++) {
            t.add(snap.data.documents[i]["ops"]
                .toString()
                .replaceAll(":", "")
                .replaceAll("true", "")
                .replaceAll(" ", ""));
            m.add(snap.data.documents[i]["message"].toString());
            d.add(DateFormat.yMMMMd('en_US').format(DateTime.parse(
                snap.data.documents[i]["created"].toDate().toString())));
          }

          // setState(() {
          topics = []..addAll(t);
          messages = []..addAll(m);
          dates = []..addAll(d);
          //  });

          //BEGIN FILTERING
          return new StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("auth-users").snapshots(),
              builder: (context,  val) {
                //getData().then((val) {
                if (val.data == null) return CircularProgressIndicator();

                //just add this line fixed repeated alerts bug (because data is constantly being streamed and built)
                alertBoxes.clear();
                t.clear();
                m.clear();
                d.clear();
                for (var i = 0; i < topics.length; i++) {
                  bool enabled = false;
                  IconData icon;
                  String s;
                  Color colors;

                  //set icons and icon colors for list of filters
                  if (topics[i].toString().contains("Weather")) {
                    icon = Icons.beach_access;
                    colors = Colors.blue;
                  }

                  if (topics[i].toString().contains("Closure")) {
                    icon = Icons.cancel;
                    colors = Colors.redAccent;
                  }

                  if (topics[i].toString().contains("Traffic")) {
                    icon = Icons.directions_car;
                    colors = Colors.green;
                  }

                  if (topics[i].toString().contains("School")) {
                    icon = Icons.school;
                    colors = Colors.black;
                  }

                  if (topics[i].toString().contains("Events")) {
                    icon = Icons.event;
                    colors = Colors.deepPurple;
                  }
                  int emailsIndex = 0;

                  for (int x = 0; x < val.data.documents.length; x++) {
                    if (val.data.documents[x].documentID.toString().contains(
                        email)) {
                      emailsIndex = x;
                    }
                  }

                  //loop thru length of topics[i] (in case there are more than categories assigned to an alert)
                  var tmp;
                  if (topics[i].contains(",")) {
                    tmp = topics[i].toString()
                        .replaceAll("{", "")
                        .replaceAll("}", "").replaceAll("SchoolInfo", "School Info").toString().split(",");
                    //compare each of those topics to each field in user's documents : if field is true and it matches topic, return true
                    for (int g = 0; g < tmp.length; g++) {
                      //print("HEY: " + val.data.documents[emailsIndex].data[tmp[g]].toString());
                      //print(g);
                      if (val.data.documents[emailsIndex].data[tmp[g]]
                          .toString()
                          .contains("true")) {
                        if (tmp[g].toString().contains("Weather")) {
                          icon = Icons.beach_access;
                          colors = Colors.blue;
                        }

                        else if (tmp[g].toString().contains("Closure")) {
                          icon = Icons.cancel;
                          colors = Colors.redAccent;
                        }

                        else if (tmp[g].toString().contains("Traffic")) {
                          icon = Icons.directions_car;
                          colors = Colors.green;
                        }

                        else if (tmp[g].toString().contains("School")) {
                          icon = Icons.school;
                          colors = Colors.black;
                        }

                        else if (tmp[g].toString().contains("Events")) {
                          icon = Icons.event;
                          colors = Colors.deepPurple;
                        }
                        enabled = true;
                        break;
                        //print("eh: " + enabled.toString());
                        //return enabled;
                      }
                    }
                  }
                  else {
                    if (val.data.documents[emailsIndex].data[topics[i]
                        .toString()
                        .replaceAll("{", "")
                        .replaceAll("}", "").replaceAll("SchoolInfo", "School Info")].toString().contains("true")) {

                      enabled = true;
                      //break;
                    }
                  }

                  if (enabled == true) {
                    //print(topics[i]);

                    String s;
                    if (topics[i].toString().contains("School")) {
                      s = topics[i].toString().replaceAll(
                          "SchoolInfo", "School");
                    }
                    else {
                      s = topics[i];
                    }
                    var message_adjust;
                    if(messages[i].toString().length >= 100){
                      message_adjust = messages[i].toString().substring(0,99) + "...";
                    }
                    else{
                      message_adjust = messages[i];
                    }

                    alertBoxes.add(new Container(
                        child: new ListTile(
                          leading: Icon(
                            icon,
                            color: colors,
                            size: 30,
                          ),
                          title: Text(s
                              .toString()
                              .replaceAll("{", "")
                              .replaceAll("}", ""), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                          subtitle: Text(
                              message_adjust +
                                  "\n" +
                                  dates[i].toString(), style: TextStyle(height: 1.2)),
                          onTap: () {
                            if (topics[i].contains("School")) {
                              topics[i] = topics[i]
                                  .toString()
                                  .replaceAll("SchoolInfo", "School");
                            }
                            //Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReadAlerts(
                                          topics[i]
                                              .toString()
                                              .replaceAll("{", "")
                                              .replaceAll("}", ""),
                                          messages[i],
                                          dates[i])),
                            );
                          },
                        ),
                      margin: EdgeInsets.only(bottom: 10.0),

                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),));
                  }
                }
                return new Column(children: alertBoxes);
              });

          return new Column(children: alertBoxes);
        });

  }

}
