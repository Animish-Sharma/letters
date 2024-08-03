import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InputList extends StatelessWidget {
  const InputList(
      {super.key,
      required this.uploadImage,
      required this.getLocation,
      required this.uploadDoc,
      required this.uploadVideo});
  final Function uploadImage;
  final Function uploadVideo;
  final Function getLocation;
  final Function uploadDoc;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return PopupMenuButton(
      offset: Offset(0, -(27.h)),
      constraints: BoxConstraints.expand(width: width / 1.25, height: 26.5.h),
      child: TextButton.icon(
          onPressed: null,
          icon: const Icon(Icons.link),
          label: const SizedBox(width: 0, height: 0)),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
              child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await uploadImage();
                      },
                      child: CircleAvatar(
                        radius: width / 14,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.image,
                            size: width / 15, color: Colors.white),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text("Gallery"),
                    )
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await getLocation();
                      },
                      child: CircleAvatar(
                        radius: width / 14,
                        backgroundColor: Colors.amber,
                        child: Icon(FontAwesomeIcons.locationDot,
                            size: width / 15, color: Colors.white),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text("Location"),
                    )
                  ],
                ),
              ],
            ),
          )),
          PopupMenuItem(
              child: Padding(
            padding: EdgeInsets.only(top: height / 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await uploadDoc();
                      },
                      child: CircleAvatar(
                        radius: width / 14,
                        backgroundColor: Colors.blue,
                        child: Icon(FontAwesomeIcons.file,
                            size: width / 15, color: Colors.white),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text("Document"),
                    )
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await uploadVideo();
                      },
                      child: CircleAvatar(
                        radius: width / 14,
                        backgroundColor: Colors.orange,
                        child: Icon(FontAwesomeIcons.fileVideo,
                            size: width / 15, color: Colors.white),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text("Video"),
                    )
                  ],
                ),
              ],
            ),
          )),
        ];
      },
    );
  }
}
