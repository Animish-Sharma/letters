import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:letters/components/custom/request_dialog.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubble extends StatefulWidget {
  final String id;
  final String message;
  final String receiverID;
  final bool isCurrentUser;
  final bool isImage;
  final bool isVoice;
  final Color pLightColor;
  final Color sLightColor;
  final String repliedMessage;
  final Color pDarkColor;
  final Color sDarkColor;
  const ChatBubble(
      {super.key,
      required this.receiverID,
      required this.sLightColor,
      required this.repliedMessage,
      required this.pLightColor,
      required this.sDarkColor,
      required this.pDarkColor,
      required this.message,
      required this.id,
      required this.isCurrentUser,
      required this.isImage,
      required this.isVoice});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  double duration = 0;
  Duration position = const Duration();

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  playRecording(String url) async {
    await audioPlayer.play(UrlSource(url));
    final Duration? x = await audioPlayer.getDuration();
    duration = (x!.inSeconds.toDouble());
    setState(() {
      isPlaying = true;
    });
  }

  stopRecording() async {
    await audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isLink = widget.message.contains("https");
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      crossAxisAlignment: widget.isCurrentUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        widget.repliedMessage != ""
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width / 2),
                child: Container(
                  margin: widget.isCurrentUser
                      ? EdgeInsets.only(right: width / 20, top: height / 80)
                      : EdgeInsets.only(left: width / 13, top: height / 80),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xff9381ff)
                        : const Color(0xffb8b8ff),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.repliedMessage.contains("firebasestorage")
                        ? widget.repliedMessage.contains("voice")
                            ? "Voice Message"
                            : "Image"
                        : widget.repliedMessage,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            : const SizedBox(
                width: 0,
                height: 0,
              ),
        !widget.isImage && !widget.isVoice
            ? GestureDetector(
                onTap: isLink
                    ? () async {
                        var url = widget.message;
                        var encoded = Uri.parse(url);
                        if (await canLaunchUrl(encoded)) {
                          await launchUrl(encoded);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }
                    : null,
                onLongPress: () {
                  RequestDialog.drop(context, widget.id, widget.message,
                      widget.receiverID, widget.isImage, widget.isCurrentUser);
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: widget.isCurrentUser
                            ? (isDarkMode
                                ? widget.pDarkColor
                                : widget.pLightColor)
                            : (isDarkMode
                                ? widget.sDarkColor
                                : widget.sLightColor),
                        borderRadius: BorderRadius.circular(20.0)),
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.symmetric(
                        vertical: 2.5, horizontal: 25),
                    child: Text(
                      widget.message,
                      style: TextStyle(
                          color: isLink
                              ? Colors.blue
                              : widget.isCurrentUser
                                  ? Colors.white
                                  : (isDarkMode ? Colors.white : Colors.black),
                          decoration: isLink
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          decorationColor: Colors.blue),
                    )),
              )
            : widget.isImage && !widget.isVoice
                ? GestureDetector(
                    onTap: () {
                      final imageProvider = Image.network(widget.message).image;
                      showImageViewer(context, imageProvider);
                    },
                    onLongPress: () async {
                      RequestDialog.drop(
                          context,
                          widget.id,
                          widget.message,
                          widget.receiverID,
                          widget.isImage,
                          widget.isCurrentUser);
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: width / 5,
                        maxWidth: width / 2,
                        maxHeight: height / 3,
                        minHeight: height / 3,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: widget.isCurrentUser
                              ? (isDarkMode
                                  ? widget.pDarkColor
                                  : widget.pLightColor)
                              : (isDarkMode
                                  ? widget.sDarkColor
                                  : widget.sLightColor),
                        ),
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(
                            vertical: 2.5, horizontal: 7),
                        child: Image.network(
                          widget.message,
                          fit: BoxFit.contain,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : Container(
                    margin: !widget.isCurrentUser
                        ? EdgeInsets.only(right: width / 5)
                        : null,
                    child: BubbleNormalAudio(
                      textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                      color: widget.isCurrentUser
                          ? (isDarkMode
                              ? widget.pDarkColor
                              : widget.pLightColor)
                          : (isDarkMode
                              ? widget.sDarkColor
                              : widget.sLightColor),
                      isLoading: false,
                      isPlaying: isPlaying,
                      position: position.inSeconds.toDouble(),
                      duration: duration,
                      onSeekChanged: (e) {
                        setState(() {
                          position = Duration(seconds: e.toInt());
                        });
                      },
                      onPlayPauseButtonClick: () {
                        if (!isPlaying) {
                          playRecording(widget.message);
                        } else {
                          stopRecording();
                        }
                      },
                    ),
                  ),
      ],
    );
  }
}
