// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert' show json;
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bgisapp/main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
String email = "";
String name = "";
String photo = "";
String phone = "";
bool signInWorked = false;

String getEmail(){
  return email;
}

String getName(){
  return name;
}

bool getGS(){
  return signInWorked;
}

String getPhone(){
  return phone;
}

String getImage(){
  //print(photo);
  return photo;
}


Future<String> signInWithGoogle(BuildContext context) async {

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if(await googleSignIn.isSignedIn()) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult = await _auth.signInWithCredential(
          credential);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      //print("USER'S EMAIL ADDY: " + user.email);
      email = user.email;
      name = user.displayName;
      photo = user.photoUrl;
      phone = user.phoneNumber;
      signInWorked = true;
      return 'signInWithGoogle succeeded: $user';
    }
    else{
      signInWorked = false;

      print('failed');
      return 'failed';
    }
}

void signOutGoogle() async{
  await googleSignIn.signOut();
  signInWorked = false;
  print("User Sign Out");
}