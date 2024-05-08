import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/custom_textfield.dart';
import 'package:letters/components/user_tile.dart';
import 'package:letters/pages/chat_page.dart';
import 'package:letters/services/chat/chat_service.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text("Search"),
      ),
      body: _buildUserList(width),
    );
  }

  Widget _buildUserList(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
          child: Text(
            "Search",
            style: GoogleFonts.roboto(
                color: Colors.grey, fontSize: 56, fontWeight: FontWeight.w100),
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
                  setState(() {
                    isClicked = true;
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      setState(() {
                        isClicked = false;
                      });
                    });
                  });
                },
              ),
            )
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
