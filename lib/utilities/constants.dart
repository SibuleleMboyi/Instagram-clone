import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final auth = FirebaseAuth.instance;
final firestore = Firestore.instance;
final usersRef = firestore.collection('users');
final storageRef = FirebaseStorage.instance.ref();
final postsRef = firestore.collection('posts');