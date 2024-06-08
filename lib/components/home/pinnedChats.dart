// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/components/chats/card.dart';
import 'package:letters/services/chat/chat_service.dart';

class PinnedChats extends StatefulWidget {
  const PinnedChats({super.key});

  @override
  State<PinnedChats> createState() => _PinnedChatsState();
}

class _PinnedChatsState extends State<PinnedChats> {
  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    return Flexible(
      child: StreamBuilder(
          stream: chatService.getActivePinnedChats(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            } else if (snapshot.data!.isEmpty) {
              return const SizedBox(width: 0, height: 0);
            } else {
              double width = MediaQuery.of(context).size.width;
              return ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: width / 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Pinned Chats",
                              style: GoogleFonts.inter(
                                  letterSpacing: .6, fontSize: width / 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GridView(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      children: snapshot.data!
                          .map((userData) => _buildUserItem(userData, context))
                          .toList(),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }

  Widget _buildUserItem(String id, BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection("Users").doc(id).get(),
      builder: ((context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("LOADING....");
        } else if (!snapshot.hasData) {
          return const Text("NO USER");
        } else if (snapshot.hasData) {
          return UserCard(snapshot: snapshot);
        }
        return const SizedBox(width: 0, height: 0);
      }),
    );
  }
}
