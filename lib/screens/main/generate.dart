import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:vistocode/common/functions.dart';
import 'package:vistocode/common/variables.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:validators/validators.dart';
import 'package:validators/sanitizers.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/mailgun.dart';
import 'package:mailer/smtp_server.dart';
import 'package:vistocode/screens/main/notification.dart';
import 'package:vistocode/screens/main/visitors.dart';
import '../../main.dart';


String firstName;
String lastName;
String email;
String phoneNumber;
String address;
String state;
String country;
String dateOfVisit;
String timeOfVisit;
List _visitorsDetails;
Map _visitorDetails;
Map _visitorData;
int _visitorDataIndex;
String _message;
List<String> _recipents;

String fNameErrorText;
String lNameErrorText;
String emailErrorText;
String pNumberErrorText;
String addressErrorText;
String stateErrorText;
String countryErrorText;
String dateErrorText;
String timeErrorText;
String purposeErrorText;

TextEditingController fNameTextController;
TextEditingController lNameTextController;
TextEditingController emailTextController;
TextEditingController pNumberTextController;
TextEditingController addressTextController;
TextEditingController stateTextController;
TextEditingController countryTextController;
TextEditingController dateTextController;
TextEditingController timeTextController;

FocusNode fNameFocusNode;
FocusNode lNameFocusNode;
FocusNode emailFocusNode;
FocusNode pNumberFocusNode;
FocusNode addressFocusNode;
FocusNode stateFocusNode;
FocusNode countryFocusNode;
FocusNode dateFocusNode;
FocusNode timeFocusNode;

List<Step> _steps;
int _step;
String _countryCode;
bool confirm;
bool generating;
bool generateError;
String _generateErrorText;
String _generatingMessage;
String _myVistocode;
bool vistocodeGenerated;
String _vcgsMessage;
bool _visitorDetailsSaved;
String _visitorDetailsSavedMessage;
IconData _visitorDetailsSavedIcon;
Color _visitorDetailsSavedIconColor;
bool _selectVisitor;
List<Widget> _visitorsCards;
Color _iconColor;
double _iconSize;
bool _enableSave;
bool _blank;
String _sPurpose;
String _vPurpose;
bool _apmtCancel;
bool _cancellingApmt;
int _notificationID45;
int _notificationID30;
int _notificationID15;



