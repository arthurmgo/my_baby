import 'package:flutter/material.dart';

import 'utils/auth.dart';
import 'pages/root_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'My Baby Arthur',
      theme: new ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: new RootPage(auth: new Auth(),),
    );
  }
}

