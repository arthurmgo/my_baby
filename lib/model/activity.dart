import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityType {

  ActivityType._();

  static const BREAST_FEEDING = "BreastFeeding";
  static const BOTTLE = "Bootle";
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

  Activity.decode(DocumentSnapshot document) :
    type = document["type"],
    timeStart = document["timeStart"],
    timeEnd = document["timeEnd"],
    note = document["note"];


  Map<String, dynamic> encode();

  String typeText(){
    switch(type){
      case ActivityType.BREAST_FEEDING: return "Amamentação";
      case ActivityType.BOTTLE: return "Mamadeira";
      case ActivityType.DIAPER: return "Fralda";
      case ActivityType.FOOD: return "Comida";
      case ActivityType.MEDICINE: return "Medicação";
      case ActivityType.SLEEPING: return "Soneca";
      default: return "Outras";
    }
  }


}


class Breast {

  Breast._();

  static const LEFT = "left";
  static const RIGHT = "rigth";
}

class BreastFeeding extends Activity{

  String breast;

  BreastFeeding(DateTime timeStart, DateTime timeEnd, String note, String breast) :
    super(ActivityType.BREAST_FEEDING, timeStart, timeEnd, note){
      this.breast = breast;
  }

  BreastFeeding.decode(DocumentSnapshot document) : super.decode(document) {
    this.breast = document['type'];
  }

  @override
  Map<String, dynamic> encode() {
    return {
      "type"      : this.type,
      "timeEnd"   : this.timeEnd,
      "timeStart" : this.timeStart,
      "note"      : this.note,
      "breast"    : this.breast,
    };
  }
}
