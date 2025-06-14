// ignore_for_file: prefer_const_constructors

import 'package:chatapp/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  void _setUserOnlineStatus(String uid) {
    final statusRef = FirebaseDatabase.instance.ref("status/$uid");
    print("Ajay" + uid);
    statusRef.set({
      "state": "online",
      "last_changed": ServerValue.timestamp,
    });
    print("Ajith function called");

    // Handle offline case when user disconnects
    statusRef.onDisconnect().set({
      "state": "offline",
      "last_changed": ServerValue.timestamp,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final uid = snapshot.data!.uid;
            _setUserOnlineStatus(uid);
            return HomePage();
          } else {
            return LoginOrRegister();
          }
        });
  }
}
