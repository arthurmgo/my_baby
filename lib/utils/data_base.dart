import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/activity.dart';
import '../model/baby.dart';


class DataBase {

  Future<String> addBaby(Baby baby) async{
    DocumentReference documentReference = Firestore.instance
        .collection("babies").document();

    await documentReference.setData(baby.encode());
    return documentReference.documentID;
  }

  void addActivity(Activity activity,String babyId) async{
    DocumentReference documentReference = Firestore.instance
        .collection("babies")
        .document(babyId)
        .collection("activities").document();

    await documentReference.setData(activity.encode());
  }

  Stream<QuerySnapshot> babiesByUser(String uid){
    return Firestore.instance
        .collection('babies')
        .where('masterId', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot> allActivities(String babyId){
    return Firestore.instance
        .collection('babies')
        .document(babyId)
        .collection('activities').snapshots();
  }


}