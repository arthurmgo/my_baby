import 'package:flutter/material.dart';


import '../utils/auth.dart';

class LoginPage extends StatefulWidget {

  final VoidCallback onSignedIn;
  final BaseAuth auth;

  LoginPage({this.auth, this.onSignedIn});

  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPage> {

  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  FormType _formType = FormType.login;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Login Page"),
      ),
      body: new Container(
        padding: EdgeInsets.all(8.0),
        child: new Form(
          key: formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildInputs() + buildSubmitButtons(),
            )
        )
      ),
    );
  }


  List<Widget> buildInputs(){
    return [
      new TextFormField(
        decoration: new InputDecoration(labelText: "Email"),
        validator:
            (value) => value.isEmpty ? "Email can\'t be empty" : null,
        onSaved:
            (value) => _email = value,
      ),
      new TextFormField(
        decoration: new InputDecoration(labelText: "Password"),
        obscureText: true,
        validator:
            (value) => value.isEmpty ? "Email can\'t be empty" : null,
        onSaved:
            (value) => _password = value,
      ),
    ];
  }

  List<Widget> buildSubmitButtons(){
    if(_formType == FormType.login) {
      return [
        new Padding(padding: EdgeInsets.only(top: 10.0)),
        new RaisedButton(
          child: new Text(
            "Login",
            style: new TextStyle(
                fontSize: 20.0
            ),
          ),
          onPressed: validateAndSubmit,
        ),
        new FlatButton(
            onPressed: moveToRegister,
            child: new Text(
              "Create an account",
              style: new TextStyle(
                  fontSize: 20.0
              ),
            )
        )
      ];
    } else {
      return [
        new Padding(padding: EdgeInsets.only(top: 10.0)),
        new RaisedButton(
          child: new Text(
            "Create an account",
            style: new TextStyle(
                fontSize: 20.0
            ),
          ),
          onPressed: validateAndSubmit,
        ),
        new FlatButton(
            onPressed: moveToLogin,
            child: new Text(
              "Have an account? Login",
              style: new TextStyle(
                  fontSize: 20.0
              ),
            )
        )
      ];
    }
  }

  bool validateAndSave() {

    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async{

    if(validateAndSave()){
      try {
        if(_formType == FormType.login){
          String userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
          print("Signed in: $userId");
        }else {
          String userId = await widget.auth.createUserWithEmailAndPassword(_email, _password);
          print("Registred user: $userId");
        }
        widget.onSignedIn();
      }catch(e){
        print("Error: $e");
      }
    }
  }


  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }
}