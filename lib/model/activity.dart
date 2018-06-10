import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivityType {
  ActivityType._();

  static const BREAST_FEEDING = "BreastFeeding";
  static const BOTTLE = "Bottle";
  static const DIAPER = "Diapler";
  static const SLEEPING = "Sleeping";
  static const FOOD = "Food";
  static const MEDICINE = "Medicine";
}

abstract class Activity {
  final String type;
  DateTime timeStart;
  DateTime timeEnd;
  String note;

  Activity(this.type, this.timeStart, this.timeEnd, this.note);

  Activity.decode(DocumentSnapshot document)
      : type = document["type"],
        timeStart = document["timeStart"],
        timeEnd = document["timeEnd"],
        note = document["note"];

  Map<String, dynamic> encode();

  String typeText() {
    switch (type) {
      case ActivityType.BREAST_FEEDING:
        return "Amamentação";
      case ActivityType.BOTTLE:
        return "Mamadeira";
      case ActivityType.DIAPER:
        return "Fralda";
      case ActivityType.FOOD:
        return "Comida";
      case ActivityType.MEDICINE:
        return "Medicação";
      case ActivityType.SLEEPING:
        return "Soneca";
      default:
        return "Outras";
    }
  }

  Color getTypeColor() {
    switch (type) {
      case ActivityType.BREAST_FEEDING:
        return new Color(0xffc5cae9);
      case ActivityType.BOTTLE:
        return new Color(0xffffccbc);
      case ActivityType.DIAPER:
        return new Color(0xffc5e1a5);
      case ActivityType.FOOD:
        return new Color(0xffb2ebf2);
      case ActivityType.MEDICINE:
        return new Color(0xfffff59d);
      case ActivityType.SLEEPING:
        return new Color(0xffced7db);
      default:
        return Colors.grey;
    }
  }
}

class Breast {
  Breast._();

  static const LEFT = "left";
  static const RIGHT = "rigth";
}

class BreastFeeding extends Activity {
  String breast;

  BreastFeeding(
      DateTime timeStart, DateTime timeEnd, String note, String breast)
      : super(ActivityType.BREAST_FEEDING, timeStart, timeEnd, note) {
    this.breast = breast;
  }

  BreastFeeding.decode(DocumentSnapshot document) : super.decode(document) {
    this.breast = document['breast'];
  }

  @override
  Map<String, dynamic> encode() {
    return {
      "type": this.type,
      "timeEnd": this.timeEnd,
      "timeStart": this.timeStart,
      "note": this.note,
      "breast": this.breast,
    };
  }
}

class Bottle extends Activity {
  Bottle(DateTime timeStart, DateTime timeEnd, String note)
      : super(ActivityType.BOTTLE, timeStart, timeEnd, note);

  Bottle.decode(DocumentSnapshot document) : super.decode(document);

  @override
  Map<String, dynamic> encode() {
    return {
      "type": this.type,
      "timeEnd": this.timeEnd,
      "timeStart": this.timeStart,
      "note": this.note,
    };
  }
}

class Diaper extends Activity {
  Diaper(DateTime timeStart, DateTime timeEnd, String note)
      : super(ActivityType.DIAPER, timeStart, timeEnd, note);

  Diaper.decode(DocumentSnapshot document) : super.decode(document);

  @override
  Map<String, dynamic> encode() {
    return {
      "type": this.type,
      "timeEnd": this.timeEnd,
      "timeStart": this.timeStart,
      "note": this.note,
    };
  }
}

class Sleeping extends Activity {
  Sleeping(DateTime timeStart, DateTime timeEnd, String note)
      : super(ActivityType.SLEEPING, timeStart, timeEnd, note);

  Sleeping.decode(DocumentSnapshot document) : super.decode(document);

  @override
  Map<String, dynamic> encode() {
    return {
      "type": this.type,
      "timeEnd": this.timeEnd,
      "timeStart": this.timeStart,
      "note": this.note,
    };
  }
}

class Food extends Activity {
  Food(DateTime timeStart, DateTime timeEnd, String note)
      : super(ActivityType.FOOD, timeStart, timeEnd, note);

  Food.decode(DocumentSnapshot document) : super.decode(document);

  @override
  Map<String, dynamic> encode() {
    return {
      "type": this.type,
      "timeEnd": this.timeEnd,
      "timeStart": this.timeStart,
      "note": this.note,
    };
  }
}

class Medicine extends Activity {
  Medicine(DateTime timeStart, DateTime timeEnd, String note)
      : super(ActivityType.MEDICINE, timeStart, timeEnd, note);

  Medicine.decode(DocumentSnapshot document) : super.decode(document);

  @override
  Map<String, dynamic> encode() {
    return {
      "type": this.type,
      "timeEnd": this.timeEnd,
      "timeStart": this.timeStart,
      "note": this.note,
    };
  }
}