class GenerateScreen extends StatefulWidget {
  @override
  _GenerateScreenState createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }

    // await Navigator.pushReplacement(
    //   currentContext,
    //   MaterialPageRoute(builder: (currentContext) => NotificationScreen(payload)),
    // );
  }

  Future<void> _scheduleNotification(id, time, min) async {
    var arrDate = DateFormat('yyyy-MM-dd hh:mm aa').parse(time);

    var scheduledNotificationDateTime5 =
          arrDate.subtract(new Duration(minutes: min));

    var androidPlatformChannelSpecifics =
        new AndroidNotificationDetails(
          'your other channel id',
          'your other channel name', 
          'your other channel description',
          importance: Importance.High,
          priority: Priority.High,
          // autoCancel: true
          );
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        id,
        'Reminder',
        'Your visitor - $firstName $lastName should be around in $min minutes',
        scheduledNotificationDateTime5,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        payload: 'Your visitor - $firstName $lastName should be around in $min minutes');
  } 

  _getCountryCode() async{
    // try {
    //   _countryCode = await FlutterSimCountryCode.simCountryCode;
    // } on PlatformException catch(e) {
    //   _countryCode = '';
    // }
  }

   _onCountryChange(CountryCode countryCode) {
    _countryCode = countryCode.toString();
    FocusScope.of(context).requestFocus(pNumberFocusNode);
  }

  _textListener() {

    if(fNameFocusNode.hasFocus){
        final _text = fNameTextController.text == '' ? fNameTextController.text : capitalizeFirst(fNameTextController.text);
        fNameTextController.value = fNameTextController.value.copyWith(
          text: _text,
          selection: TextSelection(baseOffset: _text.length, extentOffset: _text.length),
          composing: TextRange.empty,
        );
        firstName = _text;
    }

    if(lNameFocusNode.hasFocus){
        final _text = lNameTextController.text == '' ? lNameTextController.text : capitalizeFirst(lNameTextController.text);
        lNameTextController.value = lNameTextController.value.copyWith(
          text: _text,
          selection: TextSelection(baseOffset: _text.length, extentOffset: _text.length),
          composing: TextRange.empty,
        );
        lastName = _text;
    }

    if(emailFocusNode.hasFocus){
        final _text = emailTextController.text.toLowerCase();
        emailTextController.value = emailTextController.value.copyWith(
          text: _text,
          selection: TextSelection(baseOffset: _text.length, extentOffset: _text.length),
          composing: TextRange.empty,
        );
        email = _text;
    }

    if(pNumberFocusNode.hasFocus){
      final _iText = whitelist(pNumberTextController.text, '0,1,2,3,4,5,6,7,8,9');
      final _text = _iText.length > 15 ? _iText.substring(0,15) : _iText;
      pNumberTextController.value = pNumberTextController.value.copyWith(
        text: _text == '' ? ' ' : _text,
        selection: TextSelection(baseOffset: _text.length, extentOffset: _text.length),
        composing: TextRange.empty,
      );
      phoneNumber = _text;
    }

    if(addressFocusNode.hasFocus){
        final _text = addressTextController.text == '' ? addressTextController.text : addressTextController.text.toUpperCase();
        addressTextController.value = addressTextController.value.copyWith(
          text: _text,
          selection: TextSelection(baseOffset: _text.length, extentOffset: _text.length),
          composing: TextRange.empty,
        );
        address = _text;
    }

    if(stateFocusNode.hasFocus){
        final _text = stateTextController.text == '' ? stateTextController.text : stateTextController.text.toUpperCase();
        stateTextController.value = stateTextController.value.copyWith(
          text: _text,
          selection: TextSelection(baseOffset: _text.length, extentOffset: _text.length),
          composing: TextRange.empty,
        );
        state = _text;
    }

    if(countryFocusNode.hasFocus){
        final _text = countryTextController.text == '' ? countryTextController.text : countryTextController.text.toUpperCase();
        countryTextController.value = countryTextController.value.copyWith(
          text: _text,
          selection: TextSelection(baseOffset: _text.length, extentOffset: _text.length),
          composing: TextRange.empty,
        );
        country = _text;
    }
  
      final _dText = dateTextController.text == '' ? dateTextController.text : dateTextController.text.toUpperCase();
      dateTextController.value = dateTextController.value.copyWith(
        text: _dText,
        selection: TextSelection(baseOffset: _dText.length, extentOffset: _dText.length),
        composing: TextRange.empty,
      );
      dateOfVisit = _dText;
  
      final _tText = timeTextController.text == '' ? timeTextController.text : timeTextController.text.toUpperCase();
        timeTextController.value = timeTextController.value.copyWith(
          text: _tText,
          selection: TextSelection(baseOffset: _tText.length, extentOffset: _tText.length),
          composing: TextRange.empty,
        );
        timeOfVisit = _tText;
  }


  

  _focusListener() {
  }

  _unfocus() {
    fNameFocusNode.unfocus();
    lNameFocusNode.unfocus();
    emailFocusNode.unfocus();
    pNumberFocusNode.unfocus();
    addressFocusNode..unfocus();
    stateFocusNode..unfocus();
    countryFocusNode..unfocus();
    dateFocusNode.unfocus();
    timeFocusNode..unfocus();
  }

  void _showModalSheet() {
    showModalBottomSheet(
      context: context, 
      elevation: 2.0,
      builder: (builder) {
      return Material(
        color: sColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: ListView(
            padding: EdgeInsets.all(18.0),
            children: <Widget>[
              Column(children: _visitorsCards,)
            ],
          ),
        ),
      );
    });
  }

  _updateVisitorDetails(visitor){
    _cancellingApmt = true;
    Navigator.of(context).pop();
    _confirmActiveDialog(visitor);

    List _nVisitorsDetails = List.from(visitorsDetails);
    _nVisitorsDetails.forEach((v){
      if (v == visitor){
        v['active'] = false;
      }
    });
    cancelVisitorAppointment(userData['ID'], userData['docID'], _nVisitorsDetails)
    .then((data){
      _cancellingApmt = false;
      _apmtCancel = true;
      Navigator.of(context).pop();
      _confirmActiveDialog(visitor);
    });
  }

  _continueCancelDialog(visitor){
    _apmtCancel = false;
    Navigator.of(context).pop();
    _pickVisitor(visitor);
  }

  _confirmActiveDialog(visitor){ 
    showDialog(
      context: context,
      barrierDismissible: _cancellingApmt ? false : !_apmtCancel,
      builder: (_)=>Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(18.0),
              color: Colors.white,
              child: _cancellingApmt ? 
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      backgroundColor: bColor,
                      valueColor: AlwaysStoppedAnimation<Color>(pColor),
                    ),
                    Padding(padding: EdgeInsets.all(10.0),),
                    Text('Cancelling appointment...', 
                      style: TextStyle(
                        fontSize: 16.0, 
                        color: sColor),)
                  ],),
              ) :
              
              Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(8.0),),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      _apmtCancel ? "The appointment for ${visitor['firstName']} ${visitor['lastName']} has been canceled." :
                      "${visitor['firstName']} ${visitor['lastName']} has an active appointment. Do you want to cancel the appointment?",
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 16.0, 
                        color: sColor,),),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _apmtCancel ? Padding(padding: EdgeInsets.all(0.0),) : 
                        InkWell(
                          child: Text('No', 
                            style: TextStyle(
                            fontSize: 16.0, 
                            color: sColor),),
                            onTap: ()=>Navigator.of(context).pop(),   
                          ),

                        ButtonTheme(
                          minWidth: mediaWidth(context)*0.4,
                          child: RaisedButton(
                            color: _apmtCancel ? pColor : dColor,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                                child: Text(_apmtCancel ? 'Continue' : 'Yes',
                                  style: TextStyle(
                                  fontSize: 20.0, 
                                  color: Colors.white),
                                ),
                              ),
                            onPressed:  (){
                              setState(() {
                                _apmtCancel ? _continueCancelDialog(visitor) : 
                                _updateVisitorDetails(visitor);
                              });
                            }
                          ),
                        ),    

                      ],),
                  )
                ],),),
          ],
        ),
      ),
    );
  }

  _pickVisitor(visitor){
    setState(() {
      firstName = visitor['firstName'];
      lastName = visitor['lastName'];
      email = visitor['email'];
      phoneNumber = visitor['phoneNumber'];
      address = visitor['address'];
      state = visitor['state'];
      country = visitor['country'];
      _vPurpose = visitor['purpose'];
      _countryCode = visitor['phoneCode'];
      _visitorData = visitor;
      _visitorDataIndex = visitorsDetails.indexOf(visitor);
      _enableSave = true;
      _step = 3;
    });
    Navigator.pop(context);
  }

  _checkInputs() async{
    _unfocus();
    switch (_step) {
      case 0:
        setState(() {
          if(firstName == ''){
            fNameErrorText = 'Enter First Name';
          } else {
            if(lastName == ''){
              lNameErrorText = 'Enter Last Name';
            } else {
              _nextStep();
            }
          }
        });
      break;

      case 1:
        setState(() {
          if(trim(phoneNumber) == ''){
            pNumberErrorText = 'Enter phone number';
          } else {
            if(email == ''){
              emailErrorText = 'Enter email address';
            } else {
              if(!isEmail(email)){
                emailErrorText = 'The email is invalid';
              } else {
                _nextStep();
              }
            }

          }
        });
      break;

      case 2:
        setState(() {
          if(address == ''){
            addressErrorText = 'Enter address';
          } else {
            if(state == ''){
              stateErrorText = 'Enter state';
            } else {
              if(country == ''){
                countryErrorText = 'Enter country';
              } else {
                _nextStep();
              }
            }
          }
        });
      break;

      case 3:
        setState(() {
          if(_vPurpose == ''){
            purposeErrorText = 'Select the purpose of visit';
          } else {
            _nextStep();
          }
        });
      break;
      
      case 4:
        setState(() {
          if(dateOfVisit == ''){
            dateErrorText = 'Enter expected date of visit';
          } else {
            if(timeOfVisit == ''){
              timeErrorText = 'Enter expected time of visit';
            } else {
              DateTime _today = DateFormat('yyyy-MM-dd').parse(DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());
              DateTime _viday = DateFormat('yyyy-MM-dd').parse("$dateOfVisit $timeOfVisit");
              DateTime _timeNow = DateFormat('yyyy-MM-dd hh:mm aa').parse(DateFormat('yyyy-MM-dd hh:mm aa').format(DateTime.now()).toString());
              DateTime _viTime = DateFormat('yyyy-MM-dd hh:mm aa').parse("$dateOfVisit $timeOfVisit");
              if(_viday.difference(_today).inMilliseconds < 0){
                dateErrorText = 'The date is not valid, please select a date from today';
              }else{
              if(_today.difference(_viday).inMilliseconds == 0){
                if(_viTime.difference(_timeNow).inMilliseconds <= 0) {
                  timeErrorText = 'The time is not valid, please select a time from now';
                } else {
                  _nextStep();
                }
              } else {
                _nextStep();
              }
              }

            }
          }
        });
      break;

      default:
    }
  }

  _getPurposeOfVisit(String value){
    setState(() {
      purposeErrorText = '';
      _sPurpose = value;
      switch (value) {
        case 'Official':
          _vPurpose = value;
          break;
        case 'Personal':
          _vPurpose = value;
          break;
        case 'Delivery':
          _vPurpose = value;
          break;
        default:
          _vPurpose = '';
      }
    });
  }

  _previousStep() {
    _unfocus();
    if(_step != 0){
      setState(() {
        _step = _step - 1;
      });
    }
  }

  _nextStep() {
    setState(() {
      if(_step != _steps.length - 1){
        _step = _step + 1;
      } else {
        confirm = true;
      }
    });
  }


  _editDetails() {
    setState(() {
      generateError = false;
      _generateErrorText = '';
      confirm = false;
      _step = 0;
    });
  }


  Map _newVisitorDetails(){
    return  {
      'firstName':firstName, 
      'lastName':lastName,
      'phoneCode': _countryCode,
      'phoneNumber': trim(phoneNumber),
      'email':email,
      'address':address,
      'state':state,
      'country':country,
      'purpose': _vPurpose,
      'dateOfVisit':dateOfVisit,
      'timeOfVisit':timeOfVisit,
      'vistocode':_myVistocode,
      'docID':userData['docID'],
      'ID': userData['ID'],
      'businessName': userData['businessName'],
      'hostEmail': userData['email'],
      'hostFullName': userData['fullName'],
      'hostLocation': userData['location'],
      'active': true,
      'notificationIDs': [_notificationID45, _notificationID30, _notificationID15],
    };
  }


  sendVistocode() async{
    vistocodeGenerated = true;
    setState(() {
      _generatingMessage = 'Sending Vistocode...';
    });

    final smtpServer = mailgun(oya, na);
    final _message = message(email, userData['email'], firstName, userData['fullName'], _myVistocode);
  
    try {
      final sendReport = await send(_message, smtpServer);
      
      setState(() {
        _vcgsMessage = 'The Vistocode has been generated and sent to $firstName ($email), a copy has also been sent to your email.';
        generating = false;
      });
    } on MailerException catch (e) {
      setState(() {
        _vcgsMessage = 'The Vistocode has been generated but could NOT be sent to $firstName ($email). The error was: "${e.message}". Please copy the Vistocode and send it to $firstName.';
        generating = false;
      });
    }
  }


  checkEmail(email) async{
    generateError = false;
    _generateErrorText = '';
  
    var response = await http.get('https://api.emailverifyapi.com/v3/lookups/json?key=6A2A5F1A86DEF543&email='+email);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
        
      if(jsonResponse['deliverable'] != null){
        if(jsonResponse['deliverable']){
          
          _myVistocode = getVistocode(6);
          _notificationID45 = getNotificationID(8);
          _notificationID30 = getNotificationID(7);
          _notificationID15 = getNotificationID(6);
          
          firestore.collection('vistocode-${userData['ID']}').document(_myVistocode)
          .setData({
            'firstName':firstName, 
            'lastName':lastName,
            'phoneCode': _countryCode,
            'phoneNumber': trim(phoneNumber),
            'email':email,
            'address':address,
            'state':state,
            'country':country,
            'purpose': _vPurpose,
            'dateOfVisit':dateOfVisit,
            'timeOfVisit':timeOfVisit,
            'vistocode':_myVistocode,
            'docID':userData['docID'],
            'ID': userData['ID'],
            'businessName': userData['businessName'],
            'hostEmail': userData['email'],
            'hostFullName': userData['fullName'],
            'hostLocation': userData['location'],
            'active': true,
            'notificationIDs': [_notificationID45, _notificationID30, _notificationID15],
        }).then((data){

              DateTime _timeNow = DateFormat('yyyy-MM-dd hh:mm aa').parse(DateFormat('yyyy-MM-dd hh:mm aa').format(DateTime.now()).toString());
              DateTime _reTime45 = DateFormat('yyyy-MM-dd hh:mm aa').parse("$dateOfVisit $timeOfVisit").subtract(Duration(minutes: 45));
              DateTime _reTime30 = DateFormat('yyyy-MM-dd hh:mm aa').parse("$dateOfVisit $timeOfVisit").subtract(Duration(minutes: 30));
              DateTime _reTime15 = DateFormat('yyyy-MM-dd hh:mm aa').parse("$dateOfVisit $timeOfVisit").subtract(Duration(minutes: 15));

                if(_timeNow.difference(_reTime45).inMilliseconds <= 0) {
                  _scheduleNotification(_notificationID45, '$dateOfVisit $timeOfVisit', 45);
                } 
                if(_timeNow.difference(_reTime30).inMilliseconds <= 0) {
                  _scheduleNotification(_notificationID30, '$dateOfVisit $timeOfVisit', 30);
                } 
                if(_timeNow.difference(_reTime15).inMilliseconds <= 0) {
                  _scheduleNotification(_notificationID15, '$dateOfVisit $timeOfVisit', 15);
                } 
          
            if(_enableSave){
              _visitorsDetails = List.from(visitorsDetails);
              _visitorsDetails.removeAt(_visitorDataIndex);
              _visitorsDetails.add(_newVisitorDetails());
              firestore.collection('vistocodeUsers').document(userData['docID'])
                .updateData({
                  'visitorsDetails': _visitorsDetails,
                }).then((data){
                  getvisitorsDetails(userData['docID']).then((data){
                    sendVistocode();
                  });
                  
                }).catchError((error){
                    setState(() {
                      generating = false;
                      generateError = true;
                      _generateErrorText = 'An error occured, please try again';
                    });               
                });
            } else{
              sendVistocode();
            }
          
        }).catchError((error){
          setState(() {
            generating = false;
            generateError = true;
            _generateErrorText = 'An error occured, please try again';
          });
        });

        } else {
          setState(() {
            generating = false;
            generateError = true;
            _generateErrorText = 'Email could not be sent, check the email address and try again';
          });
        }
      } else {
        
          setState(() {
            generating = false;
            generateError = true;
            _generateErrorText = 'Email could not be sent, check the email address and try again';
          });
      }
    } else {
      setState(() {
        generating = false;
        generateError = true;
        _generateErrorText = 'Unable to verify if email is deliverable, try again later';
      });      
    }
  }

  _sendSMS(){
    _message = 'Hello $firstName, this is your Vistocode - $_myVistocode';
    _recipents = ['$_countryCode${trim(phoneNumber)}'];
    sendSMS(_message,_recipents);
    _blank = false;
    replaceWithScreenNamed(context, 'HomeScreen');
  }

  _smsDialog(){ 
    setState(() {
      _blank = true;
    });   
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_)=>Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              // margin: EdgeInsets.all(18.0),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  // Container(
                  //   width: mediaWidth(context),
                  //   height: mediaHeight(context)*0.2,
                  //   decoration: BoxDecoration(
                  //     color: pColor.withOpacity(0.4),
                  //     // shape: BoxShape.circle,
                  //     image: DecorationImage(
                  //       image: AssetImage("assets/images/smsImg.png"),
                  //       fit: BoxFit.contain,
                  //     ),
                  //   ),
                  // ),
                  Padding(padding: EdgeInsets.all(8.0),),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("Send Vistocode to $firstName via SMS?",
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 18.0, 
                        color: sColor, 
                        fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                          child: Text('Close', 
                            style: TextStyle(
                            fontSize: 16.0, 
                            color: sColor),),
                            onTap: ()=>goToHomeScreen(),   
                          ),

                        ButtonTheme(
                          minWidth: mediaWidth(context)*0.4,
                          child: RaisedButton(
                            color: pColor,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                                child: Text('Send SMS',
                                  style: TextStyle(
                                  fontSize: 20.0, 
                                  color: Colors.white),
                                ),
                              ),
                            onPressed:  (){
                              setState(() {
                                _sendSMS();
                              });
                            }
                          ),
                        ),    

                      ],),
                  )
                ],),),
          ],
        ),
      ),
    );
  }


  _visitorDeleteDialog(){ 
    // setState(() {
    //   _blank = true;
    // });   
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_)=>Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              // margin: EdgeInsets.all(18.0),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(8.0),),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text("You have reached the limit to save visitor details. Delete a visitor from your list to continue saving.",
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 18.0, 
                        color: dColor, 
                        fontWeight: FontWeight.bold),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                          child: Text('Close', 
                            style: TextStyle(
                            fontSize: 16.0, 
                            color: sColor),),
                            onTap: ()=>Navigator.of(context).pop(),   
                          ),

                        ButtonTheme(
                          minWidth: mediaWidth(context)*0.4,
                          child: RaisedButton(
                            color: dColor,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                                child: Text('Delete',
                                  style: TextStyle(
                                  fontSize: 20.0, 
                                  color: Colors.white),
                                ),
                              ),
                            onPressed:  (){
                              setState(() {
                                _blank = false;
                                Navigator.of(context).pop();
                                openScreenInModal(context, new VisitorsListScreen());
                              });
                            }
                          ),
                        ),    

                      ],),
                  )
                ],),),
          ],
        ),
      ),
    );
  }

  saveDetails(){
    if(visitorsDetails.length < userData['visitorSaveCount']){
      _visitorsDetails = List.from(visitorsDetails);
      _visitorsDetails.add(_newVisitorDetails());
      updateVisitorDetails(userData['docID'], _visitorsDetails)
      .then((data){
          getvisitorsDetails(userData['docID']).then((data){
            setState(() {
              _visitorDetailsSavedMessage = 'The details of $firstName has been saved!';
              _visitorDetailsSavedIconColor = pColor;
              _visitorDetailsSavedIcon = Icons.check;
              _visitorDetailsSaved = true;
              generating = false;
              _generatingMessage = '';     
            });
          });


          Timer(Duration(seconds: 3), () {
            setState(() {
              _smsDialog();
            });
            });
        }).catchError((error){
          setState(() {
            _visitorDetailsSavedMessage = 'An error occured! the details of $firstName could not be saved!';
            _visitorDetailsSavedIconColor = dColor;
            _visitorDetailsSavedIcon = Icons.close;
            _visitorDetailsSaved = true;
            generating = false;
            _generatingMessage = '';     
          });

          Timer(Duration(seconds: 3), () {
            _smsDialog();
          });
        });
    } else {
      _visitorDeleteDialog();
      generating = false;
    }

    
  }

  goToHomeScreen(){
    replaceWithScreenNamed(context, 'HomeScreen');
  }


  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
      new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );
    var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);

    _getCountryCode();
    // getvisitorsDetails(userData['docID']);
    _visitorDetails = {};
    _visitorData = {};
    _enableSave = false;

    firstName = '';
    lastName = '';
    email = '';
    phoneNumber = '';
    address = '';
    state = '';
    country = '';
    dateOfVisit = '';
    timeOfVisit = '';
    _vcgsMessage = '';
    _selectVisitor = false;
    _message = '';
    _recipents = [];
    _notificationID45 = 45;
    _notificationID30 = 30;
    _notificationID15 = 15;

    fNameErrorText = null;
    lNameErrorText = null;
    emailErrorText = null;
    pNumberErrorText = null;
    addressErrorText = null;
    stateErrorText = null;
    countryErrorText = null;
    dateErrorText = null;
    timeErrorText = null;
    purposeErrorText = '';
    
    fNameTextController = TextEditingController();
    lNameTextController = TextEditingController();
    emailTextController = TextEditingController();
    pNumberTextController = TextEditingController();
    addressTextController = TextEditingController();
    stateTextController = TextEditingController();
    countryTextController = TextEditingController();
    dateTextController = TextEditingController();
    timeTextController = TextEditingController();

    fNameFocusNode = new FocusNode();
    lNameFocusNode = new FocusNode();
    emailFocusNode = new FocusNode();
    pNumberFocusNode = new FocusNode();
    addressFocusNode = new FocusNode();
    stateFocusNode = new FocusNode();
    countryFocusNode = new FocusNode();
    dateFocusNode = new FocusNode();
    timeFocusNode = new FocusNode();

    _steps = [];
    _step = 0;
    _countryCode = '+234';
    confirm = false;
    generating = false;
    generateError = false;
    _generateErrorText = '';
    _generatingMessage = '';
    _myVistocode = '';
    vistocodeGenerated = false;
    _visitorDetailsSaved = false;
    _visitorDetailsSavedMessage = '';
    _visitorDetailsSavedIcon = Icons.check;
    _visitorDetailsSavedIconColor = pColor;
    _visitorsCards = new List<Widget>();
    _iconColor = sColor.withOpacity(0.7);
    _iconSize = 12.0;
    _blank = false;
    _sPurpose = '';
    _vPurpose = '';
    _apmtCancel = false;
    _cancellingApmt = false;



    fNameTextController.addListener(_textListener);
    lNameTextController.addListener(_textListener);
    emailTextController.addListener(_textListener);
    pNumberTextController.addListener(_textListener);
    addressTextController.addListener(_textListener);
    stateTextController.addListener(_textListener);
    countryTextController.addListener(_textListener);
    dateTextController.addListener(_textListener);
    timeTextController.addListener(_textListener);

    fNameFocusNode.addListener(_focusListener);
    lNameFocusNode.addListener(_focusListener);
    emailFocusNode.addListener(_focusListener);
    pNumberFocusNode.addListener(_focusListener);
    addressFocusNode.addListener(_focusListener);
    stateFocusNode.addListener(_focusListener);
    countryFocusNode.addListener(_focusListener);
    dateFocusNode.addListener(_focusListener);
    timeFocusNode.addListener(_focusListener);

    pNumberTextController.text = ' ';
  }

  @override
  void dispose() {
    super.dispose();
    fNameTextController.dispose();
    lNameTextController.dispose();
    emailTextController.dispose();
    pNumberTextController.dispose();
    addressTextController.dispose();
    stateTextController.dispose();
    countryTextController.dispose();
    dateTextController.dispose();
    timeTextController.dispose();

    fNameFocusNode.dispose();
    lNameFocusNode.dispose();
    emailFocusNode.dispose();
    pNumberFocusNode.dispose();
    addressFocusNode.dispose();
    stateFocusNode.dispose();
    countryFocusNode.dispose();
    dateFocusNode.dispose();
    timeFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _stepTitleStyleActive = TextStyle(
          fontSize: 16.0, 
          color: pColor);

    TextStyle _stepTitleStyleInactive = TextStyle(
          fontSize: 16.0, 
          color: sColor);

    TextStyle _detailStyle = TextStyle(
          fontSize: 18.0, 
          color: Colors.white, 
          );  

    TextStyle _purposeStyle = TextStyle(
          fontSize: 18.0, 
          color: sColor, 
          );  
        
    double iconSize = 30.0;
    Color iconColor = oColor;

    // Iterable inReverse = visitorsDetails.reversed;
    // var visitorsDetailsInReverse = inReverse.toList();
    _visitorsCards = new List<Widget>();
    _iconColor = sColor.withOpacity(0.3);
    _iconSize = 16.0;
    visitorsDetails.forEach((visitor){
      _visitorsCards.add(
        InkWell(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Card(
              elevation: 1.0,
              child: Container(
                padding: EdgeInsets.all(18.0),
                width: mediaWidth(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text('${visitor['firstName']} ${visitor['lastName']}', 
                            style: TextStyle(
                              fontSize: 16.0, 
                              color: visitor['active'] ? Colors.green : pColor, 
                              fontWeight: FontWeight.bold),),
                        ),

                        Icon(
                          Icons.chevron_right, 
                          color: visitor['active'] ? Colors.green : pColor)
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(5.0),),

                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.alternate_email, 
                            color: _iconColor, 
                            size: _iconSize,),
                          Padding(padding: EdgeInsets.all(5.0),),
                          Flexible(
                            child: Text('${visitor['email']}',
                              style: TextStyle(
                                  fontSize: 14.0, 
                                  color: sColor,),),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(4.0),),

                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.call,
                            color: _iconColor, 
                            size: _iconSize,),
                          Padding(padding: EdgeInsets.all(5.0),),
                          Flexible(
                            child: Text('${visitor['phoneCode']} ${visitor['phoneNumber']}',
                              style: TextStyle(
                                  fontSize: 14.0, 
                                  color: sColor,),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ) ,),
          ),

          onTap: (){
            visitor['active'] ? _confirmActiveDialog(visitor) :
            _pickVisitor(visitor);
          },
        )
      );

      });


    Widget _name = Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(8.0),),
          TextField(
            controller: fNameTextController..text = firstName,
            focusNode: fNameFocusNode,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'First Name',
            hintText: '',
            suffixIcon: Icon(Icons.person_outline),
            errorText: fNameErrorText,
            ),
            onChanged: (value){
              setState(() {
                fNameErrorText = null;
              });
            },
          ),
          Padding(padding: EdgeInsets.all(8.0),),

          TextField(
            controller: lNameTextController..text = lastName,
            focusNode: lNameFocusNode,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'Last Name',
            hintText: '',
            suffixIcon: Icon(Icons.person),
            errorText: lNameErrorText,
            ),
            onChanged: (value){
              setState(() {
                lNameErrorText = null;
              });
            },
          ),
        ],
      );

    Widget _contact = Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(8.0),),

          TextField(
            controller: pNumberTextController..text = phoneNumber,
            focusNode: pNumberFocusNode,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'Phone',
            hintText: '',
            prefix: CountryCodePicker(
              textStyle: TextStyle(fontSize: 16.0),
              initialSelection: _countryCode,
              favorite: ['+234'],
              onChanged: _onCountryChange,
            ),
            suffixIcon: Icon(Icons.call),
            errorText: pNumberErrorText,
            ),
            onChanged: (value){
              setState(() {
                pNumberErrorText = null;
              });
            },
          ),
          Padding(padding: EdgeInsets.all(8.0),),

          TextField(
            controller: emailTextController..text = email,
            focusNode: emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'Email',
            hintText: '',
            suffixIcon: Icon(Icons.alternate_email),
            errorText: emailErrorText,
            ),
            onChanged: (value){
              setState(() {
                emailErrorText = null;
              });
            },
          ),
        ],
      );

    
      Widget _address = Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(8.0),),

          TextField(
            controller: addressTextController..text = address,
            focusNode: addressFocusNode,
            keyboardType: TextInputType.text,
            maxLines: 2,
            decoration: InputDecoration(
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'Address',
            hintText: '',
            suffixIcon: Icon(Icons.place),
            errorText: addressErrorText,
            ),
            onChanged: (value){
              setState(() {
                addressErrorText = null;
              });
            },
          ),
          Padding(padding: EdgeInsets.all(8.0),),

          TextField(
            controller: stateTextController..text = state,
            focusNode: stateFocusNode,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'State',
            hintText: '',
            suffixIcon: Icon(Icons.map),
            errorText: stateErrorText,
            ),
            onChanged: (value){
              setState(() {
                stateErrorText = null;
              });
            },
          ),
          Padding(padding: EdgeInsets.all(8.0),),

          TextField(
            controller: countryTextController..text = country,
            focusNode: countryFocusNode,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'Country',
            hintText: '',
            suffixIcon: Icon(Icons.public),
            errorText: countryErrorText,
            ),
            onChanged: (value){
              setState(() {
                countryErrorText = null;
              });
            },
          ),
        ],
      );
    
    Widget _purpose = Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: sColor.withOpacity(0.7))
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Radio(
                    value: 'Official',
                    groupValue: _sPurpose,
                    activeColor: pColor,
                    onChanged: _getPurposeOfVisit,
                  ),
                  Text(
                    "Official",
                    style: _purposeStyle,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Radio(
                    value: 'Personal',
                    groupValue: _sPurpose,
                    activeColor: pColor,
                    onChanged: _getPurposeOfVisit,
                  ),
                  Text(
                    "Personal",
                    style: _purposeStyle,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Radio(
                    value: 'Delivery',
                    groupValue: _sPurpose,
                    activeColor: pColor,
                    onChanged: _getPurposeOfVisit,
                  ),
                  Text(
                    "Delivery",
                    style: _purposeStyle,
                  ),
                ],
              )
            ],),
        ),
        
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(purposeErrorText, 
            style: TextStyle(fontSize: 16.0, color: dColor),),
        )
      ],
    );
    
    final dateFormat = DateFormat("yyyy-MM-dd");
    final timeFormat = DateFormat("hh:mm a");
    Widget _date = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding: EdgeInsets.all(8.0),),

        DateTimeField(
          controller: dateTextController..text = dateOfVisit,
          focusNode: dateFocusNode,
          readOnly: true,
          format: dateFormat,
          resetIcon: null,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'Date',
            hintText: '',
            icon: Icon(Icons.date_range),
            errorText: dateErrorText,
            errorMaxLines: 10,
          ),
          onShowPicker: (context, currentValue) {
            return showDatePicker(
              context: context,
              firstDate: DateTime.now().subtract(Duration(days: 1)),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100),
              );
          },
          onChanged: (value){
            setState(() {
              dateErrorText = null;
            });
          },

        ),
        SizedBox(height: 24),

        DateTimeField(
          controller: timeTextController..text = timeOfVisit,
          focusNode: timeFocusNode,
          readOnly: true,
          format: timeFormat,
          resetIcon: null,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(18.0),
            border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
            labelText: 'Time',
            hintText: '',
            icon: Icon(Icons.watch_later),
            errorText: timeErrorText,
            errorMaxLines: 10,
          ),
          onShowPicker: (context, currentValue) async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.convert(time);
          },
          onChanged: (value){
            setState(() {
              timeErrorText = null;
            });
          },
        ),
        SizedBox(height: 24),
      ],
    );


    _steps = [
      Step(
        title: Text("Name", 
        style: _step == 0 ? _stepTitleStyleActive : _stepTitleStyleInactive),
        content: _name,
        isActive: _step == 0
      ),
      Step(
        title: Text("Contact",
        style: _step == 1 ? _stepTitleStyleActive : _stepTitleStyleInactive),
        content: _contact,
        isActive: _step == 1
      ),
      Step(
        title: Text("Addrress",
        style: _step == 2 ? _stepTitleStyleActive : _stepTitleStyleInactive),
        content: _address,
        isActive: _step == 2
      ),
      Step(
        title: Text("Purpose of visit",
        style: _step == 3 ? _stepTitleStyleActive : _stepTitleStyleInactive),
        content: _purpose,
        isActive: _step == 3
      ),
      Step(
        title: Text("Date and Time of visit",
        style: _step == 4 ? _stepTitleStyleActive : _stepTitleStyleInactive),
        content: _date,
        isActive: _step == 4
      ),
    ];

    Widget _details = Column(
      children: <Widget>[
        Row(
          children: <Widget>[
          Icon(Icons.person_outline, size: iconSize, color: iconColor,),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),),
          Text('$firstName $lastName', 
            style: _detailStyle,)
        ],),
        Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),

        Row(children: <Widget>[
          Icon(Icons.call, size: iconSize, color: iconColor,),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),),
          Text('$_countryCode $phoneNumber', 
            style: _detailStyle,)
        ],),
        Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),

        Row(children: <Widget>[
          Icon(Icons.alternate_email, size: iconSize, color: iconColor,),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),),
          Flexible(
            child: Text('$email', 
            style: _detailStyle,),
          )
        ],),
        Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),

        Row(children: <Widget>[
          Icon(Icons.home, size: iconSize, color: iconColor,),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),),
          Flexible(
            child: Text('$address, $state, $country', 
            style: _detailStyle,),
          )
        ],),
        Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),

        Row(children: <Widget>[
          Icon(Icons.date_range, size: iconSize, color: iconColor,),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),),
          Flexible(
            child: Text('$dateOfVisit', 
            style: _detailStyle,),
          )
        ],),
        Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),

        Row(children: <Widget>[
          Icon(Icons.watch_later, size: iconSize, color: iconColor,),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),),
          Flexible(
            child: Text('$timeOfVisit', 
            style: _detailStyle,),
          )
        ],),
        Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),


        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
          Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),),
          Flexible(
            child: Text('$_vPurpose', 
            style: TextStyle(
              fontSize: 16.0,
              color: oColor
            ),),
          )
        ],),
        

      ],);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1.0,
        title: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Text(vistocodeGenerated ? 'Visitor Details' : confirm ? 'Confirm Details' : "Enter the Visitor details", 
                      textAlign: confirm ? TextAlign.center : TextAlign.left,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700, 
                        color: Colors.white),),
        ),
        backgroundColor: _selectVisitor ? sColor.withOpacity(0.1) : pColor,
        iconTheme: IconThemeData(color: Colors.white),
        
      ),
      body: 
      _blank ? Padding(padding: EdgeInsets.all(0.0)) :
      _visitorDetailsSaved ? 
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaHeight(context)*0.1, vertical: mediaWidth(context)*0.2),
            child: Column(
                children: <Widget>[
                  Icon(_visitorDetailsSavedIcon, 
                    size: 100.0, 
                    color: _visitorDetailsSavedIconColor,),
                  
                  Padding(padding: EdgeInsets.all(8.0),),
                  
                  Text(_visitorDetailsSavedMessage,
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      fontSize: 14.0, 
                      color: sColor),)
                ],),
            ):
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: ListView(
              shrinkWrap: true,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                vistocodeGenerated || confirm ? Padding(
                  padding: EdgeInsets.fromLTRB(38.0, mediaHeight(context)*0.02, 38.0, 28.0),
                  child: Text(vistocodeGenerated ? '' : confirm ? '' : '', 
                    textAlign: confirm ? TextAlign.center : TextAlign.left,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700, 
                      color: confirm ? pColor : sColor),),
                ) :Padding(padding: EdgeInsets.all(0.0),),

                confirm ? Padding(padding: EdgeInsets.all(0.0),): 
                Stepper(
                  physics: ClampingScrollPhysics(),
                  currentStep: _step,
                  // onStepTapped: (step) {
                  //   setState(() {
                  //     _step = step;
                  //   });
                  // },
                  onStepContinue: _checkInputs,
                  onStepCancel: _previousStep,
                  controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                    return Padding(
                      padding: EdgeInsets.only(top: 20.0, right: 8.0, left: 30.0),
                      child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  _step != 0 ? InkWell(
                                    child: Text('Back', 
                                      style: TextStyle(
                                        fontSize: 16.0, 
                                        color: sColor),),
                                    onTap: onStepCancel,   
                                  ):Padding(padding: EdgeInsets.all(0.0),),

                                  ButtonTheme(
                                    minWidth: mediaWidth(context)*0.4,
                                    child: RaisedButton(
                                      color: pColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                          child: Text(_step == _steps.length - 1 ? 'Done' : 'Next',
                                            style: TextStyle(
                                              fontSize: 20.0, 
                                              color: Colors.white),
                                          ),
                                        ),
                                      onPressed: onStepContinue
                                      ),
                                    ),
                                  ],
                                ),
                    );
                      },
                    steps: _steps,
                  ),
                  
                  confirm ? Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Card(
                          color: sColor,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              children: <Widget>[
                                _details,
                              ],
                            ),
                          ),
                        ),
                        generating ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(10.0),),

                            CircularProgressIndicator(
                              backgroundColor: sColor,
                              valueColor: AlwaysStoppedAnimation<Color>(pColor),
                            ),
                                          
                            Padding(padding: EdgeInsets.all(10.0),),

                            Text(_generatingMessage,
                              textAlign: TextAlign.center,
                                style: TextStyle(
                                fontSize: 14.0,
                                color: sColor),),
                          ],
                        ):
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Column(
                            children: <Widget>[
                              vistocodeGenerated ? Column(
                                  children: <Widget>[
                                    Text(_vcgsMessage, 
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.0, 
                                        color:sColor),),
                                    Padding(padding: EdgeInsets.all(5.0),),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text('Vistocode:   ', 
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.0, 
                                            color:sColor,
                                            fontWeight: FontWeight.bold),),
                                        Text('$_myVistocode', 
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20.0, 
                                            color:pColor, 
                                            fontWeight: FontWeight.bold),)
                                      ],
                                    ),



                                  ],) :Padding(padding: EdgeInsets.all(0.0),),
                                generateError ? Column(
                                  children: <Widget>[
                                    Text(_generateErrorText, 
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.0, 
                                        color:dColor),)

                                  ],) :Padding(padding: EdgeInsets.all(0.0),),
                              Padding(padding: EdgeInsets.all(18.0),),

                              Row(
                                mainAxisAlignment: vistocodeGenerated && _enableSave ? MainAxisAlignment.center : MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                      child: Text(vistocodeGenerated ? (_enableSave ? '' : 'Close') : 'Back', 
                                        style: TextStyle(
                                          fontSize: 16.0, 
                                          color: sColor),),
                                          onTap: vistocodeGenerated ? _smsDialog : _editDetails,   
                                    ),

                                    ButtonTheme(
                                      minWidth: mediaWidth(context)*0.5,
                                        child: RaisedButton(
                                          color: pColor,
                                          shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                              child: Text(vistocodeGenerated ? (_enableSave ? 'Close' : 'Save Details' ) : 'Generate Code',
                                                style: TextStyle(
                                                  fontSize: 20.0, 
                                                  color: Colors.white),
                                              ),
                                            ),
                                          onPressed:  (){
                                            setState(() {
                                              generating = true;
                                              _generatingMessage = vistocodeGenerated ? (_enableSave ?  '' : 'Saving visitor details...') : 'Generating Code...';
                                              vistocodeGenerated ? _enableSave ? _smsDialog() : saveDetails() : checkEmail(email);
                                            });

                                          }
                                          
                                        ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          ),
                      ],
                    ),
                  ):Padding(padding: EdgeInsets.all(0.0),),
              
              ],
          ),
      ),

      bottomNavigationBar: _selectVisitor || visitorsDetails.length == 0 || confirm || vistocodeGenerated ? null : 
      BottomAppBar(
        // elevation: 1.0,
        color: sColor,
        child: InkWell(
          child: Container(
            width: mediaWidth(context),
            height: 55.0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('or Select from list', 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 18.0, 
                      fontWeight: FontWeight.bold),
                  ),

                  Icon(
                    Icons.chevron_right, 
                    size: 20.0, 
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),

          onTap: (){
            _showModalSheet();
            // setState(() {
            //   _selectVisitor = true;
            // });
          }
        ),

      )
    );
  }
}




