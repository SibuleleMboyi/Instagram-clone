import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;
final firestore = Firestore.instance;
final usersRef = firestore.collection('users');