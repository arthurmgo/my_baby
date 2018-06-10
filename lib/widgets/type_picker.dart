import 'package:flutter/material.dart';

import '../model/activity.dart';

class TypePickerWidget extends StatefulWidget {
  final String type;

  const TypePickerWidget({Key key, this.type}) : super(key: key);

  @override
  TypePickerWidgetState createState() {
    return new TypePickerWidgetState(type);
  }
}

class TypePickerWidgetState extends State<TypePickerWidget> {
  String type;

  TypePickerWidgetState(this.type);

  @override
  Widget build(BuildContext context) {
    return new SimpleDialog(
      contentPadding: EdgeInsets.zero,
      title: new Text("Escolha as atividades"),
      children: <Widget>[
        new RadioListTile(
          groupValue: type,
          value: ActivityType.BREAST_FEEDING,
          onChanged: (value) => setState(() {
                type = value;
              }),
          title: new Text("Amamentação"),
        ),
        new RadioListTile(
          groupValue: type,
          value: ActivityType.BOTTLE,
          onChanged: (value) => setState(() {
                type = value;
              }),
          title: new Text("Mamadeira"),
        ),
        new RadioListTile(
          groupValue: type,
          value: ActivityType.DIAPER,
          onChanged: (value) => setState(() {
                type = value;
              }),
          title: new Text("Fralda"),
        ),
        new RadioListTile(
          groupValue: type,
          value: ActivityType.SLEEPING,
          onChanged: (value) => setState(() {
                type = value;
              }),
          title: new Text("Soneca"),
        ),
        new RadioListTile(
          groupValue: type,
          value: ActivityType.FOOD,
          onChanged: (value) => setState(() {
                type = value;
              }),
          title: new Text("Comida"),
        ),
        new RadioListTile(
          groupValue: type,
          value: ActivityType.MEDICINE,
          onChanged: (value) => setState(() {
                type = value;
              }),
          title: new Text("Medicina"),
        ),
        new RadioListTile(
          groupValue: type,
          value: null,
          onChanged: (value) => setState(() {
                type = value;
              }),
          title: new Text("Todos"),
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new FlatButton(
                onPressed: () {
                  print(type);
                  Navigator.of(context).pop(type);
                },
                child: new Text("OK"))
          ],
        )
      ],
    );
  }
}
