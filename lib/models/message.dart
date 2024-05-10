import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final bool isImg;
  final bool isVoice;
  final String? repliedTo;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.isImg,
    this.repliedTo,
    required this.isVoice,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      "senderID": senderID,
      "senderEmail": senderEmail,
      "receiverID": receiverID,
      "isImg": isImg,
      "repliedTo": repliedTo,
      "isVoice": isVoice,
      "message": message,
      "timestamp": timestamp
    };
  }
}
