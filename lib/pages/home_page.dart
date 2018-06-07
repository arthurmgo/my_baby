import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:async';

import 'entry_baby_dialog.dart';

import '../model/baby.dart';
import '../model/activity.dart';

import '../utils/auth.dart';
import '../utils/data_base.dart';

import '../widgets/custom_butom.dart';
import '../widgets/activity_picker.dart';




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
    widget.auth.currentUser().then((value){
      setState(() {
        _uid = value;
      });
    }).catchError((e){
      print(e);
    });
    super.initState();
  }
  
  List<Widget> builder(AsyncSnapshot<QuerySnapshot> snapshot){
    if(snapshot.hasData){
      return snapshot.data.documents.map((DocumentSnapshot document) {
        Baby baby = new Baby.decode(document);
        return new ListTile(
            title: new Text(baby.name),
            subtitle: new Text(new DateFormat('dd/MM/yyyy').format(baby.birthDate)),
            trailing: new IconButton(icon: new Icon(Icons.edit), onPressed: (){}),
            leading: new CircleAvatar(
              child: Text(
                baby.name[0], 
                style: new TextStyle(
                    color: Colors.white
                ),
              ),
              backgroundColor: baby.sex ==  "female" 
                  ? Colors.pinkAccent[100] 
                  : Colors.blueAccent[100],
            ),
          onTap: () {
              setState(() {
                _babyId = document.documentID;
              });
              Navigator.of(context).pop();
          },
        );
      }).toList();
    } 
    return [];
  }




  List<Widget> builderActivity(AsyncSnapshot<QuerySnapshot> snapshot){
    if(snapshot.hasData){
      return snapshot.data.documents.map((DocumentSnapshot document) {
        Activity activity = new BreastFeeding.decode(document);
        return new ListTile(
          title: new Text(activity.typeText()),
          subtitle: new Text(new DateFormat('dd/MM/yyyy - hh:mm').format(activity.timeStart)),
          leading: new CircleAvatar(
            child: Text(
              activity.typeText()[0],
              style: new TextStyle(
                  color: Colors.white
              ),
            ),
            backgroundColor: Colors.purple
          ),
          onTap: () {
          },
        );
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("My Baby"),
      ),
      drawer: new Drawer(
        child: new StreamBuilder<QuerySnapshot>(
          stream: db.babiesByUser(_uid),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return new ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                new UserAccountsDrawerHeader(
                  accountName: new Text("User"),
                  accountEmail: new Text("user@userdomain.com"),
                )] +
                builder(snapshot) + [
                new ListTile(
                  leading: new Icon(
                      Icons.add
                  ),
                  title: new Text(
                      "Adicionar Bebê"
                  ),
                  onTap: _openAddEntryDialog
                ),
                new Divider(),
                new ListTile(
                  title: new Text(
                      "Sair"
                  ),
                  leading: new Icon(
                      Icons.exit_to_app
                  ),
                  onTap: _signOut,
                )
              ]
            );
          },
        ),
      ),
      body:
      new Column(
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
                new Padding(padding: new  EdgeInsets.only(left: 8.0)),
                new CustomButton(
                  heroTag: 0,
                  icon: "assets/icons/036-breast.png",
                  label: "Amamentação",
                  onTap: (){
                    ActivityPicker ap = new ActivityPicker.add(context, new DateTime.now(), new DateTime.now());
                    ap.breastfeedingDialog().then((ap){
                      if (ap != null){
                        db.addActivity(ap, _babyId);
                      }
                    });
                  },
                ),
                new CustomButton(
                  heroTag: 1,
                  icon: "assets/icons/024-feeding-bottle.png",
                  label: "Mamadeira",
                ),
                new CustomButton(
                  heroTag: 2,
                  icon: "assets/icons/010-diaper.png",
                  label: "Fralda",
                ),
                new CustomButton(
                  heroTag: 3,
                  icon: "assets/icons/018-crib.png",
                  label: "Sono",
                ),
                new CustomButton(
                  heroTag: 4,
                  icon: "assets/icons/022-food.png",
                  label: "Comida",
                ),
                new CustomButton(
                  heroTag: 5,
                  icon: "assets/icons/034-syringe.png",
                  label: "Medicação",
                ),
              ],
            ),
          ),

          new Expanded(
            child: _babyId != null
              ? new StreamBuilder<QuerySnapshot>(
              stream: db.allActivities(_babyId),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData){
                  return new Text("Não existem atividades cadastradas");
                } else {
                return new ListView(
                  padding: EdgeInsets.zero,
                  children: builderActivity(snapshot),
                );
                }
              },
            )
              : new Center(child: new Text("Selecione um Bebê"))
          )
        ]
      ),
    );
  }

  Future _openAddEntryDialog() async {
    Baby save = await Navigator.of(context)
      .push(new MaterialPageRoute<Baby>(
        builder: (BuildContext context) {
          return new BabyEntryDialog.add(_uid);
        },
        fullscreenDialog: true
      )
    );
    if (save != null) {
      _addBaby(save);
    }
  }

  void _addBaby(Baby save) {

    db.addBaby(save).then((id){
      setState(() {
        _babyId = id;
      });
    });
  }
}


