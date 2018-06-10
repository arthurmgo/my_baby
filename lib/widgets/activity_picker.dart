import 'dart:async';

import 'package:flutter/material.dart';

import '../model/activity.dart';
import 'dialogs/bottle_dialog.dart';
import 'dialogs/breast_feeding_dialg.dart';
import 'dialogs/diaper_dialog.dart';
import 'dialogs/food_dialog.dart';
import 'dialogs/medicine_dialog.dart';
import 'dialogs/sleeping_dialog.dart';

class ActivityPicker {
  final BuildContext _context;
  final String type;
  final Activity activityEntryToEdit;

  ActivityPicker.add(this._context, this.type) : activityEntryToEdit = null;

  ActivityPicker.edit(this._context, this.type, this.activityEntryToEdit);

  Future<Activity> showActivityDialog() async {
    Activity ac = await showDialog<Activity>(
        context: _context,
        builder: (BuildContext context) {
          if (activityEntryToEdit != null) {
            switch (type) {
              case ActivityType.BREAST_FEEDING:
                return new BreastFeedingDialog.edit(activityEntryToEdit);
              case ActivityType.DIAPER:
                return new DiaperDialog.edit(activityEntryToEdit);
              case ActivityType.FOOD:
                return new FoodDialog.edit(activityEntryToEdit);
              case ActivityType.SLEEPING:
                return new SleepingDialog.edit(activityEntryToEdit);
              case ActivityType.BOTTLE:
                return new BottleDialog.edit(activityEntryToEdit);
              case ActivityType.MEDICINE:
                return new MedicineDialog.edit(activityEntryToEdit);
            }
          } else {
            switch (type) {
              case ActivityType.BREAST_FEEDING:
                return new BreastFeedingDialog.add();
              case ActivityType.DIAPER:
                return new DiaperDialog.add();
              case ActivityType.FOOD:
                return new FoodDialog.add();
              case ActivityType.SLEEPING:
                return new SleepingDialog.add();
              case ActivityType.BOTTLE:
                return new BottleDialog.add();
              case ActivityType.MEDICINE:
                return new MedicineDialog.add();
            }
          }
        });
    return ac;
  }
}
