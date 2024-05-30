import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/custom/gradient_text.dart';
import 'package:letters/components/custom/my_drawer.dart';
import 'package:letters/components/chats/user_tile.dart';
import 'package:letters/models/user.dart';
import 'package:letters/pages/chat_page.dart';
import 'package:letters/pages/drawer/profile.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:page_transition/page_transition.dart';
import "package:provider/provider.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final _chatService = ChatService();
  String searchText = "";
  void logout() async {
    await _authService.signOut();
  }

  getUser() async {
    final User usr = await _authService.getUserInfo();
    setState(() {
      x = usr;
    });
  }

  User x = User(name: "", email: "email");

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    String a = x.imgUrl ?? "";
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text("Home"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageTransition(
                    duration: const Duration(milliseconds: 325),
                    child: const ProfilePage(),
                    type: PageTransitionType.leftToRightWithFade,
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: height / 50,
                child: ClipOval(
                  child: a == ""
                      ? Image.asset("assets/profile.png")
                      : Image.network(
                          a,
                          height: height,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return SingleChildScrollView(
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                overflow: TextOverflow.fade,
                "Welcome ${x.name} 👋",
                style: GoogleFonts.poppins(
                    height: 0.3,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                    fontSize: width / 22.5,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w300),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GradientText(
                'Letters',
                style:
                    TextStyle(fontSize: width / 7, fontWeight: FontWeight.w100),
                gradient: LinearGradient(
                    colors: !isDarkMode
                        ? [
                            const Color(0xff8E7AB5),
                            const Color(0xffB784B7),
                            const Color(0xffE493B3),
                            const Color(0xffEEA5A6),
                          ]
                        : [
                            const Color(0xff7469B6),
                            const Color(0xffAD88C6),
                            const Color(0xffE1AFD1),
                            const Color(0xffFFE6E6),
                          ]),
              ),
            ),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: width / 1.15,
                height: height / 12.5,
                margin: const EdgeInsets.only(bottom: 20),
                child: TextField(
                  onChanged: (String s) {
                    if (s == "") {
                      setState(() {
                        searchText = "";
                      });
                    }
                    setState(() {
                      searchText = s;
                    });
                  },
                  controller: _searchController,
                  style: GoogleFonts.poppins(
                      fontSize: width / 24.5, color: Colors.black),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(16),
                      hintText: "Search Messages",
                      hintStyle: GoogleFonts.poppins(
                          color: const Color(0xff7f7f7f),
                          fontWeight: FontWeight.w300),
                      filled: true,
                      fillColor: !isDarkMode
                          ? const Color(0xffd7d7d7)
                          : const Color(0xffc3c3c3),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: !isDarkMode
                                  ? const Color(0xffd7d7d7)
                                  : const Color(0xffc3c3c3))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: !isDarkMode
                                  ? const Color(0xffd7d7d7)
                                  : const Color(0xffc3c3c3))),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )),
                ),
              ),
            ),
            Flexible(
              child: StreamBuilder(
                  stream: _chatService.getActiveChats(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Error");
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Text("");
                    } else if (snapshot.data!.isEmpty) {
                      if (_searchController.text.isNotEmpty) {
                        return Container();
                      }
                      return Container(
                        width: width,
                        height: height,
                        margin: EdgeInsets.only(top: height / 6),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.close_rounded,
                              size: height / 7,
                              color: !isDarkMode
                                  ? Colors.red.shade500
                                  : Colors.red.shade300,
                            ),
                            SizedBox(height: height / 60),
                            Text("No Chats Found",
                                style: GoogleFonts.inter(
                                    fontSize: height / 30,
                                    fontWeight: FontWeight.w300))
                          ],
                        ),
                      );
                    } else {
                      return ListView(
                        children: snapshot.data!
                            .map(
                                (userData) => _buildUserItem(userData, context))
                            .toList(),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
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
                                                .primary),
                                      )
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
