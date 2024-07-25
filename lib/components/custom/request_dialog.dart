// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/components/custom/scaff_mess.dart';
import 'package:letters/services/chat/chat_service.dart';
import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDialog {
  static show(BuildContext context, String error) {
    Widget okButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("OK"),
    );

    AlertDialog alertDialog = AlertDialog(
      title: const Text("An Error Occurred"),
      content: Text(error),
      actions: <Widget>[okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return alertDialog;
      },
    );
  }

  static resetPass(BuildContext context, String email) {
    Widget okButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text("OK"),
    );

    AlertDialog alertDialog = AlertDialog(
      title: const Text("Email Sent Successfully"),
      content: Text(
          "An email on $email has been sent with a link to reset password"),
      actions: <Widget>[okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return alertDialog;
      },
    );
  }

  static drop(BuildContext context, String id, String message,
      String receiverID, bool isImg, bool isCurrentUser, bool isVoice) {
    final title =
        message.contains("firebasestorage") ? "Image / Voice" : message;

    final height = MediaQuery.of(context).size.height;
    final chatService = ChatService();
    downloadImg(String url) async {
      final http.Response response = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final filename =
          '${dir.path}/LetterImage-${DateTime.now().microsecondsSinceEpoch}.png';
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);
      if (finalPath != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            showCloseIcon: true, content: Text("Image saved to gallery")));
      }
    }

    AlertDialog dropdown = AlertDialog(
      backgroundColor: const Color(0xff1e1e24),
      title: SizedBox(
          height: height / 30,
          child: Text(title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(color: Colors.white))),
      actions: <Widget>[
        !isVoice
            ? ListTile(
                mouseCursor: SystemMouseCursors.click,
                onTap: () async {
                  !isImg
                      ? await Clipboard.setData(ClipboardData(text: message))
                          .then((_) => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  showCloseIcon: true,
                                  content:
                                      Text("Message copied to clipboard"))))
                      : (
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  showCloseIcon: true,
                                  content: Text("Downloading Image"))),
                          downloadImg(message)
                        );
                  Navigator.of(context).pop();
                },
                title: Text(!isImg ? "Copy Message" : "Download Image",
                    style: GoogleFonts.roboto(color: Colors.white)),
              )
            : const SizedBox(height: 0, width: 0),
        !isVoice && !isImg ? ListTile(
          onTap: () async {
            final translator = GoogleTranslator();
            Navigator.of(context).pop();
            final res = await translator.translate(message, to: "en");
            showBottomSheet(context: context, builder: (context)=> Container(
              child: Column(children: [
                SizedBox(height: height / 80),
                Center(
                  child: Text("Translation",style: TextStyle(fontSize: height / 30),),
                ),
                SizedBox(height: height / 40),
                Text("Text: $message",style: TextStyle(fontSize: height / 45),),
                const Divider(),
                Text("Translation: ${res.text}",style: TextStyle(fontSize: height / 45),)
              ],),
            ),constraints: BoxConstraints(maxHeight: height / 4.75));
          },
          title: Text("Translate",style: GoogleFonts.roboto(color: Colors.white)),
        ) : const SizedBox(height: 0, width: 0),
        isCurrentUser
            ? ListTile(
                mouseCursor: SystemMouseCursors.click,
                onTap: () async {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Deleting Message"),
                    ),
                  );
                  await chatService.deleteMessage(id, receiverID);
                },
                title: Text("Delete Message",
                    style: GoogleFonts.roboto(color: Colors.white)),
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Back",
              style: GoogleFonts.inter(color: Colors.blue.shade300),
            ))
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return dropdown;
      },
    );
  }

  static dropOther(
      BuildContext context,
      String id,
      double? lat,
      double? long,
      String? fName,
      String? url,
      String receiverID,
      bool isMap,
      bool isCurrentUser) {
    final title = isMap ? "Location" : "Document";

    final height = MediaQuery.of(context).size.height;
    final chatService = ChatService();

    AlertDialog dropdown = AlertDialog(
      backgroundColor: const Color(0xff1e1e24),
      title: SizedBox(
          height: height / 30,
          child: Text(title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(color: Colors.white))),
      actions: <Widget>[
        ListTile(
          mouseCursor: SystemMouseCursors.click,
          onTap: () async {
            if (isMap) {
              var url = "https://www.google.com/maps/@$lat,$long,11z";
              var encoded = Uri.parse(url);
              if (await canLaunchUrl(encoded)) {
                await launchUrl(encoded);
              } else {
                throw 'Could not launch $url';
              }
            } else {
              ScaffMess.messanger(context, "Downloading", 3);
              FileDownloader.downloadFile(
                  url: url!,
                  name: fName!,
                  onProgress: (String? fileName, double progress) {},
                  onDownloadCompleted: (String path) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("File Saved in Downloads"),
                    ));
                  },
                  onDownloadError: (String error) {
                    RequestDialog.show(context,
                        "An error occurred while downloading this file");
                  });
            }
            Navigator.of(context).pop();
          },
          title: Text(isMap ? "Open in Google Maps" : "Download Document",
              style: GoogleFonts.roboto(color: Colors.white)),
        ),
        isCurrentUser
            ? ListTile(
                mouseCursor: SystemMouseCursors.click,
                onTap: () async {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Deleting Message"),
                    ),
                  );
                  await chatService.deleteMessage(id, receiverID);
                },
                title: Text("Delete Message",
                    style: GoogleFonts.roboto(color: Colors.white)),
              )
            : const SizedBox(
                height: 0,
                width: 0,
              ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Back",
              style: GoogleFonts.inter(color: Colors.blue.shade300),
            ))
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return dropdown;
      },
    );
  }
}
