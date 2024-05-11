import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String user;
  final String otheruser;
  final Timestamp lastMessage;
  final bool locked;
  final List<String> users;
  Chat({
    required this.user,
    required this.otheruser,
    required this.lastMessage,
    required this.locked,
    required this.users,
  });
  Map<String, dynamic> toMap() {
    if (lastMessage == null) {
      return {
        "user": user,
        "otheruser": otheruser,
        "lastMessage": lastMessage,
        "locked": locked,
        "users": users,
      };
    }
    return {
      "user": user,
      "otheruser": otheruser,
      "lastMessage": lastMessage,
      "locked": locked,
      "users": users,
    };
  }
}
