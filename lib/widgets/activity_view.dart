import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/activity.dart';
import '../utils/data_base.dart';
import 'activity_picker.dart';
import 'type_picker.dart';

class ActivityView extends StatefulWidget {
  final String babyId;
  final DateTime birthDate;
  final DataBase db;

  ActivityView(
      {Key key,
      @required this.babyId,
      @required this.birthDate,
      @required this.db})
      : super(key: key);

  @override
  _ActivityViewState createState() => _ActivityViewState(babyId, birthDate, db);
}

class _ActivityViewState extends State<ActivityView> {
  DateTime _birthDate;
  int _initialPage;
  String _babyId;
  String _type;
  DataBase db;

  DateTime _now;

  _ActivityViewState(this._babyId, this._birthDate, this.db);

  _deleteActivity(String activityId) {
    db.deleteActivity(_babyId, activityId).whenComplete(() {
      print("Sucess!");
    });
  }

  void onSetType() async {
    String type = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new TypePickerWidget(type: _type);
        });

    setState(() {
      _type = type;
    });
  }

  List<Widget> builderActivity(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.documents.map((DocumentSnapshot document) {
        Activity activity;
        switch (document['type']) {
          case ActivityType.BREAST_FEEDING:
            activity = new BreastFeeding.decode(document);
            break;
          case ActivityType.DIAPER:
            activity = new Diaper.decode(document);
            break;
          case ActivityType.MEDICINE:
            activity = new Medicine.decode(document);
            break;
          case ActivityType.SLEEPING:
            activity = new Sleeping.decode(document);
            break;
          case ActivityType.BOTTLE:
            activity = new Bottle.decode(document);
            break;
          case ActivityType.FOOD:
            activity = new Food.decode(document);
            break;
        }
        return new ListTile(
          title: new Text(activity.typeText()),
          subtitle: new Text(
              new DateFormat('dd/MM/yyyy - hh:mm').format(activity.timeStart)),
          leading: new CircleAvatar(
              child: Text(
                activity.typeText()[0],
                style: new TextStyle(color: Colors.white),
              ),
              backgroundColor: activity.getTypeColor()),
          onTap: () {
            print(activity.type);
            print(activity);
            new ActivityPicker.edit(context, activity.type, activity)
                .showActivityDialog()
                .then((ap) {
              if (ap != null) {
                db.editActivity(ap, _babyId, document.documentID);
              }
            });
          },
          onLongPress: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: new Text("Deletar"),
                    content:
                        new Text("Deseja deletar a atividade selecionada?"),
                    actions: <Widget>[
                      new FlatButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: new Text("CANCELAR")),
                      new FlatButton(
                          onPressed: () {
                            _deleteActivity(document.documentID);
                            Navigator.of(context).pop();
                          },
                          child: new Text("CONFIRMAR"))
                    ],
                  );
                });
          },
        );
      }).toList();
    }
    return [];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _modifyIndex = 0;
      _now = new DateTime.now();
      _initialPage = new DateTime(_now.year, _now.month, _now.day)
          .difference(_birthDate)
          .inDays;
    });
  }

  
  int _modifyIndex;


  @override
  Widget build(BuildContext context) {
    return new PageView.builder(

        controller: new PageController(
          initialPage: _initialPage,
        ),
        reverse: false,
        itemBuilder: (BuildContext context, int index) {
          

          DateTime displayDate = new DateTime(_birthDate.year, _birthDate.month, _birthDate.day)
              .add(new Duration(days: index - _modifyIndex));


          return new StreamBuilder<QuerySnapshot>(
            stream: db.allActivities(_babyId, displayDate, _type),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return new Center(
                  child: new CircularProgressIndicator(),
                );
              } else {
                return new Column(
                  children: <Widget>[
                    new OptionsMenu(
                      displayDate: displayDate,
                      onSetType: onSetType,
                      onTapDate: () async {
                        DateTime dateTimePicked = await showDatePicker(
                            context: context,
                            initialDate:
                                new DateTime(_now.year, _now.month, _now.day),
                            firstDate: _birthDate,
                            lastDate: new DateTime.now());

                        if (dateTimePicked != null) {
                          setState(() {
                            _modifyIndex = new DateTime(displayDate.year, displayDate.month, displayDate.day)
                                .difference(dateTimePicked)
                                .inDays;
                            print(_modifyIndex);
                          });
                        }
                      },
                    ),
                    new Expanded(
                      child: new ListView(
                        padding: EdgeInsets.zero,
                        children: builderActivity(snapshot),
                      ),
                    ),
                  ],
                );
              }
            },
          );
        });
  }
}

class OptionsMenu extends StatefulWidget {
  const OptionsMenu(
      {Key key, @required this.displayDate, this.onTapDate, this.onSetType})
      : super(key: key);

  final DateTime displayDate;
  final VoidCallback onTapDate;
  final VoidCallback onSetType;

  @override
  OptionsMenuState createState() {
    return new OptionsMenuState(
        this.displayDate, this.onTapDate, this.onSetType);
  }
}

class OptionsMenuState extends State<OptionsMenu> {
  String _type;
  DateTime displayDate;
  VoidCallback onTapDate;
  VoidCallback onSetType;

  OptionsMenuState(this.displayDate, this.onTapDate, this.onSetType);

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 50.0,
        padding: new EdgeInsets.symmetric(horizontal: 16.0),
        color: const Color(0xFFEEEEEE),
        alignment: Alignment.centerLeft,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new InkWell(
                child: new Row(
                  children: <Widget>[
                    new Text(
                      displayDate.day.toString(),
                      style: new TextStyle(
                          fontSize: 34.0, fontWeight: FontWeight.bold),
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(left: 8.0),
                    ),
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(new DateFormat("E, MMM").format(displayDate)),
                        new Text("¯\\_(ツ)_/¯")
                      ],
                    )
                  ],
                ),
                onTap: onTapDate),
            new IconButton(
                icon: new Icon(Icons.filter_list), onPressed: onSetType)
          ],
        ));
  }
}
