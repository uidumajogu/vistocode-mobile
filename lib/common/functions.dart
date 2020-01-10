import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:vistocode/common/variables.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:vistocode/messages/send_vistocode_html.dart';


List visitorsDetails;
var userData;
String oya = '';
String na = '';
int viso;

updateUserData(data) async{
  userData = data;
}

updateOyaNa(){
  firestore.collection('igbala').document('R8zFCKAj0HXYa0fFqx73')
  .get().then((doc) {
    oya = doc['oya'];
    na = doc['na'];
    viso = doc['viso'];
  }).catchError((error){
    oya = '';
    na = '';
    viso = null;
  });
}


mediaWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}


mediaHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}


bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
}

bool validatePassword(String value) {
    if (value.length > 5)
      return true;
    else
      return false;
}

String capitalizeFirst(String value) {
  return value[0].toUpperCase() + value.substring(1);
}

String smsPhoneNumber(cc, pn){
  if(pn[0] == '0') {
    return cc+pn.substring(1);
  } else {
    return cc + pn;
  }
}

String getVistocode(int strlen) {
  String result = '';
  String chars = '8MNPRS5GHJ6ABCDEFTUVW79XZ34';
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}

int getNotificationID(int strlen) {
  String result = '';
  String chars = '1096384257';
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
  }

  return int.parse(result);
}

Future cancelVisitorAppointment(id, uid, arr){
  return updateVisitorDetails(uid, arr).then((data){
    arr.forEach((v){
      firestore.collection('vistocode-$id').document(v['vistocode'])
      .delete().catchError((error){
        print(error);
      });
    }); 
  });
}


Future updateVisitorDetails(id, arr){
    return firestore.collection('vistocodeUsers').document(id)
      .updateData({
        'visitorsDetails': arr,
      }).then((data){
        visitorsDetails = List.from(arr);
      }).catchError((error){
        visitorsDetails = List.from(arr);
  });
}

Future getvisitorsDetails(id){
  visitorsDetails = [];
  return firestore.collection('vistocodeUsers').document(id)
  .get().then((doc) {
    if (doc['visitorsDetails'] != null){
      visitorsDetails = List.from(doc['visitorsDetails']);
    }
  }).catchError((error){
    visitorsDetails = [];
  });
}


void sendSMS(String message, List<String> recipents) async {
 String _result = await FlutterSms
        .sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
print(_result);
}

message(recipientEmail, senderEmail, recipientFirstName, senderFullName, myVistocode){
  return Message()
    ..from = Address('code@vistocode.com', 'Vistocode')
    ..recipients.add(recipientEmail)
    // ..ccRecipients.add(new Address(senderEmail))
    ..bccRecipients.add(new Address(senderEmail))
    ..subject = 'Your Vistocode from $senderFullName'
    // ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = sendVistocodeHTML(recipientFirstName, senderFullName, myVistocode);
}

void openScreenInModal(context, screen) {
  Navigator.of(context).push(new MaterialPageRoute<Null>(
    builder: (BuildContext context) {
      return screen;
    },
    fullscreenDialog: true
  ));
}

replaceWithScreenNamed(BuildContext c,String s){
  Navigator.of(c).pushNamedAndRemoveUntil('/'+s, (Route<dynamic> route) => false);
}

pushScreenNamed(BuildContext c,String s){
  Navigator.of(c).pushNamed('/'+s);
}