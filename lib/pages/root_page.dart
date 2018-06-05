import 'package:flutter/material.dart';

import '../utils/auth.dart';

import 'login_page.dart';
import 'home_page.dart';

class RootPage extends StatefulWidget {

  final BaseAuth auth;

  RootPage({this.auth});

  @override
  _RootPageState createState() => new _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {

  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn(){
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  @override
  Widget build(BuildContext context) {

    switch(authStatus){
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        return new HomePage(
          auth: widget.auth,
          onSignedOut: _signedOut,
        );
      default:
        return new Container();
    }
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }
}
