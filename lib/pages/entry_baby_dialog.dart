
import 'package:flutter/material.dart';

import '../widgets/date_time.dart';
import '../model/baby.dart';

class BabyEntryDialog extends StatefulWidget {

  final String masterId;
  final Baby babyEntryToEdit;

  BabyEntryDialog.add(this.masterId) :
        babyEntryToEdit = null;


  BabyEntryDialog.edit(this.babyEntryToEdit) :
        masterId = babyEntryToEdit.masterId;

  @override
  WeightEntryDialogState createState() {
    if (babyEntryToEdit != null) {
      return new WeightEntryDialogState(babyEntryToEdit.birthDate,
          babyEntryToEdit.sex, babyEntryToEdit.name);
    } else {
      return new WeightEntryDialogState(
          new DateTime.now(), null, null);
    }
  }
}

class WeightEntryDialogState extends State<BabyEntryDialog> {

  final formKey = new GlobalKey<FormState>();

  DateTime _birthDate = new DateTime.now();
  String _sex;
  String _name;

  TextEditingController _textController;

  WeightEntryDialogState(this._birthDate, this._sex, this._name);

  Widget _createAppBar(BuildContext context) {
    return new AppBar(
      title: widget.babyEntryToEdit == null
          ? const Text("Adicionar Bebê")
          : const Text("Editar Bebê"),
      actions: [
        new FlatButton(
          onPressed: () {
            if(_sex != null && _name != null){
              Navigator
                  .of(context)
                  .pop(new Baby(widget.masterId, _name, _sex, _birthDate));
            }else{

            }
          },
          child: new Text('SAVE',
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: _name);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _createAppBar(context),
      body: new ListView(
        children: [
           new ListTile(
            leading: new Image.asset("assets/icons/001-baby-6.png", width: 32.0, height: 32.0,),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Nome',
              ),
              controller: _textController,
              onChanged: (value) => _name = value,
            ),
          ),
          new Padding(padding: new EdgeInsets.only(top: 10.0)),
          new Container(
            padding: const EdgeInsets.only(left: 16.0),
            child: new Row(
              children: <Widget>[
                new Image.asset("assets/icons/044-gender.png", width: 32.0, height: 32.0, ),
                new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Radio<String>(
                          value: Sex.FEMALE,
                          groupValue: _sex,
                          onChanged: (String value) { setState(() { _sex = value; }); },
                        ),
                        const Text("Menina")
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        new Radio<String>(
                          value: Sex.MALE,
                          groupValue: _sex,
                          onChanged: (String value) { setState(() { _sex = value; }); },
                        ),
                        const Text("Menino")
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          new ListTile(
            leading: new Image.asset("assets/icons/026-calendar.png", width: 32.0, height: 32.0,),
            title: new DateItem(
              dateTime: _birthDate,
              onChanged: (dateTime) => setState(() => _birthDate = dateTime),
            ),
          ),
        ],
      ),
    );
  }
}


