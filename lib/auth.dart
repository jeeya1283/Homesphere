import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? googleUser;

  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow

    googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {}
    googleUser ??= await _googleSignIn.signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    var result = await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = result.user;
    debugPrint((credential.idToken));

    await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
      'firstname': user?.displayName,
      'lastname': '',
      'email': user?.email,
      'phoneNumber':user?.phoneNumber ?? '',
    });
    // Once signed in, return the UserCredential
    return result;
  }
}