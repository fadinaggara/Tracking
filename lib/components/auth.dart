import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadil_project/Screens/Login.dart';
import 'package:hadil_project/Screens/first_screen.dart';
import 'package:hadil_project/Screens/verifyEmail.dart';
import 'package:hadil_project/components/notif.dart';

Future<void> signOut(context) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  await auth.signOut();



  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => LoginPage()));
}
signUp(String email, String password,_formkey,context) async {

  FirebaseAuth _auth = FirebaseAuth.instance;

  if (_formkey.currentState.validate()) {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      ///Success
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => VerifyScreen()),
            (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar('please verify'));


    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(snackBar('user not found'));
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(snackBar('wrong password'));
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e);
    }
  }

}
Future VerifyEmail(email,context) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email
    );

    showTos("Reset email sent");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage())
    );
  } on FirebaseAuthException catch (e) {
    print(e);

    Navigator.of(context).pop();
  }
}
void signIn(String email, String password,_formkey,context) async {
  SnackBar snackBar(String txt){
    return SnackBar(
      content:  Text(txt),
    );
  }
  if (_formkey.currentState!.validate()) {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      ///Success
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => first_screen()),
            (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar('welcome'));


    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(snackBar('user not found'));

      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(snackBar('user not found'));

      }
    }
  }
  else{
    print('### input not validated');
  }

}