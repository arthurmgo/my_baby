import 'package:flutter/material.dart';

import 'pages/root_page.dart';
import 'utils/auth.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'My Baby Arthur',
      theme: new ThemeData(
        primaryColor: const Color(0xffb3e5fc),
        primaryColorLight: const Color(0xffe6ffff),
        primaryColorDark: const Color(0xff82b3c9),
        accentColor: const Color(0xfff8bbd0),
      ),
      home: new RootPage(
        auth: new Auth(),
      ),
    );
  }
}
