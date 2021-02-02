import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram/utilities/constants.dart';

class AuthService{

  static void signUpUser( BuildContext context, String name, String email, String password) async{
    try{
      AuthResult authResult = await auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser signedInUser = authResult.user;
      if( signedInUser != null){
         usersRef.document(signedInUser.uid).setData({
           'email': email,
           'name': name,
            'profileImageUrl': '',
         });
        Navigator.pop(context);
      }
    }catch(e){
      print(e);
    }
  }

  static void logout() {
     auth.signOut();
  }

  static void login(String email, String password) async{
    try{
      await auth.signInWithEmailAndPassword(email: email, password: password);
    }catch(e){
      print(e);
    }
  }
}