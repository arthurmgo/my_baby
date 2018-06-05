import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityType {

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


}


class Breast {
  static const LEFT = "left";
  static const RIGHT = "rigth";
}

class BreastFeeding extends Activity{

  Breast breast;

  BreastFeeding(DateTime timeStart, DateTime timeEnd, String note, Breast breast) :
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
