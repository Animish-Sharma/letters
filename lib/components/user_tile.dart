import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final String imgUrl;
  const UserTile(
      {super.key,
      required this.text,
      required this.onTap,
      required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 12.5, horizontal: 20),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: height / 45,
              child: ClipOval(
                  child: imgUrl == ""
                      ? Image.asset("assets/profile.png", height: height)
                      : Image.network(
                          imgUrl,
                          height: height,
                        )),
            ),
            const SizedBox(width: 15),
            Text(
              text,
              style: GoogleFonts.rubik(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
