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
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  About();
  @override
  AboutState createState() => new AboutState();
}

class AboutState extends State<About> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('About', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red[900],
          centerTitle: true,
          iconTheme: new IconThemeData(color: Colors.white),

        ),
        body: Center(
        child: Padding(
    padding: const EdgeInsets.all(20.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
            Text("The GIS Alerts app is the official Government messaging system used to immediately disseminate critical information to the general public. It is an initiative of the Barbados Government Information Service and continues to demonstrate our commitment to serving the people of Barbados through the use of modern, relevant technologies. \n\nTo learn more about this initiative please visit", style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: Colors.black,
            ),),
            Row(children: <Widget>[
                  InkWell(
                  child: Text("https://gisbarbados.gov.bb",
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Colors.red[900],
                    ),
                  ),
                    onTap: () => launch("https://gisbarbados.gov.bb"),
                  ),
                  ]),

                ])))
    );
  }
}
