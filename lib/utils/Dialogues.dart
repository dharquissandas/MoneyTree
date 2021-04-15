import 'package:flutter/material.dart';
import 'package:money_tree/screens/layoutManagers/HomeLayout.dart';
import 'package:money_tree/utils/Notifications.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'package:page_transition/page_transition.dart';

//open Sidebar Currency Selector
openCurrencySelector(context) {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Select Currency'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            setCurrency("£");
            Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft, child: Home()),
                (r) => false);
          },
          child: const Text('Pounds (£)'),
        ),
        SimpleDialogOption(
          onPressed: () {
            setCurrency("\$");
            Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft, child: Home()),
                (r) => false);
          },
          child: const Text('Dollars (\$)'),
        ),
        SimpleDialogOption(
          onPressed: () {
            setCurrency("€");
            Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft, child: Home()),
                (r) => false);
          },
          child: const Text('Euros (€)'),
        ),
      ],
    ),
  );
}

//open Sidebar Notfication Selector
openNotificationSelection(context, flutterLocalNotificationsPlugin) {
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Show Daily Notifications'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            scheduleRecorruingNotification(flutterLocalNotificationsPlugin);
            Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft, child: Home()),
                (r) => false);
          },
          child: const Text('Allow Notifications'),
        ),
        SimpleDialogOption(
          onPressed: () {
            turnReoccuringNotificationOff(flutterLocalNotificationsPlugin);
            Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft, child: Home()),
                (r) => false);
          },
          child: const Text('Disable Notifications'),
        ),
      ],
    ),
  );
}
