import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/loginorregister.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:page_transition/page_transition.dart';

class ChoosePage extends StatefulWidget {
  const ChoosePage({super.key});

  @override
  State<ChoosePage> createState() => _ChoosePageState();
}

class _ChoosePageState extends State<ChoosePage> {
  bool isOffline = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InternetConnectivityListener(
      connectivityListener: (BuildContext context, bool hasInternetAccess) {
        if (hasInternetAccess) {
          setState(() {
            isOffline = true;
          });
        } else {
          setState(() {
            isOffline = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xff462972),
        body: SingleChildScrollView(
          child: Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/chooseBack.png"),
                    fit: BoxFit.fitHeight)),
            child: Column(
              children: !isOffline
                  ? <Widget>[
                      SizedBox(height: height / 4),
                      Text(
                        "You are \n Offline",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: width / 6,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: height / 50),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width / 10),
                        child: Text(
                          "You are offline as of right now, please connect to an internet connection to continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: width / 22),
                        ),
                      )
                    ]
                  : <Widget>[
                      SizedBox(height: height / 8),
                      Center(
                        child: CircleAvatar(
                          radius: width / 10,
                          backgroundImage: Image.asset(
                            "assets/chat.jpg",
                          ).image,
                        ),
                      ),
                      SizedBox(height: height / 20),
                      Container(
                        margin: EdgeInsets.only(left: width / 20),
                        child: Image.asset(
                          "assets/snippet.png",
                          height: height / 3,
                        ),
                      ),
                      SizedBox(height: height / 30),
                      Text(
                        "Letters",
                        style: GoogleFonts.poppins(
                            fontSize: width / 7,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Center(
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: <AnimatedText>[
                            TyperAnimatedText(
                              "Let's Change the World",
                              textStyle: GoogleFonts.poppins(
                                  fontSize: width / 18, color: Colors.white),
                              speed: const Duration(milliseconds: 75),
                            ),
                            TyperAnimatedText(
                              'Change the way you -',
                              textStyle: GoogleFonts.poppins(
                                  fontSize: width / 18, color: Colors.white),
                              speed: const Duration(milliseconds: 75),
                            ),
                            TyperAnimatedText(
                              '- talk to your loved ones',
                              textStyle: GoogleFonts.poppins(
                                  fontSize: width / 18, color: Colors.white),
                              speed: const Duration(milliseconds: 75),
                            ),
                            TyperAnimatedText(
                              '',
                              textStyle: GoogleFonts.poppins(
                                  fontSize: width / 18, color: Colors.white),
                              speed: const Duration(milliseconds: 75),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height / 18),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: const LoginOrRegister(),
                          ),
                        ),
                        child: Container(
                          width: width / 6.2,
                          height: width / 6.2,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                            FontAwesomeIcons.arrowRight,
                            size: width / 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: height / 20),
                      Text(
                        "Made with ❤️ by Animish Sharma",
                        style: GoogleFonts.rubik(color: Colors.white),
                      )
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
