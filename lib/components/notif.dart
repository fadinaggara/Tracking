import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> AlertNotif() async {

  AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'you are in in desired location',
      )
  );

}

SnackBar snackBar(String txt){
  return SnackBar(
    content:  Text(txt),
  );
}
void showTos(txt){
  Fluttertoast.showToast(
      msg: txt,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0
  );
}

void detectIfInRange(double d){
  if(d>1.0 && d<20.0){
    AlertNotif();
  }
}
