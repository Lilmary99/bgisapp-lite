import 'dart:ui';
import 'package:bgisapp/google-signin.dart';
import 'package:bgisapp/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
import 'package:bgisapp/read-alerts.dart';
import 'package:bgisapp/saved-display.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bgisapp/about.dart';
import 'package:bgisapp/profile.dart';
import 'package:bgisapp/sign-in.dart';

class UserSettings extends StatefulWidget {
  final String title = 'BGIS Alerts';
  String email;
  String name;

  UserSettings(this.email, this.name);

  //pass email in like this:
  //SecondPage(email);

  @override
  UserSettingsState createState() => UserSettingsState(email, name);
}

class UserSettingsState extends State<UserSettings> {
  final String email;
  final String name;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  UserSettingsState(this.email, this.name);

  //Should be pre-loaded from firestore database
  bool requestNotifs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red[900],
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body:new Container(
          child: new SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(children: <Widget>[
              //REQUEST NOTIFICATIONS BAR
              Flexible(child: Text("REQUEST NOTIFICATIONS? ")),
              showNotifCheckbox()
            ]),

              Row(children: <Widget>[
              Text("PLEASE SELECT PREFERRED FILTERS: "),
              SizedBox(height: 10),
                ]),

            // SHOW FILTERS
            Flexible(child: showFilters()),
          ],
        ),),),
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
                // Update the state of the app
                // ...
                // Then close the drawer
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

  //generate list of filters FROM database
  HashMap loadedFilters = new HashMap<String, String>();

  //list of filter booleans
  List<bool> filters = List.filled(5, true);
  List<bool> f = new List();
  var cats = new List();
  List<Widget> filterBoxes = List<Widget>();
  Widget showFilters() {
    //results();
    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("alert-categories").snapshots(),
        builder: (context, snap) {
          //just add this line
          if (snap.data == null) return CircularProgressIndicator();

          filterBoxes.clear();
          cats.clear();
          return new StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("auth-users").snapshots(),
              builder: (context, val) {
                if (val.data == null) return CircularProgressIndicator();

                filterBoxes.clear();
                cats.clear();
                f.clear();
                int emailsIndex = 0;
                for (int x = 0; x < val.data.documents.length; x++) {
                  if (val.data.documents[x].documentID
                      .toString()
                      .contains(email)) {
                    emailsIndex = x;
                  }
                }

                var c = new List();
                //gets filters

                for (int i = 0; i < snap.data.documents.length; i++) {
                  cats.add(snap.data.documents[i].documentID.toString());
                  //print(qs.documents[i].documentID.toString());
                }
                //cats = []..addAll(c);

                //list of filter booleans
                //List<bool> f = new List();
                IconData iconData;
                String s = "";
                Color colorsData;

                for (int i = 0; i < cats.length; i++) {
                  if (val
                      .data
                      .documents[emailsIndex]
                      .data[cats[i]
                      .toString()
                      .replaceAll("{", "")
                      .replaceAll("}", "")
                      .replaceAll("SchoolInfo", "School Info")]
                      .toString()
                      .contains("true")) {
                    f.add(true);
                  } else {
                    f.add(false);
                  }

                  if (cats[i].toString().contains("Weather")) {
                    iconData = Icons.beach_access;
                    colorsData = Colors.blue;
                    s = "Weather";
                  }
                  if (cats[i].toString().contains("Closure")) {
                    iconData = Icons.cancel;
                    colorsData = Colors.redAccent;
                    s = "Closure";
                  }
                  if (cats[i].toString().contains("Traffic")) {
                    iconData = Icons.directions_car;
                    colorsData = Colors.green;
                    s = "Traffic";
                  }
                  if (cats[i].toString().contains("School")) {
                    iconData = Icons.school;
                    colorsData = Colors.black;
                    s = cats[i].toString().replaceAll("SchoolInfo", "School");
                  }
                  if (cats[i].toString().contains("Events")) {
                    iconData = Icons.event;
                    colorsData = Colors.deepPurple;
                    s = "Events";
                  }
                  //print(cats[i].toString());

                  filterBoxes.add(Container(

                      child: CheckboxListTile(
                          title: Text(s),
                          secondary: Icon(
                            iconData,
                            color: colorsData,
                            size: 30,
                          ),
                          value: f[i],
                          onChanged: (bool value) {
                            setState(() {
                              f[i] = !f[i];

                              if (f[i] == false){
                                _fcm.unsubscribeFromTopic(cats[i].toString().replaceAll("School Info", "School"));
                              }
                              else{
                                _fcm.subscribeToTopic(cats[i].toString().replaceAll("School Info", "School"));
                              }

                              updateFilter(email, cats[i].toString(), f[i]);
                            });
                          }),
                      decoration: new BoxDecoration(
                          border: new Border(bottom: new BorderSide()))));
                }

                return new Column(children: filterBoxes);
                //INSERT END OF STREAM HERE
              });
        });
  }

  void updateFilter(String email, String filter, bool enable) async {
    await Firestore.instance
        .collection("auth-users")
        .document(email)
        .updateData({
      filter: enable.toString()
    });
  }

  void updateRequestNotifs(String email, bool enable) async {
    await Firestore.instance
        .collection("auth-users")
        .document(email)
        .updateData({
      'requestNotifs': enable.toString()
    });
  }

  Widget showNotifCheckbox(){
    return new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("auth-users").snapshots(),
        builder: (context, val) {
          if (val.data == null) return CircularProgressIndicator();

          int emailsIndex = 0;
          for (int x = 0; x < val.data.documents.length; x++) {
            if (val.data.documents[x].documentID
                .toString()
                .contains(email)) {
              emailsIndex = x;
            }
          }

          if(val.data.documents[emailsIndex].data["requestNotifs"].toString().contains("true")) {
            requestNotifs = true;
            for (int y = 0; y < f.length; y++) {
              if (f[y] == true) {
                _fcm.subscribeToTopic(cats[y].replaceAll("School Info", "School"));
              }
            }
          }
          else{
            requestNotifs = false;
            for (int y = 0; y < f.length; y++) {
                _fcm.unsubscribeFromTopic(cats[y].replaceAll("School Info", "School"));
            }
          }

          return new Checkbox(
            value: requestNotifs,
            //onChanged should modify Firebase database
            onChanged: (bool val) {
              setState(() {
                requestNotifs = !requestNotifs;
                updateRequestNotifs(email, requestNotifs);
                if(requestNotifs == true){
                  for (int y = 0; y < f.length; y++) {
                    if (f[y] == true) {
                      _fcm.subscribeToTopic(cats[y].replaceAll("School Info", "School"));
                    }
                  }
                }
                else{
                  for (int y = 0; y < f.length; y++) {
                    _fcm.unsubscribeFromTopic(cats[y].replaceAll("School Info", "School"));
                  }
                }
              });
            },
          );
        });

  }

}
