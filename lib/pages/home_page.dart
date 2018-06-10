import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/activity.dart';
import '../model/baby.dart';
import '../utils/auth.dart';
import '../utils/data_base.dart';
import '../widgets/activity_picker.dart';
import '../widgets/activity_view.dart';
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
  DataBase db = new DataBase();

  String _type;

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
              _babyId = document.documentID;
              _currentBaby = baby;
              _birthDate = new DateTime(_currentBaby.birthDate.year,
                  _currentBaby.birthDate.month, _currentBaby.birthDate.day);
            });
            Navigator.of(context).pop();
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
        title: _currentBaby == null
            ? new Text("My Baby")
            : new Text("My Baby ${_currentBaby.name}"),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.delete),
              onPressed: () {
                if (_babyId != null) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return new AlertDialog(
                          title: new Text("Deletar"),
                          content:
                              new Text("Deseja deletar o bebê selecionado?"),
                          actions: <Widget>[
                            new FlatButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: new Text("CANCELAR")),
                            new FlatButton(
                                onPressed: () {
                                  _deleteBaby();
                                  Navigator.of(context).pop();
                                },
                                child: new Text("CONFIRMAR"))
                          ],
                        );
                      });
                }
              })
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
                    ? new ActivityView(
                        key: new Key(_babyId),
                        babyId: _babyId,
                        birthDate: _birthDate,
                        db: db)
                    : new Center(child: new Text("Selecione um Bebê")))
          ]),
    );
  }

  _deleteBaby() {
    db.deleteBaby(_babyId);
    setState(() {
      _birthDate = null;
      _currentBaby = null;
      _babyId = null;
    });
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
          _babyId = babyId;
          _currentBaby = newSave;
          _birthDate = new DateTime(_currentBaby.birthDate.year,
              _currentBaby.birthDate.month, _currentBaby.birthDate.day);
        });
      }
    });
  }

  void _addBaby(Baby save) {
    db.addBaby(save).then((id) {
      setState(() {
        _babyId = id;
        _currentBaby = save;
        _birthDate = new DateTime(_currentBaby.birthDate.year,
            _currentBaby.birthDate.month, _currentBaby.birthDate.day);
      });
    });
  }
}
