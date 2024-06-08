import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class UserTile extends StatefulWidget {
  final String text;
  final String receiverID;
  final void Function()? onTap;
  final String imgUrl;
  const UserTile(
      {super.key,
      required this.text,
      required this.receiverID,
      required this.onTap,
      required this.imgUrl});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  final ChatService _chatService = ChatService();
  String messageSent = "";
  bool sentByUser = true;

  getMessageSent() async {
    String a = await _chatService.getLastMessage(widget.receiverID);
    setState(() {
      messageSent = a;
    });
  }

  getUserMessageSent() async {
    bool a = await _chatService.lastMessageSentByUser(widget.receiverID);
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 12.5, horizontal: 20),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (widget.imgUrl != "") {
                  final imageProvider = Image.network(widget.imgUrl).image;
                  showImageViewer(context, imageProvider);
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: height / 45,
                child: ClipOval(
                    child: widget.imgUrl == ""
                        ? Image.asset("assets/profile.png", height: height)
                        : Image.network(
                            widget.imgUrl,
                            fit: BoxFit.fitWidth,
                            width: width,
                            height: width,
                          )),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: GoogleFonts.rubik(fontSize: 18),
                ),
                messageSent != ""
                    ? SizedBox(
                        width: width / 1.65,
                        child: Text(
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          messageSent,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey),
                        ),
                      )
                    : const SizedBox(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
            !sentByUser
                ? Container(
                    margin: EdgeInsets.fromLTRB(width / 50, 0, 0, height / 100),
                    width: width / 50,
                    height: height / 80,
                    decoration: const BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                  )
                : const SizedBox(
                    width: 0,
                    height: 0,
                  )
          ],
        ),
      ),
    );
  }
}
