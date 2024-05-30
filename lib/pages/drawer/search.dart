import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/custom/custom_textfield.dart';
import 'package:letters/components/chats/user_tile.dart';
import 'package:letters/components/custom/gradient_text.dart';
import 'package:letters/components/custom/request_dialog.dart';
import 'package:letters/pages/chat_page.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _authService = AuthService();
  final _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  void logout() async {
    await _authService.signOut();
  }

  Stream x = const Stream.empty();
  bool isClicked = false;

  Stream getStreams() {
    if (isClicked) {
      x = _chatService.getCurrentUserStream(_searchController.text.trim());
    }
    return x;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text("Search"),
      ),
      body: _buildUserList(width, isDarkMode),
    );
  }

  Widget _buildUserList(double width, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: GradientText(
            'Search',
            style: TextStyle(fontSize: width / 7, fontWeight: FontWeight.w100),
            gradient: LinearGradient(
                colors: !isDarkMode
                    ? [
                        const Color(0xffFC5C7D),
                        const Color(0xff6A82FB),
                      ]
                    : [
                        const Color(0xffDAE2F8),
                        const Color(0xffD6A4A4),
                      ]),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: width / 1.2,
              child: CustomTextField(
                hintText: "Email",
                isPass: false,
                controller: _searchController,
                icon: const Icon(Icons.email),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    setState(() {
                      isClicked = true;
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        setState(() {
                          isClicked = false;
                        });
                      });
                    });
                  } else {
                    RequestDialog.show(context, "Email cannot be empty");
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: width / 25),
        Flexible(child: _runStream(width)),
      ],
    );
  }

  Widget _runStream(double width) {
    return StreamBuilder(
      stream: getStreams(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        } else if (!snapshot.hasData) {
          bool isDarkMode =
              Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
          double height = MediaQuery.of(context).size.height;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: width / 5),
                  Icon(Icons.search, size: width / 3, color: Colors.grey),
                  SizedBox(height: width / 30),
                  Text(
                    "Search User by email",
                    style: GoogleFonts.poppins(
                        fontSize: width / 20, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: height / 3),
                  GestureDetector(
                    onTap: () async {
                      const url =
                          "https://api.whatsapp.com/send?text=Download the web3 chat app Letters from https://cirious.netlify.app/apps";
                      var encoded = Uri.parse(url);
                      if (await canLaunchUrl(encoded)) {
                        await launchUrl(encoded,
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      width: width / 1.7,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(3)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Colors.grey,
                            size: width / 12,
                          ),
                          Text(
                            "    Invite others",
                            style: GoogleFonts.poppins(
                                fontSize: width / 20,
                                color: isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading....");
        } else if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              children: [
                SizedBox(height: width / 5),
                Icon(Icons.person_off, size: width / 3, color: Colors.grey),
                SizedBox(height: width / 30),
                Text(
                  "No User Found",
                  style: GoogleFonts.poppins(
                      fontSize: width / 20, color: Colors.grey.shade600),
                )
              ],
            ),
          );
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getUser()?.email) {
      return UserTile(
        text: userData["email"],
        receiverID: userData["id"],
        imgUrl: userData["imgUrl"] ?? "",
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverName: userData["name"],
              receiverEmail: userData["email"],
              receiverID: userData["id"],
              receiverBio: userData['bio'],
              imgUrl: userData["imgUrl"],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
