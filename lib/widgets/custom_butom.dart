import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Object heroTag;
  final String icon;
  final String label;
  final VoidCallback onTap;

  const CustomButton({
    Key key, this.icon, this.label, this.onTap, this.heroTag
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.topCenter,
      width: 70.0,
      child: new Column(
        children: <Widget>[
          new FloatingActionButton(
            heroTag: heroTag,
            backgroundColor: Colors.blueAccent[100],
            mini: true,
            child: new Image.asset(icon, width: 32.0, height: 32.0,),
            onPressed: onTap,
            elevation: 0.0,
          ),
          new Padding(padding: new EdgeInsets.only(top: 5.0)),
          new Container(
            alignment: Alignment.center,
            width: 35.0,
            child: new Text(label, style: new TextStyle(
                fontSize: 10.0
            ),),
          )
        ],
      ),
    );
  }
}