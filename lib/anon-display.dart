import 'dart:ui';
import 'package:bgisapp/google-signin.dart';
import 'package:bgisapp/home.dart';
import 'package:bgisapp/user-settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
import 'package:bgisapp/read-alerts.dart';
import 'package:bgisapp/about.dart';

class AnonDisplayAlerts extends StatefulWidget {
  final String title = 'BGIS Alerts';

  AnonDisplayAlerts({Key key, title}) : super(key: key);

  @override
  DisplayAlertsState createState() => new DisplayAlertsState();
}

class DisplayAlertsState extends State<AnonDisplayAlerts> {
  //list of filter booleans
  List<bool> filters = List.filled(5, false);
  var topics;
  var messages;
  var dates;

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
    padding: const EdgeInsets.all(10.0),
            child: new Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //PULL ALERTS FROM DATABASE HERE AND CREATE TEXT OBJECTS?
                //showAlerts()

                showAlerts(context),
              ],
            ),
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
                  MaterialPageRoute(builder: (context) => AnonDisplayAlerts()),
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
          //just add this line
          if (snap.data == null) return CircularProgressIndicator();

          alertBoxes.clear();
          t.clear();
          m.clear();
          d.clear();
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

          for (var i = 0; i < topics.length; i++) {
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
              topics[i] =
                  topics[i].toString().replaceAll("SchoolInfo", "School");
            }

            if (topics[i].toString().contains("Events")) {
              icon = Icons.event;
              colors = Colors.deepPurple;
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
                  title: Text(topics[i]
                      .toString()
                      .replaceAll("{", "")
                      .replaceAll("}", ""), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  subtitle: Text(message_adjust +
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

          return new Column(children: alertBoxes);
        });
  }
}
