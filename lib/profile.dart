import 'dart:ui';
import 'package:bgisapp/google-signin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:collection';
import 'package:share/share.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:bgisapp/about.dart';
import 'package:bgisapp/google-signin.dart';
import 'package:bgisapp/home.dart';
import 'package:bgisapp/user-settings.dart';
import 'package:bgisapp/saved-display.dart';

class Person extends StatefulWidget {
  final String title = 'BGIS Alerts';
  final String email;
  final String name;

  Person(this.email,this.name);

  @override
  ProfileState createState() => new ProfileState(email,name);
}

class ProfileState extends State<Person> {
  final String email;
  final String name;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  ProfileState(this.email, this.name);
  final Geolocator geolocator = Geolocator();

  Position _currentPosition;
  String _currentAddress = "Unknown location";

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Profile', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red[900],
          centerTitle: true,
          iconTheme: new IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<bool>(
    future: Geolocator().isLocationServiceEnabled(),
            initialData: false,
    builder: (context, AsyncSnapshot<bool> snapshot) {
    if (!snapshot.hasData) {
    // while data is loading:
    return Center(child: CircularProgressIndicator(),);
    }

    else {
      _getCurrentLocation();

      String url = "";

      if(getGS()){
        url = getImage();
        if (url == "null"){
          url = "https://i.ibb.co/sCJQyJv/anon.png";
        }
      }else{
        url = "https://i.ibb.co/sCJQyJv/anon.png";
      }

      return new Padding(
          padding: const EdgeInsets.all(20.0),
          child: new Container(
              child: new SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: 150.0,
                            height: 150.0,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(url)
                                )
                            )),]),
                          SizedBox(height: 15),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            Icon(Icons.location_on,
                              color: Colors.orange[600],
                              size: 25,),
                            Flexible(
                              child: Text(_currentAddress, style: TextStyle(fontSize: 18, height: 1.4)),
                            ),
                          ]),
                          SizedBox(height: 20),
                          RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(text: 'Name: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: name),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(text: 'Email: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: email),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                        ]))));}}),
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


  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(locationPermissionLevel: GeolocationPermission.locationWhenInUse, desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });

    }).catchError((e) {
      print(e);
    });
  }
  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        '${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      print(e);
    }
  }


}
