// ignore_for_file: must_be_immutable, file_names, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/components/chats/user_tile.dart';
import 'package:letters/pages/chat_page.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AllChats extends StatelessWidget {
  AllChats({super.key, required this.searchText});
  String searchText;

  @override
  Widget build(BuildContext context) {
    final _chatService = ChatService();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Flexible(
      child: StreamBuilder(
          stream: _chatService.getActiveChats(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("");
            } else if (snapshot.data!.isEmpty) {
              return SingleChildScrollView(
                child: SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("No Chats Found",
                          style: GoogleFonts.inter(
                              fontSize: height / 50,
                              fontWeight: FontWeight.w300))
                    ],
                  ),
                ),
              );
            } else {
              return ListView(
                children: snapshot.data!
                    .map((userData) => _buildUserItem(userData, context))
                    .toList(),
              );
            }
          }),
    );
  }

  Widget _buildUserItem(String id, BuildContext context) {
    final ChatService _chatService = ChatService();
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
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
          final usr = snapshot.data;
          if (!usr["name"].toLowerCase().contains(searchText.toLowerCase())) {
            return const SizedBox(width: 0, height: 0);
          }
          return GestureDetector(
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (context) => SizedBox(
                        width: width / 1.25,
                        child: AlertDialog(
                          title: Text(
                            usr["name"],
                          ),
                          actions: <Widget>[
                            ListTile(
                              title: const Text("Open"),
                              onTap: () => Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  child: ChatPage(
                                    receiverName: usr["name"],
                                    receiverEmail: usr["email"],
                                    receiverID: usr["id"],
                                    imgUrl: usr["imgUrl"],
                                    receiverBio: usr["bio"],
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text("Pin/Unpin Chat"),
                              onTap: () async {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: Colors.grey.shade900,
                                  duration: const Duration(seconds: 2),
                                  content: const Row(
                                    children: <Widget>[
                                      CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                      Text("  Pinning/Unpinning Chats...")
                                    ],
                                  ),
                                ));
                                Navigator.of(context).pop();
                                await _chatService
                                    .pinUnPinChats(snapshot.data["id"]);
                              },
                            ),
                            ListTile(
                              title: const Text("Lock/Unlock Chat"),
                              onTap: () async {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: Colors.grey.shade900,
                                  duration: const Duration(seconds: 2),
                                  content: const Row(
                                    children: <Widget>[
                                      CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                      Text("  Locking/Unlocking Chats...")
                                    ],
                                  ),
                                ));
                                Navigator.of(context).pop();
                                await _chatService
                                    .lockUnlockChats(snapshot.data["id"]);
                              },
                            ),
                            ListTile(
                              title: const Text("Delete Chat"),
                              onTap: () async {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: Colors.grey.shade900,
                                  duration: const Duration(seconds: 2),
                                  content: Row(
                                    children: <Widget>[
                                      const CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                      Text(
                                        "  Deleting Chats...",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      )
                                    ],
                                  ),
                                ));
                                Navigator.of(context).pop();
                                await _chatService
                                    .deleteChat(snapshot.data["id"]);
                              },
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Back",
                                  style: GoogleFonts.inter(
                                      color: isDarkMode
                                          ? Colors.blue.shade300
                                          : Colors.blue),
                                ))
                          ],
                        ),
                      ));
            },
            child: UserTile(
              text: usr["name"],
              receiverID: id,
              imgUrl: usr['imgUrl'],
              onTap: () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: ChatPage(
                    receiverName: usr["name"],
                    receiverEmail: usr["email"],
                    receiverID: usr["id"],
                    imgUrl: usr["imgUrl"],
                    receiverBio: usr["bio"],
                  ),
                ),
              ),
            ),
          );
        }
        return Container();
      }),
    );
  }
}
