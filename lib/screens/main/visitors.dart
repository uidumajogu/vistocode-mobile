import 'package:flutter/material.dart';
import 'package:vistocode/common/functions.dart';
import 'package:vistocode/common/variables.dart';
import 'package:vistocode/screens/main/active.dart';

List<Widget> _visitorsCards;
Color _iconColor;
double _iconSize;
List _visitorsDetails;

class VisitorsListScreen extends StatefulWidget {
  @override
  _VisitorsListScreenState createState() => _VisitorsListScreenState();
}

class _VisitorsListScreenState extends State<VisitorsListScreen> {

  _confirmVisitorDelete(visitor) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete details?',
          style: TextStyle(
            fontSize: 18.0, 
            color: dColor, 
            fontWeight: FontWeight.bold),),
        content: Text(
          'This will delete the details of ${visitor['firstName']} ${visitor['lastName']} from your list.', 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0, 
              color: sColor),),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel',
              style: TextStyle(
                fontSize: 16.0, 
                color: pColor, 
                fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Delete',
              style: TextStyle(
                fontSize: 16.0, 
                color: dColor, 
                fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                _deleteVisitorDetails(visitor);
              });
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

  _deleteVisitorDetails(visitor){
    _visitorsDetails.remove(visitor);
  }

  @override
  void initState() {
    super.initState();
    _visitorsCards = new List<Widget>();
    _visitorsDetails = new List();
    _visitorsDetails = List.from(visitorsDetails);
    _iconColor = sColor.withOpacity(0.7);
    _iconSize = 12.0;
  }

  @override
  void dispose() {
    super.dispose();
    if(!unOrdDeepEq(_visitorsDetails, visitorsDetails)){
      updateVisitorDetails(userData['docID'], _visitorsDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    Iterable _inReverse = _visitorsDetails.reversed;
    var _visitorsDetailsInReverse = _inReverse.toList();
    _visitorsCards = new List<Widget>();
    _iconColor = sColor.withOpacity(0.3);
    _iconSize = 16.0;
    _visitorsDetailsInReverse.forEach((visitor){
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
                      children: <Widget>[
                        Icon(
                            Icons.brightness_1, 
                            color: visitor['active'] ? aColor : pColor),
                        Padding(padding: EdgeInsets.all(5.0),),
                        Text('${visitor['firstName']} ${visitor['lastName']}', 
                          style: TextStyle(
                            fontSize: 16.0, 
                            color: visitor['active'] ? aColor : pColor, 
                            fontWeight: FontWeight.bold),),
                      ],
                    ),
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

                        // visitor['active'] ? 
                        Text(visitor['active'] ? '${visitor['vistocode']}' : 'INACTIVE',
                          style: TextStyle(
                          fontSize: 14.0, 
                          color: visitor['active'] ? aColor : pColor,
                          fontWeight: FontWeight.bold),) 
                          // :
                        // Row(
                        //   children: <Widget>[
                        //     Icon(Icons.account_box, color: sColor,),
                        //     Icon(Icons.pause, color: sColor,)
                        //   ],),
                      ],
                    ),

                    Padding(padding: EdgeInsets.all(2.0),),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(visitor['active'] ? 'Cancel appointment' : 'Delete from list',
                          textAlign: TextAlign.end, 
                          style: TextStyle(
                            fontSize: 10.0, 
                            color: visitor['active'] ? pColor : dColor,
                            fontWeight: FontWeight.bold),),
                      ],
                    )
                  ],
                ),
              ) ,),
          ),

          onTap: ()=>visitor['active'] ? openScreenInModal(context, new ActiveVisitorsScreen()) : _confirmVisitorDelete(visitor),
        )
      );
      });


    return Scaffold(
      backgroundColor: bColor,
      appBar: AppBar(
        // elevation: 0.0,
        backgroundColor: sColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Your saved visitor details',
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
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Text('You do not have any visitor details saved', 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0, 
                      color: sColor),),
                ),
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