import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/activity.dart';
import '../model/baby.dart';

class DataBase {
  Future<String> addBaby(Baby baby) async {
    DocumentReference documentReference =
        Firestore.instance.collection("babies").document();

    await documentReference.setData(baby.encode());
    return documentReference.documentID;
  }

  Future<Null> editBaby(Baby baby, String babyId) async {
    await Firestore.instance
        .collection("babies")
        .document(babyId)
        .setData(baby.encode());
  }

  Future<Null> deleteBaby(String babyId) async {
    await Firestore.instance
        .collection("babies")
        .document(babyId).delete();
  }

  Future<Null> deleteActivity(String babyId, String activityId) async {
    await Firestore.instance
        .collection("babies")
        .document(babyId)
        .collection("activities")
        .document(activityId)
        .delete();
  }

  void addActivity(Activity activity, String babyId) async {
    DocumentReference documentReference = Firestore.instance
        .collection("babies")
        .document(babyId)
        .collection("activities")
        .document();

    await documentReference.setData(activity.encode());
  }

  void editActivity(Activity activity, String babyId, String activityId) async {
    DocumentReference documentReference = Firestore.instance
        .collection("babies")
        .document(babyId)
        .collection("activities")
        .document(activityId);

    await documentReference.setData(activity.encode());
  }

  Stream<QuerySnapshot> babiesByUser(String uid) {
    return Firestore.instance
        .collection('babies')
        .where('masterId', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot> allActivities(String babyId, DateTime date, String type) {
    if (type != null){
      return Firestore.instance
          .collection('babies')
          .document(babyId)
          .collection('activities')
          .where('timeStart',
          isLessThan: date.add(new Duration(days: 1)),
          isGreaterThanOrEqualTo: date).where('type', isEqualTo: type)
          .snapshots();
    }else{
      return Firestore.instance
          .collection('babies')
          .document(babyId)
          .collection('activities')
          .where('timeStart',
          isLessThan: date.add(new Duration(days: 1)),
          isGreaterThanOrEqualTo: date)
          .snapshots();
    }
  }
}
