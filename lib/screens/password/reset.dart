import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vistocode/common/functions.dart';
import 'package:vistocode/common/variables.dart';


String _emailErrorText;
String _emailError;
String _email;
bool _loading;
String _loadingMessage;
bool _resetSent;

TextEditingController _emailTextController;
FocusNode _emailFocusNode;

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  _emailListener() {
    _email = _emailTextController.text;
  }

  _focusListener() {
  }

  bool _validateEmail() {
    if(validateEmail(_email)){
      return true;
    } else {
      _emailErrorText = 'Email is invalid';
      _loading = false;
      return false;
    }
  }

  Future<void>  _resetPassword(String email) async{
    
    try {
      await auth.sendPasswordResetEmail(email: email);
      setState(() {
        _resetSent = true;
        _loading = false;
      });

      Timer(Duration(seconds: 4), () {
            _resetSent = false;
            Navigator.pop(context);
          });

    } catch (e) {
      setState(() {
        _emailError = e.message;
        _loading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _emailTextController = TextEditingController();
    _emailFocusNode = FocusNode();
    _email = '';
    _emailError = '';
    _loading = false;
    _loadingMessage = '';
    _resetSent = false;
    _emailTextController.addListener(_emailListener);
    _emailFocusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    super.dispose();
    _emailTextController.dispose();
    _emailFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: pColor),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(22.0),
          child: _resetSent ? 
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaWidth(context)*0.1),
            child: Column(
                children: <Widget>[
                  Icon(Icons.check, 
                    size: 100.0, 
                    color: pColor,),
                  
                  Padding(padding: EdgeInsets.all(8.0),),
                  
                  Text('A password reset link has been sent to $_email. Follow the link to reset your password.',
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      fontSize: 14.0, 
                      color: sColor),)
                ],),
            ):
              
              Container(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: mediaHeight(context)*0.05, bottom: mediaHeight(context)*0.05),
                        child: Text('Enter your email to reset password', 
                          style: TextStyle(
                            fontSize: 22.0, 
                            color: sColor, 
                            fontWeight: FontWeight.bold),
                        ),
                    ),

                    TextField(
                      controller: _emailTextController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(18.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: 'Email',
                        hintText: 'me@example.com',
                        suffixIcon: Icon(Icons.alternate_email),
                        errorText: _emailErrorText
                      ),
                      onChanged: (value){
                        setState(() {
                          _emailErrorText = null;
                          _emailError = '';
                        });
                      },
                    ),


                    _emailError == '' ?
                    Padding(
                      padding: EdgeInsets.all(0),
                    ):
                    Padding(
                      padding: EdgeInsets.symmetric(vertical:8.0, horizontal: 50.0),
                      child: Text(_emailError,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.0, 
                            color: dColor),),
                    ),
                    Padding(padding: EdgeInsets.all(12.0),),
                    
                    _loading ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(
                          backgroundColor: sColor,
                          valueColor: AlwaysStoppedAnimation<Color>(pColor),
                        ),
                        
                        Padding(padding: EdgeInsets.all(10.0),),

                        Text(_loadingMessage, 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: sColor),),
                      ],
                      ):
                    ButtonTheme(
                      minWidth: mediaWidth(context),
                      child: RaisedButton(
                        color: pColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Reset Password',
                            style: TextStyle(fontSize: 22.0, color: Colors.white),
                            ),
                        ),
                        onPressed: () {
                          _emailFocusNode.unfocus();
                          _loading = true;
                          _loadingMessage = 'Sending Password Reset Link...';
                          _emailErrorText = null;
                          _emailError = '';
                          if(_validateEmail()){
                            setState(() {
                            _resetPassword(_email);
                           }); 
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
      
    );
  }
}