// ignore_for_file: must_be_immutable

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/pages/chat_page.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class UserCard extends StatefulWidget {
  UserCard({super.key, required this.snapshot});
  AsyncSnapshot snapshot;
  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  String messageSent = "";
  bool sentByUser = true;

  getMessageSent() async {
    String a = await _chatService.getLastMessage(widget.snapshot.data["id"]);
    setState(() {
      messageSent = a;
    });
  }

  getUserMessageSent() async {
    bool a =
        await _chatService.lastMessageSentByUser(widget.snapshot.data["id"]);
    setState(() {
      sentByUser = a;
    });
  }

  @override
  void initState() {
    super.initState();
    getMessageSent();
    getUserMessageSent();
  }

  final ChatService _chatService = ChatService();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final usr = widget.snapshot.data;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return !sentByUser
        ? AvatarGlow(
            repeat: true,
            glowColor: Colors.green,
            glowRadiusFactor: 0.1,
            glowShape: BoxShape.circle,
            duration: const Duration(milliseconds: 2000),
            curve: Curves.fastOutSlowIn,
            child: actChild(context, usr, width, isDarkMode, height),
          )
        : actChild(context, usr, width, isDarkMode, height);
  }

  Container actChild(
      BuildContext context, usr, double width, bool isDarkMode, double height) {
    return Container(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                                .lockUnlockChats(widget.snapshot.data["id"]);
                          },
                        ),
                        ListTile(
                          title: const Text("Delete Chat"),
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                                .deleteChat(widget.snapshot.data["id"]);
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
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          margin: EdgeInsets.symmetric(horizontal: width / 20),
          child: Stack(
            children: <Widget>[
              if (usr["imgUrl"] == "")
                Image.asset("assets/profile.png", height: height)
              else
                Container(
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xfff48c06),
                      ],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Image.network(
                    usr["imgUrl"],
                    fit: BoxFit.fitWidth,
                    width: width,
                    height: width,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usr["name"],
                      style: GoogleFonts.poppins(
                          fontSize: width / 25, color: Colors.white),
                    ),
                    SizedBox(
                      width: width / 1.65,
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        messageSent,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey.shade400),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
