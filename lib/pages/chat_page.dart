// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/chats/chat_bubble.dart';
import 'package:letters/components/custom/custom_textfield.dart';
import 'package:letters/components/chats/popup_menu.dart';
import 'package:letters/components/custom/request_dialog.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import "package:provider/provider.dart";
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();
  final theme = "";
  FocusNode myFocusNode = FocusNode();

  final record = Record();
  String path = "";
  bool isRecording = false;
  bool messageReply = false;
  String repliedMessage = "";
  bool repliedCurrentUser = false;
  String changeStatus = "offline";

  startRecord() async {
    final location = await getApplicationDocumentsDirectory();
    String name = const Uuid().v1();
    if (await record.hasPermission()) {
      await record.start(path: "${location.path}$name.m4a");
    }
  }

  setSeen() async {
    await _chatService.setMessageToSeen(widget.receiverID);
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

  getThemeInt() async {
    return await _chatService.getThemeInt(widget.receiverID);
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
      widget.themeInt = prefs.getInt(chatRoomID) ?? 1;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getSharedPrefs();
    setSeen();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isBg = state == AppLifecycleState.paused;
    final isClosed = state == AppLifecycleState.detached;
    final isScreen = state == AppLifecycleState.resumed;
    isBg || isScreen == true || isClosed == false
        ? setState(() {
            changeStatus = "online";
          })
        : setState(() {
            changeStatus = "offline";
          });
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
    if (widget.themeInt == 3) return const Color(0xffd32f2f);
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
      await _chatService.sendMessage(widget.receiverID, x, repliedMessage);
      scrollDown();
    } else {
      RequestDialog.show(context, "Message Field is Empty");
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
            SizedBox(
              width: width / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.receiverName),
                  SizedBox(
                    width: width / 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: width / 60,
                          height: height / 90,
                          decoration: BoxDecoration(
                              color: changeStatus == "online"
                                  ? Colors.green
                                  : Colors.red.shade700,
                              shape: BoxShape.circle),
                        ),
                        Text(
                          changeStatus,
                          style: TextStyle(
                              color: Colors.grey, fontSize: width / 40),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text("Coming Soon"),
                      content: Text(
                          "This feature will soon be available to all users, right now it is being tested. \nRegards, \nAnimish Sharma"),
                    );
                  });
            },
            child: const Icon(Icons.call),
          ),
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
          messageReply
              ? _buildReplyMessage(repliedMessage, repliedCurrentUser, context)
              : Container(),
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
              .map((doc) => _buildMessageItem(doc, i, isDarkMode))
              .toList(),
        );
      },
    );
  }

  Widget _buildReplyMessage(
      String message, bool isCurrentUser, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(right: width / 6.5, left: width / 30),
      height: height / 20,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xff9381ff),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: width / 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: "Replying to: ",
                        children: [TextSpan(text: message)]),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    messageReply = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: height / 30,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, Color i, bool isDarkMode) {
    Color pLightColor = getpLight();
    Color sLightColor = getsLight();
    Color pDarkColor = getpDark();
    Color sDarkColor = getsDark();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderID"] == _authService.getUser()!.uid;
    final date = data["timestamp"].toDate();
    final alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return GestureDetector(
      onHorizontalDragUpdate: (det) {
        int sensitivity = 6;
        if (det.delta.dx > sensitivity) {
          setState(() {
            messageReply = true;
            repliedMessage = data["message"];
            repliedCurrentUser = isCurrentUser;
          });
        }
      },
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              id: doc.id,
              message: data["message"],
              receiverID: widget.receiverID,
              isCurrentUser: isCurrentUser,
              sLightColor: sLightColor,
              pLightColor: pLightColor,
              pDarkColor: pDarkColor,
              sDarkColor: sDarkColor,
              repliedMessage: data["repliedTo"],
              isImage: data["isImg"],
              isVoice: data["isVoice"],
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
                      color: data["read"]
                          ? Colors.blue
                          : isDarkMode
                              ? Colors.white
                              : Colors.black,
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
                    XFile? file = await imagePicker.pickImage(
                        source: ImageSource.gallery);
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.grey.shade900,
                        duration: const Duration(seconds: 5),
                        content: Row(
                          children: <Widget>[
                            const CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                            Text(
                              "  Uploading...",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.background),
                            )
                          ],
                        ),
                      ));
                      await _chatService.sendImageMessage(
                          widget.receiverID, file!.path);
                      setState(() {
                        repliedMessage = "";
                        messageReply = false;
                        repliedCurrentUser = false;
                      });
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.grey.shade900,
                          duration: const Duration(seconds: 5),
                          content: Row(
                            children: <Widget>[
                              const CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                              Text(
                                "  Uploading...",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                              )
                            ],
                          ),
                        ));
                        stopRecord();
                      }
                      repliedMessage = "";
                      messageReply = false;
                      repliedCurrentUser = false;
                    });
                  },
                  child: Icon(isRecording ? Icons.stop : Icons.mic_none_sharp)),
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
                setState(() {
                  repliedMessage = "";
                  messageReply = false;
                  repliedCurrentUser = false;
                });
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
