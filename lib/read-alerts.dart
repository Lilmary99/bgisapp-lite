import 'dart:ui';
import 'package:bgisapp/google-signin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
import 'package:share/share.dart';

class ReadAlerts extends StatefulWidget {
  final String title = 'BGIS Alerts';
  final String topic;
  final String message;
  final String date;

  ReadAlerts(this.topic, this.message, this.date);

  @override
  ReadAlertsState createState() => new ReadAlertsState(topic, message, date);
}

class ReadAlertsState extends State<ReadAlerts> {
  final String topic;
  final String message;
  final String date;

  ReadAlertsState(this.topic, this.message, this.date);

  //sets up display for reading an alert
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('BGIS Alerts', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red[900],
          centerTitle: true,
          iconTheme: new IconThemeData(color: Colors.white),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
    child: new Container(
    child: new SingleChildScrollView(
            child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
              Row(children: <Widget>[
                Text(
                  topic,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w700),
                ),
              ]),
              SizedBox(height: 15),
              Row(children: <Widget>[
                Flexible(
                  child: Text(message, style: TextStyle(fontSize: 18, height: 1.4)),
                ),
              ]),
              SizedBox(height: 15),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Date Edited: " + date,
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () => Share.share(
                          "Shared via Barbados Government Information Service Alerts App: " +
                              message,
                          subject: 'BGIS Alerts'),
                    ),
                  ])
            ])))));
  }
}
