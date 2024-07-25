import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/chats/assistantChatBubble.dart';
import 'package:letters/components/chats/chat_bubble.dart';
import 'package:letters/components/custom/custom_textfield.dart';
import 'package:letters/components/custom/request_dialog.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:letters/func/color_selector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Assistant extends StatefulWidget {
  const Assistant({super.key, required this.receiverID});
  final String receiverID;

  @override
  State<Assistant> createState() => _AssistantState();
}

class _AssistantState extends State<Assistant> {
  final _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  int themeInt = 1;
  String currentDate = "";
  final _numberToMonth = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec"
  };
  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
    }
  }
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String x = _messageController.text;
      _messageController.clear();
      await _chatService.sendAssistantMessage(x);
      scrollDown();
    } else {
      RequestDialog.show(context, "Message Field is Empty");
    }
  }
  Future<void> deleteChat() async {
    await _chatService.deleteAssistantChat();
  }
  _createChat() async {
    await _chatService.createAssistantRoom(widget.receiverID);
  }
  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> ids = [
      FirebaseAuth.instance.currentUser!.uid,
      widget.receiverID
    ];
    ids.sort();
    String chatRoomID = ids.join("_");
    setState(() {
      themeInt = prefs.getInt(chatRoomID) ?? 1;
    });
  }

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createChat();
    });
    Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title:const Text("AI Assistant"),
        actions: [
           GestureDetector(
            onTap: () async {
              await deleteChat();
              Navigator.of(context).pop();
            },
             child: const Padding(
              padding:  EdgeInsets.only(right: 12.0),
              child: Icon(Icons.delete,color: Colors.red,),
                       ),
           )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(context)),
          _buildUserInput(context)
        ],
      ),
    );
  }
  Widget _buildMessageList(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String senderID = _authService.getUser()!.uid;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    Color i = isDarkMode ? Colors.grey.shade200 : Colors.grey.shade700;
    return StreamBuilder(
      stream: _chatService.getAssistantMessages(senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return SingleChildScrollView(
            child: SizedBox(
              width: width,
              height: height,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: width / 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: SizedBox(
                        width: width / 1.5,
                        child: Image.asset("assets/message4.gif"),
                      ),
                    ),
                  ),
                  SizedBox(height: height / 40),
                  Text(
                    "Say Hi! to your assistant",
                    style: GoogleFonts.poppins(
                        fontSize: width / 18,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading");
        }
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc, i, isDarkMode))
              .toList(),
        );
      },
    );
  }
  Widget _buildMessageItem(DocumentSnapshot doc, Color i, bool isDarkMode) {
    Color pLightColor = getpLight(themeInt);
    Color sLightColor = getsLight(themeInt);
    Color pDarkColor = getpDark(themeInt);
    Color sDarkColor = getsDark(themeInt);
    bool newDate = false;
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderID"] == _authService.getUser()!.uid;
    final date = data["timestamp"].toDate();
    String nowDate = "${date.day} ${_numberToMonth[date.month]} ${date.year}";
    if (currentDate == "") {
      currentDate = nowDate;
      newDate = true;
    } else if (currentDate != nowDate) {
      currentDate = nowDate;
      newDate = true;
    } else {
      newDate = false;
    }
    final alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          newDate
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 12),
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 0),
                    decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade600
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(nowDate,
                        style: GoogleFonts.dmSans(
                            fontSize: 12.5,
                            color: isDarkMode
                                ? Colors.grey.shade100
                                : Colors.grey.shade700)),
                  ),
                )
              : const SizedBox(width: 0, height: 0),
          AssistantChatBubble(
            id: doc.id,
            message: data["message"],
            receiverID: widget.receiverID,
            isCurrentUser: isCurrentUser,
            sLightColor: sLightColor,
            pLightColor: pLightColor,
            pDarkColor: pDarkColor,
            sDarkColor: sDarkColor,
          ),
          Padding(
            padding: isCurrentUser
                ? const EdgeInsets.only(right: 24)
                : const EdgeInsets.only(left: 30),
            child: Row(
              mainAxisAlignment: !isCurrentUser
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.done_all_outlined,
                    size: 16,
                  ),
                ),
                Text(
                  date.toString().substring(11, 16),
                  style: GoogleFonts.poppins(color: i, fontSize: 10),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _buildUserInput(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(bottom: height / 40),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              focusNode: myFocusNode,
              hintText: "Message",
              isPass: false,
              controller: _messageController,
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: height / 100),
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            child: IconButton(
              onPressed: () {
                sendMessage();
              },
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}