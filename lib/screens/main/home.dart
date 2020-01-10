import 'package:flutter/material.dart';
import 'package:vistocode/common/functions.dart';
import 'package:vistocode/common/variables.dart';
import 'package:simple_animations/simple_animations.dart';

int _activeVisitors;
int _allVisitors;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  _getVisitorCount(){
    _activeVisitors = 0;
    _allVisitors = 0;
    if(visitorsDetails.isNotEmpty){
      visitorsDetails.forEach((visitor){
        _allVisitors++;
        if(visitor['active']){
          _activeVisitors++;
        }
      });
    } else {
      _activeVisitors = 0;
      _allVisitors = 0;
    }
  }


  @override
  void initState() {
    super.initState();
    _activeVisitors = 0;
    _allVisitors = 0;
    _getVisitorCount();
  }

  @override
  Widget build(BuildContext context) {
    _getVisitorCount();

    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 1),
          ColorTween(begin: sColor.withOpacity(0.0), end: pColor.withOpacity(0.5))),
      Track("color2").add(Duration(seconds: 1),
          ColorTween(begin: sColor.withOpacity(0.0), end: pColor.withOpacity(0.5)))
    ]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: pColor),
      ),
      body: Container(
        width: mediaWidth(context),
        height: mediaHeight(context),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.all(50.0),),
          Text('Tap to generate Vistocode', 
            style: TextStyle(
              fontSize: 20.0, 
              color: sColor),),
          Padding(padding: EdgeInsets.all(12.0),),
              InkWell(
                borderRadius: BorderRadius.all(Radius.circular(100.0)),
                child: Stack(
                  children: <Widget>[
                    ControlledAnimation(
                      playback: Playback.MIRROR,
                      tween: tween,
                      duration: tween.duration,
                      builder: (context, animation) {
                        return Container(
                          height: 210.0,
                          width: 210.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // color: animation["color1"],
                              gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.center,
                                  colors: [animation["color1"], animation["color2"]])
                                  ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Image.asset('assets/images/homeLogo.png', scale: 6.1,),
                    ),
                  ],),
                onTap: ()=>
                // launchSMS('+2348022850200'),
                pushScreenNamed(context,'GenerateScreen'),
              ),
        ],
          ),
      ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0.0,
          child: Padding(
            padding: EdgeInsets.only(bottom: 50.0,),
            child: Container(
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(color: bColor),
                borderRadius: BorderRadius.all(Radius.circular(50.0))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            padding: EdgeInsets.all(0.0),
                            icon: Icon(
                              Icons.view_list, 
                              color: sColor.withOpacity(0.5), 
                              size: 50.0,),
                            onPressed: ()=> pushScreenNamed(context,'VisitorsListScreen'),
                          ),
                          Text(_allVisitors.toString(), 
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold, 
                              color: _allVisitors == 0 ? sColor : pColor), )
                        ],
                      ),
                      Text('Saved', 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.0, 
                          color: sColor, 
                          fontWeight: FontWeight.bold),)
                    ],
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            padding: EdgeInsets.all(0.0),
                            icon: Icon(
                              Icons.account_circle, 
                              color: sColor.withOpacity(0.5), 
                              size: 50.0,),
                            onPressed: ()=> pushScreenNamed(context,'ActiveVisitorsScreen'),
                          ),
                          Text(_activeVisitors.toString(), 
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold, 
                              color: _activeVisitors == 0 ? sColor : pColor), )
                        ],
                      ),
                      Text('Expected', 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.0, 
                          color: sColor, 
                          fontWeight: FontWeight.bold),)
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}