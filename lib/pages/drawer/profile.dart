// ignore_for_file: use_build_context_synchronously

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/auth/loginorregister.dart';
import 'package:letters/models/user.dart';
import 'package:letters/pages/user/lockedChats.dart';
import 'package:letters/pages/user/update.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();

  Future<User?> getUser() async {
    return await _authService.getUserInfo();
  }

  late final Future user;

  @override
  void initState() {
    super.initState();
    user = getUser();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("P R O F I L E"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
            height: height,
            width: width,
            child: FutureBuilder(
              future: user,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    "Loading",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  );
                } else if (snapshot.hasData) {
                  final data = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: height / 20),
                      GestureDetector(
                        onLongPress: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LockedChats()));
                        },
                        onDoubleTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LockedChats()));
                        },
                        onTap: () {
                          if (data.imgUrl != "") {
                            final imageProvider =
                                Image.network(data.imgUrl).image;
                            showImageViewer(context, imageProvider);
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: height / 8,
                          child: ClipOval(
                            child: data.imgUrl == ""
                                ? Image.asset("assets/profile.png")
                                : Image.network(
                                    data.imgUrl,
                                    height: height,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: height / 45),
                      ListTile(
                        leading: Text(
                          "Name : ",
                          style: TextStyle(
                              fontSize: height / 57.5,
                              fontWeight: FontWeight.bold),
                        ),
                        title: SelectableText(
                          data.name.toString(),
                          style: GoogleFonts.rubik(fontSize: height / 55),
                        ),
                      ),
                      ListTile(
                        leading: Text(
                          "Bio : ",
                          style: TextStyle(
                              fontSize: height / 57.5,
                              fontWeight: FontWeight.bold),
                        ),
                        title: SelectableText(
                          data.bio.toString(),
                          style: GoogleFonts.rubik(fontSize: height / 55),
                        ),
                      ),
                      ListTile(
                        leading: Text(
                          "Email : ",
                          style: TextStyle(
                              fontSize: height / 57.5,
                              fontWeight: FontWeight.bold),
                        ),
                        title: SelectableText(
                          data.email.toString(),
                          style: GoogleFonts.rubik(fontSize: height / 55),
                        ),
                      ),
                      SizedBox(height: height / 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: width / 2,
                            height: height / 18,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const UpdatePage()));
                              },
                              icon: Icon(
                                Icons.edit,
                                size: width / 15,
                                color: Colors.white,
                              ),
                              label: Text(
                                "UPDATE",
                                style: TextStyle(
                                    color: Colors.white, fontSize: width / 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                    side:
                                        const BorderSide(color: Colors.green)),
                                backgroundColor: Colors.green,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                }
                return Container();
              },
            )),
      ),
    );
  }
}
