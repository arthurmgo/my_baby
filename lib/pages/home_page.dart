import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/activity.dart';
import '../model/baby.dart';
import '../utils/auth.dart';
import '../utils/data_base.dart';
import '../widgets/activity_picker.dart';
import '../widgets/custom_butom.dart';
import 'entry_baby_dialog.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  HomePage({this.auth, this.onSignedOut});

  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String _uid;
  String _babyId;
  Baby _currentBaby;
  DateTime _birthDate;
  int _startPage;

  DataBase db = new DataBase();

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    DateTime now = new DateTime.now();
    widget.auth.currentUser().then((value) {
      setState(() {
        _uid = value;
      });
    }).catchError((e) {
      print(e);
    });
    if (_currentBaby != null) {
      setState(() {
        _birthDate = new DateTime(_currentBaby.birthDate.year,
            _currentBaby.birthDate.month, _currentBaby.birthDate.day);
        _startPage = new DateTime(now.year, now.month, now.day)
            .difference(_birthDate)
            .inDays;
      });
    }
    super.initState();
  }

  List<Widget> builder(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return <Widget>[
        new Center(
          child: new CircularProgressIndicator(),
        )
      ];
    }
    if (snapshot.hasData) {
      return snapshot.data.documents.map((DocumentSnapshot document) {
        Baby baby = new Baby.decode(document);
        return new ListTile(
          title: new Text(baby.name),
          subtitle:
              new Text(new DateFormat('dd/MM/yyyy').format(baby.birthDate)),
          trailing: new IconButton(
              icon: new Icon(Icons.edit),
              onPressed: () {
                _editEntry(baby, document.documentID);
              }),
          leading: new CircleAvatar(
            child: Text(
              baby.name[0],
              style: new TextStyle(color: Colors.white),
            ),
            backgroundColor: baby.sex == "female"
                ? Colors.pinkAccent[100]
                : Colors.blueAccent[100],
          ),
          onTap: () {
            setState(() {
              DateTime now = new DateTime.now();
              _babyId = document.documentID;
              _currentBaby = baby;
              _birthDate = new DateTime(_currentBaby.birthDate.year,
                  _currentBaby.birthDate.month, _currentBaby.birthDate.day);
              _startPage = new DateTime(now.year, now.month, now.day)
                  .difference(_birthDate)
                  .inDays;
            });
            Navigator.of(context).pop();
          },
        );
      }).toList();
    }
    return [];
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
            new ActivityPicker.edit(context, activity.type, activity)
                .showActivityDialog()
                .then((ap) {
              if (ap != null) {
                db.editActivity(ap, _babyId, document.documentID);
              }
            });
          },
        );
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("My Baby"),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.delete),
              onPressed: (){
                if(_babyId != null){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return new AlertDialog(
                        title: new Text("Deletar"),
                        content: new Text("Deseja deletar o bebê selecionado?"),
                        actions: <Widget>[
                          new FlatButton(onPressed:()=> Navigator.of(context).pop(), child: new Text("CANCELAR")),
                          new FlatButton(
                              onPressed: (){
                                _deleteBaby();
                                Navigator.of(context).pop();
                              },
                              child: new Text("CONFIRMAR"))
                        ],
                      );
                    }
                  );
                }
              }
          )
        ],
      ),
      drawer: new Drawer(
        child: new StreamBuilder<QuerySnapshot>(
          stream: db.babiesByUser(_uid),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return new ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                      new UserAccountsDrawerHeader(
                        accountName: new Text("User"),
                        accountEmail: new Text("user@userdomain.com"),
                      )
                    ] +
                    builder(snapshot) +
                    [
                      new ListTile(
                          leading: new Icon(Icons.add),
                          title: new Text("Adicionar Bebê"),
                          onTap: _openAddEntryDialog),
                      new Divider(),
                      new ListTile(
                        title: new Text("Sair"),
                        leading: new Icon(Icons.exit_to_app),
                        onTap: _signOut,
                      )
                    ]);
          },
        ),
      ),
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Container(
              color: Colors.grey[100],
              padding: new EdgeInsets.only(top: 10.0),
              height: 100.0,
              child: new ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  new Padding(padding: new EdgeInsets.only(left: 8.0)),
                  new CustomButton(
                    heroTag: 0,
                    icon: "assets/icons/036-breast.png",
                    label: "Amamentação",
                    onTap: () {
                      ActivityPicker ap = new ActivityPicker.add(
                          context, ActivityType.BREAST_FEEDING);
                      ap.showActivityDialog().then((ap) {
                        if (ap != null) {
                          db.addActivity(ap, _babyId);
                        }
                      });
                    },
                  ),
                  new CustomButton(
                      heroTag: 1,
                      icon: "assets/icons/024-feeding-bottle.png",
                      label: "Mamadeira",
                      onTap: () {
                        ActivityPicker ap = new ActivityPicker.add(
                            context, ActivityType.BOTTLE);
                        ap.showActivityDialog().then((ap) {
                          if (ap != null) {
                            db.addActivity(ap, _babyId);
                          }
                        });
                      }),
                  new CustomButton(
                      heroTag: 2,
                      icon: "assets/icons/010-diaper.png",
                      label: "Fralda",
                      onTap: () {
                        ActivityPicker ap = new ActivityPicker.add(
                            context, ActivityType.DIAPER);
                        ap.showActivityDialog().then((ap) {
                          if (ap != null) {
                            db.addActivity(ap, _babyId);
                          }
                        });
                      }),
                  new CustomButton(
                      heroTag: 3,
                      icon: "assets/icons/018-crib.png",
                      label: "Sono",
                      onTap: () {
                        ActivityPicker ap = new ActivityPicker.add(
                            context, ActivityType.SLEEPING);
                        ap.showActivityDialog().then((ap) {
                          if (ap != null) {
                            db.addActivity(ap, _babyId);
                          }
                        });
                      }),
                  new CustomButton(
                      heroTag: 4,
                      icon: "assets/icons/022-food.png",
                      label: "Comida",
                      onTap: () {
                        ActivityPicker ap =
                            new ActivityPicker.add(context, ActivityType.FOOD);
                        ap.showActivityDialog().then((ap) {
                          if (ap != null) {
                            db.addActivity(ap, _babyId);
                          }
                        });
                      }),
                  new CustomButton(
                      heroTag: 5,
                      icon: "assets/icons/034-syringe.png",
                      label: "Medicação",
                      onTap: () {
                        ActivityPicker ap = new ActivityPicker.add(
                            context, ActivityType.MEDICINE);
                        ap.showActivityDialog().then((ap) {
                          if (ap != null) {
                            db.addActivity(ap, _babyId);
                          }
                        });
                      }),
                ],
              ),
            ),
            new Expanded(
                child: _babyId != null
                    ? new PageView.builder(
                        controller: new PageController(
                          initialPage: _startPage,
                        ),
                        reverse: false,
                        itemBuilder: (BuildContext context, int index) {
                          DateTime now = new DateTime.now();
                          DateTime displayDate =
                              _birthDate.add(new Duration(days: index));
                          return new StreamBuilder<QuerySnapshot>(
                            stream: db.allActivities(_babyId, displayDate),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return new Center(
                                  child: new CircularProgressIndicator(),
                                );
                              } else {
                                return new Column(
                                  children: <Widget>[
                                    new OptionsMenu(
                                      displayDate: displayDate,
                                      onTapDate: () async {
                                        DateTime dateTimePicked =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: new DateTime(
                                                    now.year,
                                                    now.month,
                                                    now.day),
                                                firstDate: _currentBaby
                                                    .birthDate
                                                    .subtract(
                                                        new Duration(days: 1)),
                                                lastDate: new DateTime.now());

                                        if (dateTimePicked != null) {
                                          setState(() {
                                            _startPage = dateTimePicked
                                                .difference(_birthDate)
                                                .inDays;
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
                        })
                    : new Center(child: new Text("Selecione um Bebê")))
          ]),
    );
  }

  Future _openAddEntryDialog() async {
    Baby save = await Navigator.of(context).push(new MaterialPageRoute<Baby>(
        builder: (BuildContext context) {
          return new BabyEntryDialog.add(_uid);
        },
        fullscreenDialog: true));
    if (save != null) {
      _addBaby(save);
    }
  }

  _editEntry(Baby baby, String babyId) {
    Navigator
        .of(context)
        .push(
          new MaterialPageRoute<Baby>(
            builder: (BuildContext context) {
              return new BabyEntryDialog.edit(baby);
            },
            fullscreenDialog: true,
          ),
        )
        .then((newSave) {
      if (newSave != null) {
        db.editBaby(newSave, babyId);
        setState(() {
          DateTime now = new DateTime.now();
          _babyId = babyId;
          _currentBaby = newSave;
          _birthDate = new DateTime(_currentBaby.birthDate.year,
              _currentBaby.birthDate.month, _currentBaby.birthDate.day);
          _startPage = new DateTime(now.year, now.month, now.day)
              .difference(_birthDate)
              .inDays;
        });
      }
    });
  }

  void _addBaby(Baby save) {
    db.addBaby(save).then((id) {
      setState(() {
        DateTime now = new DateTime.now();
        _babyId = id;
        _currentBaby = save;
        _birthDate = new DateTime(_currentBaby.birthDate.year,
            _currentBaby.birthDate.month, _currentBaby.birthDate.day);
        _startPage = new DateTime(now.year, now.month, now.day)
            .difference(_birthDate)
            .inDays;
      });
    });
  }

  _deleteBaby() {
    db.deleteBaby(_babyId).whenComplete(() {
      setState(() {
        _startPage = null;
        _birthDate = null;
        _currentBaby = null;
        _babyId = null;
      });
    });
  }
}

class OptionsMenu extends StatefulWidget {
  const OptionsMenu({
    Key key,
    @required this.displayDate,
    this.onTapDate,
  }) : super(key: key);

  final DateTime displayDate;
  final VoidCallback onTapDate;

  @override
  OptionsMenuState createState() {
    return new OptionsMenuState(this.displayDate, this.onTapDate);
  }
}

class OptionsMenuState extends State<OptionsMenu> {
  DateTime displayDate;
  VoidCallback onTapDate;

  OptionsMenuState(this.displayDate, this.onTapDate);

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
                icon: new Icon(Icons.filter_list),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return new SimpleDialog(
                          contentPadding: EdgeInsets.zero,
                          title: new Text("Escolha as atividades"),
                          children: <Widget>[
                            new CheckboxListTile(
                              value: false,
                              onChanged: null,
                              title: new Text("Amamentação"),
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                new FlatButton(
                                    onPressed: null, child: new Text("OK"))
                              ],
                            )
                          ],
                        );
                      });
                })
          ],
        ));
  }
}
