import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:letters/components/custom/request_dialog.dart';
import 'package:letters/components/custom/scaff_mess.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AssistantChatBubble extends StatefulWidget {
  final String id;
  final String message;
  final String receiverID;
  final bool isCurrentUser;
  final Color pLightColor;
  final Color sLightColor;
  final Color pDarkColor;
  final Color sDarkColor;
  const AssistantChatBubble(
      {super.key,
      required this.receiverID,
      required this.sLightColor,
      required this.pLightColor,
      required this.sDarkColor,
      required this.pDarkColor,
      required this.message,
      required this.id,
      required this.isCurrentUser,
     });

  @override
  State<AssistantChatBubble> createState() => _AssistantChatBubbleState();
}

class _AssistantChatBubbleState extends State<AssistantChatBubble> {
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  double duration = 0;
  Duration position = const Duration();

  @override
  void initState() {
    super.initState();
  }

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
    bool isLink = widget.message.contains("https");
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      crossAxisAlignment: widget.isCurrentUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [GestureDetector(
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
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isCurrentUser
                        ? (isDarkMode ? widget.pDarkColor : widget.pLightColor)
                        : (isDarkMode ? widget.sDarkColor : widget.sLightColor),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(14),
                  margin:
                      const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
                  child: Text(
                    widget.message,
                    style: TextStyle(
                        color: isLink
                            ? isDarkMode
                                ? Colors.blue
                                : Colors.blue.shade300
                            : widget.isCurrentUser
                                ? Colors.white
                                : (isDarkMode ? Colors.white : Colors.black),
                        decoration: isLink
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor:
                            isDarkMode ? Colors.blue : Colors.blue.shade300),
                  ),
                ),
              )
           
      ],
    );
  }
}
