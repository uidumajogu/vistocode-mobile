import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vistocode/common/functions.dart';
import 'package:vistocode/common/variables.dart';


String nPwdErrorText;
String cPwdErrorText;
String newPassword = '';
String confirmedPassword = '';
String pwdErrorText = '';
bool _loading = false;
String _loadingMessage = '';
bool _passwordChanged = false;
bool _defaultPassword = false;

TextEditingController nPwdTextController = TextEditingController();
TextEditingController cPwdTextController = TextEditingController();
FocusNode nPwdFocusNode = new FocusNode();
FocusNode cPwdFocusNode = new FocusNode();

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {


  _pwdListener() {
    newPassword = nPwdTextController.text;
    confirmedPassword = cPwdTextController.text;
  }

  _focusListener() {
  }

  bool _validatePasswordChange(BuildContext c) {

    if(!validatePassword(newPassword)){
      nPwdErrorText = 'password must be at least 6 characters';
    }

    if(newPassword != confirmedPassword){
      cPwdErrorText = 'password is not the same';
    }

    if(validatePassword(newPassword) && (newPassword == confirmedPassword)){
      return true;
    } else {
      _loading = false;
      return false;
    }
  }


  void _changePassword(BuildContext c) async{
    
    FirebaseUser _user = await auth.currentUser();
    _defaultPassword = userData['defaultPassword'];
    try {
      await _user.updatePassword(newPassword);
      firestore.collection('vistocodeUsers').document(_user.uid)
      .updateData({
          'defaultPassword': false,
          'sku': '',
      }).then((data){
          setState(() {
            _loading = false;
            _passwordChanged = true;
          });

          Timer(Duration(seconds: 3), () {
            _passwordChanged = false;
            _defaultPassword ? replaceWithScreenNamed(c, 'WelcomeScreen'):
              replaceWithScreenNamed(c, 'HomeScreen');
            
          });
      }).catchError((error){
        pwdErrorText = error.message;
        _loading = false;
      });

    } catch (e) {
      setState(() {
        pwdErrorText = e.message;
        _loading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    nPwdTextController.addListener(_pwdListener);
    cPwdTextController.addListener(_pwdListener);
    nPwdFocusNode.addListener(_focusListener);
    cPwdFocusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    super.dispose();
    nPwdTextController.dispose();
    cPwdTextController.dispose();
    nPwdFocusNode.dispose();
    cPwdFocusNode.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 1],
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),

              ],
            ),
        ),
        child: Padding(
          padding: EdgeInsets.all(22.0),
          child: _passwordChanged ? 
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mediaHeight(context)*0.1, vertical: mediaWidth(context)*0.2),
            child: Column(
                children: <Widget>[
                  Icon(Icons.check, 
                    size: 100.0, 
                    color: pColor,),
                  
                  Padding(padding: EdgeInsets.all(8.0),),
                  
                  Text('You have successfully changed your password',
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
                      padding: EdgeInsets.only(top: mediaHeight(context)*0.1, bottom: mediaHeight(context)*0.05),
                        child: Text('Change Password', 
                          style: TextStyle(
                            fontSize: 22.0, 
                            color: sColor, 
                            fontWeight: FontWeight.bold),
                        ),
                    ),

                    TextField(
                      controller: nPwdTextController,
                      focusNode: nPwdFocusNode,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(18.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: 'New Password',
                        suffixIcon: Icon(Icons.lock_outline),
                        errorText: nPwdErrorText
                      ),
                      onChanged: (value){
                        setState(() {
                          nPwdErrorText = null;
                          pwdErrorText = '';
                        });
                        },
                    ),
                    Padding(padding: EdgeInsets.all(8.0),),

                    TextField(
                      controller: cPwdTextController,
                      focusNode: cPwdFocusNode,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(18.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: 'Confirm New Password',
                        hintText: '',
                        suffixIcon: Icon(Icons.lock_outline),
                        errorText: cPwdErrorText,
                      ),
                      onChanged: (value){
                        setState(() {
                          cPwdErrorText = null;
                          pwdErrorText = '';
                        });
                        },
                    ),
                    Padding(padding: EdgeInsets.all(8.0),),


                    pwdErrorText == '' ?
                    Padding(
                      padding: EdgeInsets.all(0),
                    ):
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical:8.0, horizontal: 50.0),
                      child: Text(pwdErrorText,
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
                          padding: const EdgeInsets.all(12.0),
                          child: Text('Change',
                            style: TextStyle(fontSize: 24.0, color: Colors.white),
                            ),
                        ),
                        onPressed: () {
                          nPwdFocusNode.unfocus();
                          cPwdFocusNode.unfocus();
                          _loading = true;
                          _loadingMessage = 'Changing Password...';
                          cPwdErrorText = null;
                          pwdErrorText = '';
                          if(_validatePasswordChange(context)){
                            setState(() {
                            _changePassword(context);
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