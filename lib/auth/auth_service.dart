import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:letters/models/user.dart" as i;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Reference _storeRef = FirebaseStorage.instance.ref();
  final CollectionReference _ref =
      FirebaseFirestore.instance.collection("Users");

  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await OneSignal.login(_auth.currentUser!.uid);
      await OneSignal.User.addTagWithKey("userId", _auth.currentUser!.uid);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    } catch (e) {
      rethrow;
    }
  }

  User? getUser() {
    return _auth.currentUser;
  }

  Future<i.User> getUserInfo() async {
    QuerySnapshot<Object?> snapshot = await _ref
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();

    QueryDocumentSnapshot<Object?> doc = snapshot.docs[0];
    return i.User(
        id: doc.id,
        name: doc["name"],
        email: doc["email"],
        imgUrl: doc["imgUrl"],
        bio: doc["bio"]);
  }

  Future<void> updateUser(
      String id, String name, String bio, String path) async {
    final String uniqueName = _auth.currentUser!.uid.toString();
    Reference refImg = _storeRef.child("profile images");
    Reference refImgUplaod = refImg.child(uniqueName);
    await refImgUplaod.putFile(File(path));
    String imgUrl = await refImgUplaod.getDownloadURL();
    i.User a = i.User(
      name: name,
      bio: bio,
      id: _auth.currentUser!.uid,
      imgUrl: imgUrl,
      email: FirebaseAuth.instance.currentUser!.email.toString(),
    );
    await _ref.doc(id).set(a.toMap());
  }

  Future<UserCredential> signUpWithEmailandPassword(
      String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _firestore
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({"id": userCredential.user!.uid, "name": name, "email": email});
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> deleteUser() async {
    try {
      final String currentUserID = _auth.currentUser!.uid;
      CollectionReference s = _firestore.collection("chat_room");
      await s.where("users", arrayContains: currentUserID).get().then((value) {
        for (DocumentSnapshot ds in value.docs) {
          ds.reference.collection("Messages").get().then((values) {
            for (DocumentSnapshot dsa in values.docs) {
              dsa.reference.delete();
            }
          });
          ds.reference.delete();
        }
      });
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData =
          FirebaseAuth.instance.currentUser!.providerData.first;

      if (AppleAuthProvider().providerId == providerData.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }

      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Handle exceptions
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
