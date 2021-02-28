import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final auth = FirebaseAuth.instance;
final firestore = Firestore.instance;
final storageRef = FirebaseStorage.instance.ref();
final usersRef = firestore.collection('users');
final postsRef = firestore.collection('posts');
final followersRef = firestore.collection('followers');
final followingRef = firestore.collection('following');
final feedsRef = firestore.collection('feeds');
final likesRef = firestore.collection('likes');