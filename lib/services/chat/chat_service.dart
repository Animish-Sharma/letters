import 'dart:io';
import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import "package:http/http.dart" as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:letters/models/assistMessage.dart';
import 'package:letters/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Reference _ref = FirebaseStorage.instance.ref();

  Future<void> setMessageToSeen(String receiverID) async {
    final String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .where("receiverID", isEqualTo: currentUserID)
        .where("read", isEqualTo: false)
        .snapshots()
        .forEach((element) async {
      List<DocumentSnapshot> docs = element.docs;
      for (var doc in docs) {
        await doc.reference.update({"read": true});
      }
    });
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
        .orderBy("lastMessage", descending: true)
        .where("users", arrayContains: _auth.currentUser!.uid)
        .where("locked", isEqualTo: false)
        .where("pinned", isEqualTo: false)
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

  Stream<List<String>> getActivePinnedChats() {
    return _firestore
        .collection("chat_room")
        .orderBy("lastMessage", descending: true)
        .where("users", arrayContains: _auth.currentUser!.uid)
        .where("locked", isEqualTo: false)
        .where("pinned", isEqualTo: true)
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

  Stream<List<String>> getActiveLockedChats() {
    return _firestore
        .collection("chat_room")
        .orderBy("lastMessage", descending: true)
        .where("users", arrayContains: _auth.currentUser!.uid)
        .where("locked", isEqualTo: true)
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

  Future<void> deleteAssistantChat() async {
    CollectionReference s = _firestore.collection("assistant");
    await s
        .doc(_auth.currentUser!.uid)
        .collection("Messages")
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
    return await s.doc(_auth.currentUser!.uid).delete();
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

  Future<void> lastMessageSent(String chatRoomId, Timestamp time,
      String receiverID, String messageSent) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    List<String> users = [currentUserId, receiverID];
    users.sort();
    QuerySnapshot<Object?> snapshot = await _firestore
        .collection("chat_room")
        .where("users", isEqualTo: users)
        .get();
    QueryDocumentSnapshot<Object?> doc = snapshot.docs[0];

    await _firestore.collection("chat_room").doc(chatRoomId).set({
      "lastMessage": time,
      "user": currentUserId,
      "otheruser": receiverID,
      "users": users,
      "sentBy": currentUserId,
      "locked": doc["locked"],
      "pinned": doc["pinned"],
      "messageSent": messageSent
    });
  }

  Future<String> getLastMessage(String receiverID) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    List<String> users = [currentUserId, receiverID];
    users.sort();
    QuerySnapshot<Object?> snapshot = await _firestore
        .collection("chat_room")
        .where("users", isEqualTo: users)
        .get();
    QueryDocumentSnapshot<Object?> doc = snapshot.docs[0];
    return doc["messageSent"];
  }

  Future<bool> lastMessageSentByUser(String receiverID) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    List<String> users = [currentUserId, receiverID];
    users.sort();
    QuerySnapshot<Object?> snapshot = await _firestore
        .collection("chat_room")
        .where("users", isEqualTo: users)
        .get();
    QueryDocumentSnapshot<Object?> doc = snapshot.docs[0];
    return doc["sentBy"] as String != currentUserId ? false : true;
  }

  Future<void> createChatRoom(String receiverID) async {
    final String currentUserID = _auth.currentUser!.uid;
    List<String> ids = [currentUserID, receiverID];
    Timestamp time = Timestamp.now();
    ids.sort();
    String chatRoomID = ids.join("_");

    final a = _firestore.collection('chat_room').doc(chatRoomID);

    await a.get().then((value) => !value.exists
        ? a.set({
            "user": currentUserID,
            "otheruser": receiverID,
            "users": ids,
            "lastMessage": time,
            "pinned": false,
            "locked": false,
            "messageSent": "",
            "sentBy": currentUserID
          })
        : null);
  }

  Future<void> createAssistantRoom(String receiverID) async {
    final String currentUserID = _auth.currentUser!.uid;

    final a = _firestore.collection('assistant').doc(currentUserID);

    await a.get().then((value) => !value.exists
        ? a.set({
            "user": currentUserID,
          })
        : null);
  }

  Future<void> sendMessage(String receiverID, message, String repliedTo) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      read: false,
      senderEmail: currentUserEmail,
      isVoice: false,
      isVid: false,
      isMap: false,
      receiverID: receiverID,
      isDoc: false,
      message: message,
      isImg: false,
      repliedTo: repliedTo,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    await lastMessageSent(chatRoomID, timestamp, receiverID, message);
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
    await sendNotifications(receiverID, message);
  }

  Future<void> sendAssistantMessage(String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    AssistantMessage newAssistantMessage = AssistantMessage(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      message: message,
      timestamp: timestamp,
    );
    await _firestore
        .collection("assistant")
        .doc(currentUserID)
        .collection("Messages")
        .add(newAssistantMessage.toMap());
    await getAssistantResponse(message);
  }

  Future<void> getAssistantResponse(String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final assist = Gemini.instance;
    String? repMessage = "";
    await assist
        .text(message)
        .then((value) => print(repMessage = value?.output));
    AssistantMessage newAssistantMessage = AssistantMessage(
      senderID: "ASSISTANT",
      senderEmail: "ASSISTANT",
      message: repMessage!,
      timestamp: timestamp,
    );
    await _firestore
        .collection("assistant")
        .doc(currentUserID)
        .collection("Messages")
        .add(newAssistantMessage.toMap());
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
      read: false,
      isMap: false,
      isVid: false,
      receiverID: receiverID,
      repliedTo: "",
      message: imgUrl,
      isDoc: false,
      isVoice: false,
      isImg: true,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    await lastMessageSent(chatRoomID, timestamp, receiverID, "Image");
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
    await sendNotifications(receiverID, "Image");
  }

  Future<void> sendVideoMessage(
      String receiverID, String path, String fName) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    final String uniqueName =
        'Letters Video ${timestamp.microsecondsSinceEpoch.toString()}';
    Reference refImg = _ref.child("videos");
    Reference refImgUplaod = refImg.child(uniqueName);
    await refImgUplaod.putFile(
        File(path), SettableMetadata(contentType: 'video/mp4'));
    String imgUrl = await refImgUplaod.getDownloadURL();
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      read: false,
      isMap: false,
      receiverID: receiverID,
      isVid: true,
      fName: fName,
      repliedTo: "",
      message: imgUrl,
      isDoc: false,
      isVoice: false,
      isImg: false,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    await lastMessageSent(chatRoomID, timestamp, receiverID, "Image");
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
    await sendNotifications(receiverID, "Image");
  }

  Future<void> sendDocumentMessage(
      String receiverID, String path, String fExt, String fName) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    final String uniqueName =
        'Letters Document ${timestamp.microsecondsSinceEpoch.toString()}$fExt';
    Reference refImg = _ref.child("documents");
    Reference refDocUpload = refImg.child(uniqueName);
    await refDocUpload.putFile(File(path));
    String docUrl = await refDocUpload.getDownloadURL();
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      fName: fName,
      isVid: false,
      read: false,
      isMap: false,
      receiverID: receiverID,
      repliedTo: "",
      message: docUrl,
      isVoice: false,
      isImg: false,
      isDoc: true,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    await lastMessageSent(chatRoomID, timestamp, receiverID, "Document");
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
    await sendNotifications(receiverID, "📄 Document");
  }

  Future<void> sendLocationAsMessage(
      String receiverID, double lat, double long) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      read: false,
      isMap: true,
      isVid: false,
      isDoc: false,
      receiverID: receiverID,
      repliedTo: "",
      message: "",
      lat: lat,
      long: long,
      isVoice: false,
      isImg: false,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    await lastMessageSent(chatRoomID, timestamp, receiverID, "Location");
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
    await sendNotifications(receiverID, "📍 Location");
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
      read: false,
      isVid: false,
      isDoc: false,
      message: url,
      isMap: false,
      repliedTo: "",
      isImg: false,
      isVoice: true,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    await lastMessageSent(chatRoomID, timestamp, receiverID, "Voice Message");
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
    await sendNotifications(receiverID, "Voice Message");
  }

  Future<int> getThemeInt(String receiverID) async {
    List<String> ids = [_auth.currentUser!.uid, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(chatRoomID) ?? 1;
  }

  Future<void> setThemeInt(String receiverID, int themeInt) async {
    List<String> ids = [_auth.currentUser!.uid, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(chatRoomID, themeInt);
  }

  Future<void> lockUnlockChats(String receiverID) async {
    List<String> ids = [_auth.currentUser!.uid, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    QuerySnapshot<Object?> snapshot = await _firestore
        .collection("chat_room")
        .where("users", isEqualTo: ids)
        .get();
    QueryDocumentSnapshot<Object?> doc = snapshot.docs[0];
    await _firestore.collection("chat_room").doc(chatRoomID).set({
      "user": _auth.currentUser!.uid,
      "otheruser": receiverID,
      "users": ids,
      "sentBy": doc["sentBy"],
      "messageSent": doc["messageSent"],
      "locked": !doc["locked"],
      "pinned": doc["pinned"],
      "lastMessage": doc["lastMessage"]
    });
  }

  Future<void> pinUnPinChats(String receiverID) async {
    List<String> ids = [_auth.currentUser!.uid, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    QuerySnapshot<Object?> snapshot = await _firestore
        .collection("chat_room")
        .where("users", isEqualTo: ids)
        .get();
    QueryDocumentSnapshot<Object?> doc = snapshot.docs[0];
    await _firestore.collection("chat_room").doc(chatRoomID).set({
      "user": _auth.currentUser!.uid,
      "otheruser": receiverID,
      "users": ids,
      "sentBy": doc["sentBy"],
      "messageSent": doc["messageSent"],
      "locked": doc["locked"],
      "pinned": !doc["pinned"],
      "lastMessage": doc["lastMessage"]
    });
  }

  Future<void> deleteMessage(String id, String receiverID) async {
    List<String> ids = [_auth.currentUser!.uid, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .collection("Messages")
        .doc(id)
        .delete();
    await _firestore
        .collection("chat_room")
        .doc(chatRoomID)
        .update({"messageSent": "Message Deleted"});
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

  Stream<QuerySnapshot> getAssistantMessages(String userID) {
    return _firestore
        .collection("assistant")
        .doc(userID)
        .collection("Messages")
        .orderBy("timestamp")
        .snapshots();
  }

  Future<void> sendNotifications(String receiverID, String message) async {
    const String appKey = "MTFiZDg0YWItZWEwNy00NzdiLWE1ODgtZTQ5MmNiNzZjYTYw";
    const String appId = "4b3b447f-4915-4439-b3d8-0da767e76e77";
    QuerySnapshot<Object?> snapshot = await _firestore
        .collection("Users")
        .where("id", isEqualTo: _auth.currentUser!.uid)
        .get();
    QueryDocumentSnapshot<Object?> doc = snapshot.docs[0];
    final Map<String, dynamic> requestBody = {
      "included_segments": ["Active Users"],
      'filters': [
        {"field": "tag", "key": "userId", "relation": "=", "value": receiverID}
      ],
      "headings": {"en": doc["name"]},
      "contents": {"en": message},
      "ios_interruption_level": "critical",
      "app_id": appId,
      "target_channel": "push",
      "android_channel_id": "fea8bcbd-7301-4559-ad3d-78e6d0f5345b"
    };
    final Map<String, String> headers = {
      "Authorization": "Basic $appKey",
      "accept": "application/json",
      "content-type": "application/json"
    };

    try {
      final http.Response response = await http.post(
          Uri.parse("https://onesignal.com/api/v1/notifications"),
          headers: headers,
          body: jsonEncode(requestBody));
      if (response.statusCode == 200) {
        print(response.body);
        print("Notification sent successfully");
      } else {
        print("An error occurred");
      }
    } catch (e) {
      print("Error sending notifications");
      print(e);
    }
  }
}
