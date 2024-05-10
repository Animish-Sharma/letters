import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:letters/themes/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatefulWidget {
  final String message;
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
      required this.sLightColor,
      required this.repliedMessage,
      required this.pLightColor,
      required this.sDarkColor,
      required this.pDarkColor,
      required this.message,
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
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.repliedMessage != ""
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width / 2),
                child: Container(
                  margin: widget.isCurrentUser
                      ? EdgeInsets.only(left: width / 20, top: height / 80)
                      : EdgeInsets.only(right: width / 20, top: height / 80),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xff9381ff) : Color(0xffb8b8ff),
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
                onLongPress: () async {
                  await Clipboard.setData(ClipboardData(text: widget.message))
                      .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              showCloseIcon: true,
                              content: Text("Message copied to clipboard"))));
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
                          color: widget.isCurrentUser
                              ? Colors.white
                              : (isDarkMode ? Colors.white : Colors.black)),
                    )),
              )
            : widget.isImage && !widget.isVoice
                ? GestureDetector(
                    onTap: () {
                      final imageProvider = Image.network(widget.message).image;
                      showImageViewer(context, imageProvider);
                    },
                    onLongPress: () async {
                      final http.Response response =
                          await http.get(Uri.parse(widget.message));
                      final dir = await getTemporaryDirectory();
                      final filename =
                          '${dir.path}/LetterImage-${DateTime.now().microsecondsSinceEpoch}.png';
                      final file = File(filename);
                      await file.writeAsBytes(response.bodyBytes);
                      final params =
                          SaveFileDialogParams(sourceFilePath: file.path);
                      final finalPath =
                          await FlutterFileDialog.saveFile(params: params);
                      if (finalPath != null) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                showCloseIcon: true,
                                content: Text("Image saved to gallery")));
                      }
                    },
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
                      width: width / 2,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(
                          vertical: 2.5, horizontal: 7),
                      child: Image.network(
                        widget.message,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
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
