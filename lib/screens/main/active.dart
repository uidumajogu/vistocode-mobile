import 'package:flutter/material.dart';
import 'package:vistocode/common/functions.dart';
import 'package:vistocode/common/variables.dart';
import 'package:vistocode/main.dart';

List<Widget> _visitorsCards;
Color _iconColor;
double _iconSize;
List _visitorsDetails;
bool _apmtCancel;
bool _cancelledApmt;


class ActiveVisitorsScreen extends StatefulWidget {
  @override
  _ActiveVisitorsScreenState createState() => _ActiveVisitorsScreenState();
}

class _ActiveVisitorsScreenState extends State<ActiveVisitorsScreen> {

  Future<void> _cancelSpecificNotification(visitor) async {
    await flutterLocalNotificationsPlugin.cancel(visitor['notification'][0]);
    await flutterLocalNotificationsPlugin.cancel(visitor['notification'][1]);
    await flutterLocalNotificationsPlugin.cancel(visitor['notification'][2]);
  }

  _updateVisitorDetails(visitor){
    _cancelledApmt = true;
    _visitorsDetails.forEach((v){
      if (v == visitor){
        v['active'] = false;
        _cancelSpecificNotification(v);
      }
    });
    _apmtCancel = true;
    Navigator.of(context).pop();
    _cancelApmtDialog(visitor);
  }

  _closeCancelDialog(){
    _apmtCancel = false;
    Navigator.of(context).pop();
  }

  _cancelApmtDialog(visitor){ 
    showDialog(
      context: context,
      barrierDismissible: !_apmtCancel,
      builder: (_)=>Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(18.0),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(8.0),),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      _apmtCancel ? "The appointment for ${visitor['firstName']} ${visitor['lastName']} has been canceled." :
                      "This action will cancel the appointment for ${visitor['firstName']} ${visitor['lastName']}.",
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
                          child: Text('Close', 
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
                                child: Text(_apmtCancel ? 'Close' : 'Continue',
                                  style: TextStyle(
                                  fontSize: 20.0, 
                                  color: Colors.white),
                                ),
                              ),
                            onPressed:  (){
                              setState(() {
                                _apmtCancel ? _closeCancelDialog() : 
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


  @override
  void initState() {
    super.initState();
    _visitorsDetails = new List();
    _visitorsCards = new List<Widget>();
    _visitorsDetails = List.from(visitorsDetails);
    _iconColor = sColor.withOpacity(0.7);
    _iconSize = 12.0;
    _apmtCancel = false;
    _cancelledApmt = false;
  }

  @override
  void dispose() {
    super.dispose();
    if(_cancelledApmt){
      cancelVisitorAppointment(userData['ID'], userData['docID'], _visitorsDetails);
    }
  }


  @override
  Widget build(BuildContext context) {

    Iterable inReverse = _visitorsDetails.reversed;
    var visitorsDetailsInReverse = inReverse.toList();
    _visitorsCards = new List<Widget>();
    _iconColor = sColor.withOpacity(0.3);
    _iconSize = 16.0;
    visitorsDetailsInReverse.forEach((visitor){
      if(visitor['active']){
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
                    Text('${visitor['firstName']} ${visitor['lastName']}', 
                      style: TextStyle(
                        fontSize: 16.0, 
                        color: pColor, 
                        fontWeight: FontWeight.bold),),
                    Padding(padding: EdgeInsets.all(8.0),),

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

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      child: Divider(height: 5.0, color: sColor,),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${visitor['dateOfVisit']} ${visitor['timeOfVisit']}',
                          style: TextStyle(
                          fontSize: 12.0, 
                          color: sColor,),),

                        Text('${visitor['vistocode']}',
                          style: TextStyle(
                          fontSize: 14.0, 
                          color: pColor,
                          fontWeight: FontWeight.bold),),
                        // Padding(padding: EdgeInsets.only(right: 10.0),),
                      ],
                    ),

                    Padding(padding: EdgeInsets.all(2.0),),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Cancel appointment',
                          textAlign: TextAlign.end, 
                          style: TextStyle(
                            fontSize: 10.0, 
                            color: dColor,
                            fontWeight: FontWeight.bold),),
                      ],
                    )
                  ],
                ),
              ) ,),
          ),

          onTap: ()=>_cancelApmtDialog(visitor),
        )
      );
      }

      });



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // elevation: 0.0,
        backgroundColor: pColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(_visitorsCards.length < 2 ? 'Expected visitor' : 'Expected visitors', 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 20.0, 
                  fontWeight: FontWeight.bold),),
      ),
      body: Container(
        height: mediaHeight(context),
        width: mediaWidth(context),
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        color: sColor.withOpacity(0.1),
        child: _visitorsCards.length == 0 ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('No expected visitors', 
                  style: TextStyle(
                    fontSize: 18.0, 
                    color: sColor),),
                Padding(padding: EdgeInsets.only(top:22.0)),
                Image.asset('assets/images/empty.png', scale: 4.3,),
              ],
            ) : 
        
        ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top:22.0)),
            Column(
              children: _visitorsCards,
            ),
          ],
        ),
      ),
      
    );
  }
}