import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/chat_bubble.dart';
import 'package:letters/components/custom_textfield.dart';
import 'package:letters/components/popup_menu.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import "package:provider/provider.dart";
import 'package:record/record.dart';
import "dart:math";
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;
  final String receiverEmail;
  final String receiverID;
  final String receiverBio;
  final String imgUrl;
  int themeInt = 1;

  ChatPage(
      {super.key,
      required this.receiverBio,
      required this.imgUrl,
      required this.receiverEmail,
      required this.receiverID,
      required this.receiverName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();
  final theme = "";
  FocusNode myFocusNode = FocusNode();

  final record = Record();
  String path = "";
  bool isRecording = false;

  startRecord() async {
    final location = await getApplicationDocumentsDirectory();
    String name = const Uuid().v1();
    if (await record.hasPermission()) {
      await record.start(path: "${location.path}$name.m4a");
    }
  }

  callBack(int val) {
    setState(() {
      widget.themeInt = val;
    });
  }

  stopRecord() async {
    String? finalPath = await record.stop();
    setState(() {
      path = finalPath!;
    });
    await _chatService.sendVoiceMessage(widget.receiverID, path);
  }

  _createChat() async {
    await _chatService.createChatRoom(widget.receiverID);
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
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
    }
  }

  Color getpLight() {
    if (widget.themeInt == 1) return const Color(0xff4caf50);
    if (widget.themeInt == 2) return const Color(0xff29b6f6);
    if (widget.themeInt == 3) return Colors.red;
    return Colors.purple;
  }

  Color getpDark() {
    if (widget.themeInt == 1) return const Color(0xff2e7d32);
    if (widget.themeInt == 2) return const Color(0xff1565c0);
    if (widget.themeInt == 3) return Color(0xffd32f2f);
    return Colors.purple;
  }

  Color getsLight() {
    if (widget.themeInt == 1) return const Color(0xffd6d6d6);
    if (widget.themeInt == 2) return const Color(0xfff8bbd0);
    if (widget.themeInt == 3) return const Color(0xffffca28);
    return const Color(0xffb0bec5);
  }

  Color getsDark() {
    if (widget.themeInt == 1) return const Color(0xff424242);
    if (widget.themeInt == 2) return const Color(0xffec407A);
    if (widget.themeInt == 3) return const Color(0xffff6f00);
    return const Color(0xff455a64);
  }

  String getMessage() {
    List list = [
      "message1",
      "message2",
      "message3",
      "message4",
    ];
    final random = Random();
    final randomItem = list[random.nextInt(list.length)];
    return randomItem;
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String x = _messageController.text;
      _messageController.clear();
      await _chatService.sendMessage(widget.receiverID, x);
      scrollDown();
    }
  }

  bool change = false;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: widget.imgUrl == ""
                    ? Image.asset("assets/profile.png")
                    : Image.network(widget.imgUrl, height: height),
              ),
            ),
            SizedBox(width: width / 40),
            Text(widget.receiverName),
          ],
        ),
        actions: <Widget>[
          PopUpMenu(
            height: height,
            widget: widget,
            chatService: _chatService,
            callBack: callBack,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildMessageList(context)),
          _buildUserInput(context)
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final name = getMessage();
    String senderID = _authService.getUser()!.uid;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    Color i = isDarkMode ? Colors.grey.shade200 : Colors.grey.shade700;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return SizedBox(
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
                      child: Image.asset("assets/$name.gif"),
                    ),
                  ),
                ),
                SizedBox(height: height / 40),
                Text(
                  "Say Hi! to ${widget.receiverName}",
                  style: GoogleFonts.poppins(
                      fontSize: width / 18,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading");
        }
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc, i))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, Color i) {
    Color pLightColor = getpLight();
    Color sLightColor = getsLight();
    Color pDarkColor = getpDark();
    Color sDarkColor = getsDark();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderID"] == _authService.getUser()!.uid;
    final date = data["timestamp"].toDate();
    final alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            sLightColor: sLightColor,
            pLightColor: pLightColor,
            pDarkColor: pDarkColor,
            sDarkColor: sDarkColor,
            isImage: data["isImg"],
            isVoice: data["isVoice"],
          ),
          Padding(
            padding: isCurrentUser
                ? const EdgeInsets.only(right: 24)
                : const EdgeInsets.only(left: 30),
            child: Text(
              date.toString().substring(11, 16),
              style: GoogleFonts.poppins(color: i, fontSize: 10),
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
            icon: InkWell(
                onTap: () async {
                  ImagePicker imagePicker = ImagePicker();
                  XFile? file =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  try {
                    await _chatService.sendImageMessage(
                        widget.receiverID, file!.path);
                    // ignore: empty_catches
                  } catch (e) {}
                },
                child: const Icon(Icons.image_outlined)),
            suffix: InkWell(
                onTap: () {
                  setState(() {
                    isRecording = !isRecording;
                    if (isRecording) {
                      startRecord();
                    } else {
                      stopRecord();
                    }
                  });
                },
                child: Icon(isRecording ? Icons.stop : Icons.mic_none_sharp)),
            controller: _messageController,
          )),
          Container(
            margin: EdgeInsets.only(right: height / 100),
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            child: IconButton(
              onPressed: sendMessage,
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
