// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/pages/chat_page.dart';
import 'package:letters/pages/home.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PopUpMenu extends StatefulWidget {
  PopUpMenu({
    super.key,
    required this.height,
    required this.widget,
    required this.callBack,
    required ChatService chatService,
  }) : _chatService = chatService;
  int groupVal = 1;
  final double height;
  final ChatPage widget;
  final Function callBack;
  final ChatService _chatService;

  @override
  State<PopUpMenu> createState() => _PopUpMenuState();
}

class _PopUpMenuState extends State<PopUpMenu> {
  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> ids = [
      FirebaseAuth.instance.currentUser!.uid,
      widget.widget.receiverID
    ];
    ids.sort();
    String chatRoomID = ids.join("_");
    setState(() {
      groupVal = prefs.getInt(chatRoomID) ?? 1;
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  int groupVal = 1;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PopupMenuButton(
        offset: Offset(width / 20, widget.height / 17),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 0,
            child: ListTile(
              onTap: () {
                Navigator.of(context).pop();
                showBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: widget.height / 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                if (widget.widget.imgUrl != "") {
                                  final imageProvider =
                                      Image.network(widget.widget.imgUrl).image;
                                  showImageViewer(context, imageProvider);
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: widget.height / 10,
                                child: ClipOval(
                                  child: widget.widget.imgUrl == ""
                                      ? Image.asset("assets/profile.png")
                                      : Image.network(
                                          widget.widget.imgUrl,
                                          height: width,
                                          width: width,
                                          fit: BoxFit.fitWidth,
                                        ),
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(widget.widget.receiverName),
                              leading: const Icon(Icons.person),
                            ),
                            ListTile(
                              title: Text(widget.widget.receiverEmail),
                              leading: const Icon(Icons.email),
                            ),
                            ListTile(
                              title: Text(widget.widget.receiverBio == ""
                                  ? "Hi! I am using Letters"
                                  : widget.widget.receiverBio),
                              leading: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                      );
                    });
              },
              leading: const Icon(Icons.person),
              title: const Text("User Information"),
            ),
          ),
          PopupMenuItem(
            value: 2,
            onTap: () {
              showBottomSheet(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) => SizedBox(
                        width: width,
                        height: widget.height / 2.75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: widget.height / 40),
                            Text(
                              "Themes",
                              style: GoogleFonts.inter(
                                  fontSize: widget.height / 40),
                            ),
                            SizedBox(height: widget.height / 40),
                            ListTile(
                              title: const Text("Original"),
                              trailing: Radio(
                                activeColor: Colors.green,
                                value: 1,
                                groupValue: groupVal,
                                onChanged: (val) async {
                                  await widget._chatService.setThemeInt(
                                      widget.widget.receiverID, val ?? 1);
                                  setModalState(() {
                                    widget.callBack(val);
                                    groupVal = val!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Lovers Rock"),
                              trailing: Radio(
                                activeColor: Colors.pink,
                                value: 2,
                                groupValue: groupVal,
                                onChanged: (val) async {
                                  await widget._chatService.setThemeInt(
                                      widget.widget.receiverID, val ?? 2);
                                  setModalState(() {
                                    widget.callBack(val);
                                    groupVal = val!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Euphoria"),
                              trailing: Radio(
                                activeColor: Colors.red,
                                value: 3,
                                groupValue: groupVal,
                                onChanged: (val) async {
                                  await widget._chatService.setThemeInt(
                                      widget.widget.receiverID, val ?? 2);
                                  setModalState(() {
                                    widget.callBack(val);
                                    groupVal = val!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Element"),
                              trailing: Radio(
                                value: 4,
                                activeColor: Colors.purple,
                                groupValue: groupVal,
                                onChanged: (val) async {
                                  await widget._chatService.setThemeInt(
                                      widget.widget.receiverID, val ?? 2);
                                  setModalState(() {
                                    widget.callBack(val);
                                    groupVal = val!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            },
            child: const ListTile(
              leading: Icon(Icons.workspaces),
              title: Text("Themes"),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.grey.shade900,
                duration: const Duration(seconds: 1),
                content: Row(
                  children: <Widget>[
                    const CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                    Text(
                      "   Pinning / UnPinning Chat...",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    )
                  ],
                ),
              ));
              await widget._chatService.pinUnPinChats(widget.widget.receiverID);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            },
            value: 2,
            child: const ListTile(
              leading: Icon(Icons.push_pin),
              title: Text("Pin Chats"),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.grey.shade900,
                duration: const Duration(seconds: 1),
                content: Row(
                  children: <Widget>[
                    const CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                    Text(
                      "   Locking / Unlocking Chat...",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background),
                    )
                  ],
                ),
              ));
              await widget._chatService
                  .lockUnlockChats(widget.widget.receiverID);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            },
            value: 2,
            child: const ListTile(
              leading: Icon(Icons.lock),
              title: Text("Lock/Unlock Chat"),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: ListTile(
              onTap: () async {
                await widget._chatService.deleteChat(widget.widget.receiverID);
                // ignore: duplicate_ignore
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
              textColor: Colors.red,
              iconColor: Colors.red,
              leading: const Icon(Icons.delete),
              title: const Text("Delete Chat"),
            ),
          ),
        ],
      ),
    );
  }
}
