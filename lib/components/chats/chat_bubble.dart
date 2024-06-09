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

class ChatBubble extends StatefulWidget {
  final String id;
  final String message;
  final String receiverID;
  final bool isCurrentUser;
  final bool isImage;
  final bool isVoice;
  final bool isDoc;
  final Color pLightColor;
  final Color sLightColor;
  final String repliedMessage;
  final Color pDarkColor;
  final double? lat;
  final double? long;
  final String? fName;
  final Color sDarkColor;
  final bool isMap;
  const ChatBubble(
      {super.key,
      required this.receiverID,
      required this.sLightColor,
      required this.repliedMessage,
      required this.pLightColor,
      required this.isDoc,
      required this.sDarkColor,
      required this.pDarkColor,
      required this.message,
      required this.isMap,
      required this.id,
      required this.isCurrentUser,
      this.fName,
      this.lat,
      this.long,
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
        !widget.isImage && !widget.isVoice && !widget.isMap && !widget.isDoc
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
                  widget.isCurrentUser
                      ? RequestDialog.drop(
                          context,
                          widget.id,
                          widget.message,
                          widget.receiverID,
                          widget.isImage,
                          widget.isCurrentUser,
                          widget.isVoice)
                      : null;
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
            : widget.isImage && !widget.isVoice && !widget.isMap
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
                          widget.isCurrentUser,
                          widget.isVoice);
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
                : widget.isVoice
                    ? GestureDetector(
                        onLongPress: () {
                          RequestDialog.drop(
                              context,
                              widget.id,
                              widget.message,
                              widget.receiverID,
                              widget.isImage,
                              widget.isCurrentUser,
                              widget.isVoice);
                        },
                        child: Container(
                          margin: !widget.isCurrentUser
                              ? EdgeInsets.only(right: width / 5)
                              : null,
                          child: BubbleNormalAudio(
                            textStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
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
                      )
                    : widget.isMap
                        ? GestureDetector(
                            onTap: () async {
                              var url =
                                  "https://www.google.com/maps/@${widget.lat},${widget.long},11z";
                              var encoded = Uri.parse(url);
                              if (await canLaunchUrl(encoded)) {
                                await launchUrl(encoded);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            onLongPress: () {
                              RequestDialog.dropOther(
                                context,
                                widget.id,
                                widget.lat,
                                widget.long,
                                "",
                                "",
                                widget.receiverID,
                                widget.isMap,
                                widget.isCurrentUser,
                              );
                            },
                            child: Container(
                              height: height / 3,
                              width: width / 1.4,
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 2.5, horizontal: 25),
                              decoration: BoxDecoration(
                                color: widget.isCurrentUser
                                    ? (isDarkMode
                                        ? widget.pDarkColor
                                        : widget.pLightColor)
                                    : (isDarkMode
                                        ? widget.sDarkColor
                                        : widget.sLightColor),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: FlutterMap(
                                options: MapOptions(
                                  onTap: (TapPosition a, LatLng? s) async {
                                    var url =
                                        "https://www.google.com/maps/@${widget.lat},${widget.long},11z";
                                    var encoded = Uri.parse(url);
                                    if (await canLaunchUrl(encoded)) {
                                      await launchUrl(encoded);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  initialCenter:
                                      LatLng(widget.lat!, widget.long!),
                                  initialZoom: 10.5,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.letters',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point:
                                            LatLng(widget.lat!, widget.long!),
                                        width: width / 3,
                                        height: width / 3,
                                        child: Icon(
                                          FontAwesomeIcons.locationDot,
                                          color: Colors.red.shade600,
                                          size: width / 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : widget.isDoc
                            ? GestureDetector(
                                onTap: () async {
                                  ScaffMess.messanger(
                                      context, "Downloading", 3);
                                  FileDownloader.downloadFile(
                                      url: widget.message,
                                      name: widget.fName,
                                      onProgress: (String? fileName,
                                          double progress) {},
                                      onDownloadCompleted: (String path) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content:
                                              Text("File Saved in Downloads"),
                                        ));
                                      },
                                      onDownloadError: (String error) {
                                        RequestDialog.show(context,
                                            "An error occurred while downloading this file");
                                      });
                                },
                                onLongPress: () async {
                                  RequestDialog.dropOther(
                                    context,
                                    widget.id,
                                    null,
                                    null,
                                    widget.fName,
                                    widget.fName,
                                    widget.receiverID,
                                    widget.isMap,
                                    widget.isCurrentUser,
                                  );
                                },
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minWidth: width / 3,
                                      maxWidth: width / 1.25),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2.5, horizontal: 25),
                                    decoration: BoxDecoration(
                                      color: widget.isCurrentUser
                                          ? (isDarkMode
                                              ? widget.pDarkColor
                                              : widget.pLightColor)
                                          : (isDarkMode
                                              ? widget.sDarkColor
                                              : widget.sLightColor),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6.0),
                                          child: Icon(
                                            FontAwesomeIcons.fileInvoice,
                                            size: width / 20,
                                            color: !widget.isCurrentUser
                                                ? isDarkMode
                                                    ? Colors.white
                                                    : Colors.black
                                                : isDarkMode
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade200,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                              minWidth: width / 5,
                                              maxWidth: width / 2.5),
                                          child: Text(
                                            widget.fName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: width / 17.5),
                                          child: Icon(
                                            size: width / 16,
                                            FontAwesomeIcons.circleDown,
                                            color: !widget.isCurrentUser
                                                ? isDarkMode
                                                    ? Colors.white
                                                    : Colors.black
                                                : isDarkMode
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade200,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
      ],
    );
  }
}
