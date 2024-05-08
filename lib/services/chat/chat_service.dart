import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:letters/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Reference _ref = FirebaseStorage.instance.ref();

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future getTheme(String receiverId) async {
    final String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatRoomID = ids.join("_");
    return await _firestore.collection("chat_room").doc(chatRoomID);
  }

  Future getUser(String id) async {
    return await _firestore
        .collection("Users")
        .where("uid", isEqualTo: id)
        .snapshots()
        .first;
  }

  Stream<List<String>> getActiveChats() {
    return _firestore
        .collection("chat_room")
        .where("users", arrayContains: _auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        List userId = user["users"];
        userId.remove(_auth.currentUser!.uid);
        String a = userId[0];
        return a;
      }).toList();
    });
  }

  Future<void> deleteChat(String receiverID) async {
    final String currentUserID = _auth.currentUser!.uid;
    CollectionReference s = _firestore.collection("chat_room");
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    await s.doc(chatRoomID).collection("Messages").get().then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
    return await s.doc(chatRoomID).delete();
  }

  Stream<List<Map<String, dynamic>>> getCurrentUserStream(String email) {
    return _firestore
        .collection("Users")
        .where("email", isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> createChatRoom(String receiverID) async {
    final String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    final a = _firestore.collection('chat_room').doc(chatRoomID);

    await a.get().then((value) => !value.exists
        ? a.set({"user": currentUserID, "otheruser": receiverID, "users": ids})
        : null);
  }

  Future<void> sendMessage(String receiverID, message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      isVoice: false,
      receiverID: receiverID,
      message: message,
      isImg: false,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
  }

  Future<void> sendImageMessage(String receiverID, String path) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    final String uniqueName =
        'Letters Image ${timestamp.microsecondsSinceEpoch.toString()}';
    Reference refImg = _ref.child("images");
    Reference refImgUplaod = refImg.child(uniqueName);
    await refImgUplaod.putFile(File(path));
    String imgUrl = await refImgUplaod.getDownloadURL();
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: imgUrl,
      isVoice: false,
      isImg: true,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
  }

  Future<void> sendVoiceMessage(String receiverID, String path) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    final String uniqueName =
        'Letters Voice ${timestamp.microsecondsSinceEpoch.toString()}.m4a';
    Reference refImg = _ref.child("voice");
    Reference refImgUplaod = refImg.child(uniqueName);
    await refImgUplaod.putFile(File(path));
    String url = await refImgUplaod.getDownloadURL();
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: url,
      isImg: false,
      isVoice: true,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");
    return _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .orderBy("timestamp")
        .snapshots();
  }
}
