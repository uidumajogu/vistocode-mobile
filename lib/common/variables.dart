import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';


final FirebaseAuth auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;
Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;

Color pColor = Color(0xFFFDA203);
Color sColor = Color(0xFF687688);
Color tColor = Color(0xFF253061);
Color dColor = Color(0xFFFA5072);
Color oColor = Color(0xFFB3E8FF);
Color bColor = Color(0xFFEFEFEF);
Color aColor = Color(0xFF048518);

