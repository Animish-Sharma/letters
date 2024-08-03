import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class VideoCallPage extends StatefulWidget {
  VideoCallPage({super.key, required this.receiverName, required this.imgUrl});
  String receiverName;
  String imgUrl;

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  String randomNumber = Random().nextInt(1000000000).toString();
  bool isMicOn = true;
  bool isSpeakerOn = true;
  @override
  Widget build(BuildContext context) {
    String status = "Calling ${widget.receiverName}....";
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Call",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff2c374c),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey.shade300),
          height: height,
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: height / 50),
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.inter(fontSize: width / 15),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height / 200),
                child: Text(
                  "Call ID #$randomNumber",
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.inter(
                      fontSize: width / 30, color: Colors.grey),
                ),
              ),
              SizedBox(height: height / 7),
              ClipOval(
                child: Container(
                  height: height / 4,
                  width: height / 4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: NetworkImage(widget.imgUrl),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.receiverName,
                  style: GoogleFonts.rubik(
                      fontSize: width / 15,
                      fontWeight: FontWeight.w100,
                      color: isDarkMode ? Colors.grey : Colors.grey.shade800),
                ),
              ),
              SizedBox(height: height / 4.6),
              Container(
                width: width / 1.15,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Color(0xff1b263b),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMicOn = !isMicOn;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xff778da9)),
                        child: Icon(
                          isMicOn ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.red),
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSpeakerOn = !isSpeakerOn;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xff778da9)),
                        child: Icon(
                          !isSpeakerOn ? Icons.phone : Icons.volume_up_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
