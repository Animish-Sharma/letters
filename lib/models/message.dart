import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final bool isImg;
  final bool isVoice;
  final bool isMap;
  final bool isDoc;
  final bool read;
  final String? repliedTo;
  final double? lat;
  final double? long;
  final String message;
  final Timestamp timestamp;
  final String? fName;
  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.isImg,
    this.fName,
    required this.isDoc,
    this.repliedTo,
    this.lat,
    this.long,
    required this.isVoice,
    required this.isMap,
    required this.read,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      "senderID": senderID,
      "senderEmail": senderEmail,
      "receiverID": receiverID,
      "isImg": isImg,
      "isMap": isMap,
      "repliedTo": repliedTo,
      "lat": lat,
      "long": long,
      "isVoice": isVoice,
      "fName": fName,
      "isDoc": isDoc,
      "read": read,
      "message": message,
      "timestamp": timestamp
    };
  }
}
