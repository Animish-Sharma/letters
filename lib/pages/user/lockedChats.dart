// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/components/chats/user_tile.dart';
import 'package:letters/pages/chat_page.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class LockedChats extends StatefulWidget {
  const LockedChats({super.key});

  @override
  State<LockedChats> createState() => _LockedChatsState();
}

class _LockedChatsState extends State<LockedChats> {
  final _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text("Locked Chats"),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            "Locked Chats",
            style: GoogleFonts.roboto(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 56,
                fontWeight: FontWeight.w100),
          ),
        ),
        Flexible(
          child: StreamBuilder(
              stream: _chatService.getActiveLockedChats(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error");
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Text("");
                } else if (snapshot.data!.isEmpty) {
                  return Container(
                    width: width,
                    height: height,
                    margin: EdgeInsets.only(top: height / 6),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.cancel_outlined,
                          size: height / 7,
                          color: !isDarkMode
                              ? Colors.red.shade500
                              : Colors.red.shade300,
                        ),
                        SizedBox(height: height / 60),
                        Text("No Locked Chats",
                            style: GoogleFonts.inter(
                                fontSize: height / 30,
                                fontWeight: FontWeight.w300))
                      ],
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
        ),
      ],
    );
  }

  Widget _buildUserItem(String id, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection("Users").doc(id).get(),
      builder: ((context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Column(
            children: [
              Icon(Icons.cancel, size: width / 33),
              Text(
                "Error",
                style: GoogleFonts.lato(fontSize: width / 25),
              ),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("LOADING....");
        } else if (!snapshot.hasData) {
          return const Text("NO USER");
        } else if (snapshot.hasData) {
          final usr = snapshot.data;
          return GestureDetector(
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (context) => SizedBox(
                        width: width / 1.1,
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
                              title: const Text("Lock/Unlock Chat"),
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
                                        "  Locking/Unlocking Chats...",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .background),
                                      )
                                    ],
                                  ),
                                ));
                                Navigator.of(context).pop();
                                await _chatService
                                    .lockUnlockChats(snapshot.data["id"]);
                                // ignore: use_build_context_synchronously
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
              imgUrl: usr['imgUrl'],
              receiverID: id,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
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
