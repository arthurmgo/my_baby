import 'package:cloud_firestore/cloud_firestore.dart';

class Sex {
  static const MALE = "male";
  static const FEMALE = "female";
}

class Baby {
  String masterId;
  String name;
  String sex;
  DateTime birthDate;

  Baby(this.masterId, this.name, this.sex, this.birthDate);

  Baby.decode(DocumentSnapshot document)
      : masterId = document['masterId'],
        name = document['name'],
        sex = document['sex'],
        birthDate = document['birthDate'];

  Map<String, dynamic> encode() {
    return {
      'masterId': this.masterId,
      'name': this.name,
      'sex': this.sex,
      'birthDate': this.birthDate
    };
  }
}
