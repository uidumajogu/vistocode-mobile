import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vistocode/common/functions.dart';
import 'package:vistocode/common/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


String emailErrorText;
String passwordErrorText;
String email;
String password;
String loginErrorText;
bool loading;
String loadingMessage;
bool _isloading;

TextEditingController emailTextController = TextEditingController();
TextEditingController pwdTextController = TextEditingController();
FocusNode emailFocusNode = new FocusNode();
FocusNode passwordFocusNode = new FocusNode();

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<FirebaseUser> currentUser() {
    return FirebaseAuth.instance.currentUser();
  }

  _updateUserData(user){
      firestore.collection('vistocodeUsers').document(user.uid)
        .get().then((doc) {
              updateUserData(doc);
                  getvisitorsDetails(doc['docID']).then((data){
                    loadingCleanUp();
                    if(doc['defaultPassword']){
                      replaceWithScreenNamed(context, 'ChangePasswordScreen');
                      _isloading = false;
                    } else {
                      replaceWithScreenNamed(context, 'HomeScreen');
                      _isloading = false;
                    } 
                });
        }).catchError ((e) {
      setState(() {
        loadingCleanUp();
        _isloading = false;
        loginErrorText = e.message;
      });
    });
  }

  textListener() {
    email = emailTextController.text;
    password = pwdTextController.text;
  }

  focusListener() {
  }

  bool validateInputs(BuildContext c) {
    if(!validateEmail(email)){
      emailErrorText = 'email is invalid';
    }

    if(!validatePassword(password)){
      passwordErrorText = 'password must be at least 6 characters';
    }

    if(validateEmail(email) && validatePassword(password)){
      return true;
    } else {
      loading = false;
      return false;
    }
  }

  loadingCleanUp(){
    loadingMessage = '';
    loading = false;
  }

  void loginUser(BuildContext c) async {
    try {
    FirebaseUser _user = await auth.signInWithEmailAndPassword(
      email: email, 
      password: password);
        setState(() {
          loadingMessage = 'Getting your profile...';
        });
        
        firestore.collection('vistocodeUsers').document(_user.uid)
        .get().then((doc) {
          firestore.collection('vistocodeUsers').document(_user.uid)
          .updateData({
              'lastUsedDate': DateFormat('yyyy-MM-dd HH:MM:SS').format(DateTime.now()),
          }).then((data){
              updateUserData(doc);
              updateOyaNa();
                  getvisitorsDetails(doc['docID']).then((data){
                  Timer(Duration(seconds: 1), () {
                    loadingCleanUp();
                    if(doc['defaultPassword']){
                      replaceWithScreenNamed(c, 'ChangePasswordScreen');
                    } else {
                      replaceWithScreenNamed(c, 'HomeScreen');
                    } 
                  });
                });

          }).catchError((error){
              loadingCleanUp();
              loginErrorText = error.message;
          });

        }).catchError ((e) {
      setState(() {
        loadingCleanUp();
        loginErrorText = e.message;
      });
    });
    } catch (e) {
      setState(() {
        loadingCleanUp();
        loginErrorText = e.message;
      });
    }


  }


  @override
  void initState() {
    super.initState();
    _isloading = true;
    FirebaseAuth.instance.currentUser().then((user){
      if(user != null){
        _updateUserData(user);
        updateOyaNa();
      }else{
        setState(() {
          _isloading = false;
        });
      }
      
    }).catchError((error){
        setState(() {
          _isloading = false;
        });
      print(error);
    });
    
    emailTextController.addListener(textListener);
    pwdTextController.addListener(textListener);
    emailFocusNode.addListener(focusListener);
    passwordFocusNode.addListener(focusListener);

    emailErrorText = null;
    passwordErrorText = null;
    email = '';
    password = '';
    loginErrorText = '';
    loading = false;
    loadingMessage = 'Authenticating...';
    oya = '';
    na = '';
  }

  @override
  void dispose() {
    super.dispose();
    emailTextController.dispose();
    pwdTextController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isloading ? null : AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: pColor),
      ),
      body: Container(
        width: mediaWidth(context),
        height: mediaHeight(context),
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
        child: Center(
                  child: _isloading ? 
                Stack(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Image.asset('assets/images/homeLogo.png', scale: 25.0,),
                      ),
                      SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          // backgroundColor: bColor,
                          valueColor: AlwaysStoppedAnimation<Color>(sColor.withOpacity(0.3)),
                        ),
                      )

                  ],):

          ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(22.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: mediaHeight(context)*0.03, bottom: mediaHeight(context)*0.05),
                      child: Image.asset('assets/images/nameLogo.png', scale: 4.0,),
                    ),

                    TextField(
                      controller: emailTextController,
                      focusNode: emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(18.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: 'Email',
                        hintText: 'me@example.com',
                        suffixIcon: Icon(Icons.alternate_email),
                        errorText: emailErrorText
                      ),
                      onChanged: (value){
                        setState(() {
                          emailErrorText = null;
                          loginErrorText = '';
                        });
                        },
                    ),
                    Padding(padding: EdgeInsets.all(8.0),),

                    TextField(
                      controller: pwdTextController,
                      focusNode: passwordFocusNode,
                      keyboardType: TextInputType.text,
                      
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(18.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                        labelText: 'Password',
                        hintText: '',
                        suffixIcon: Icon(Icons.lock_outline),
                        errorText: passwordErrorText,
                      ),
                      onChanged: (value){
                        setState(() {
                          passwordErrorText = null;
                          loginErrorText = '';
                        });
                        },
                    ),
                    Padding(padding: EdgeInsets.all(8.0),),


                    loginErrorText == '' ?
                    Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        child: Text('Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold, 
                                    color: sColor),),
                        splashColor: pColor,
                        focusColor: pColor,
                        onTap: ()=>pushScreenNamed(context,'ResetPasswordScreen'),
                      ),
                    ):
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical:8.0, horizontal: 50.0),
                      child: Text(loginErrorText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.0, 
                            color: dColor),),
                    ),
                    Padding(padding: EdgeInsets.all(12.0),),
                    
                    loading ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(
                          backgroundColor: sColor,
                          valueColor: AlwaysStoppedAnimation<Color>(pColor),
                        ),
                        
                        Padding(padding: EdgeInsets.all(10.0),),

                        Text(loadingMessage,
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
                          child: Text('Login',
                            style: TextStyle(fontSize: 24.0, color: Colors.white),
                            ),
                        ),
                        onPressed: () {
                          emailFocusNode.unfocus();
                          passwordFocusNode.unfocus();
                          loading = true;
                          loadingMessage = 'Authenticating...';
                          passwordErrorText = null;
                          loginErrorText = '';
                          setState(() {
                            if(validateInputs(context)){
                              loginUser(context);
                            }
                          });
                          },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}