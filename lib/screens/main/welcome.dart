import 'package:flutter/material.dart';
import 'package:vistocode/common/functions.dart';
import 'package:vistocode/common/variables.dart';
import 'package:vistocode/screens/auth/login.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: pColor),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome ' + userData['fullName'].split(" ")[0] + '!', 
              style: TextStyle(
                fontSize: 24.0, 
                color: pColor, 
                fontWeight: FontWeight.bold),),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 38.0, horizontal: 40.0),
              child: Text('Generate code for your visitors to ' + 
              userData['businessName'] + ' for seamless authentication', 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),),
            ),

              Padding(
                padding: EdgeInsets.only(top: mediaHeight(context)*0.05, bottom: mediaHeight(context)*0.05),
                child: Image.asset('assets/images/welcomeImg.png', scale: 2.8,),
              ),

            ButtonTheme(
              minWidth: mediaWidth(context),
              child: RaisedButton(
                color: pColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                    child: Text('Start',
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                  ),
              onPressed: (){
                setState(() {
                  replaceWithScreenNamed(context, 'HomeScreen');
                });
              },
              ),
            )
          ],
        ),
      ),
    );
  }
}