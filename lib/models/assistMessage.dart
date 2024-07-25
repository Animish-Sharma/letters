import 'package:cloud_firestore/cloud_firestore.dart';

class AssistantMessage {
  final String senderID;
  final String senderEmail;
  final String message;
  final Timestamp timestamp;
  AssistantMessage({
    required this.senderID,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      "senderID": senderID,
      "senderEmail": senderEmail,
      "message": message,
      "timestamp": timestamp
    };
  }
}
