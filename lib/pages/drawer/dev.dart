import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DevPage extends StatelessWidget {
  const DevPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text("About Dev"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: height / 20),
            CircleAvatar(
              backgroundImage: const AssetImage("assets/dev.jpg"),
              radius: width / 4,
            ),
            SizedBox(height: height / 40),
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: <AnimatedText>[
                TypewriterAnimatedText(
                  'Animish Sharma',
                  textStyle: GoogleFonts.poppins(fontSize: width / 15),
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  '@ciriousdev',
                  textStyle: GoogleFonts.poppins(fontSize: width / 15),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
            ),
            SizedBox(height: height / 80),
            SizedBox(
              width: width / 1.1,
              child: SelectableText(
                "Hello There! \nI'm Animish Sharma, a 18-year-old student. Education and sports are my passion, and I'm fortunate enough to excel in both fields. I believe in the power of knowledge and constantly strive to expand my horizons. Solving complex problems and understanding the intricacies of various subjects fuel my curiosity for learning. Beyond the classroom, you can often find me on the sports field, where I feel alive and energized. Sportsmanship and teamwork are values that I hold close to my heart, and I believe they complement my academic pursuits. I hope to inspire others to follow their passions and dreams, just as I am doing. Thank you for visiting my page, and I hope you enjoy exploring my world!",
                style: GoogleFonts.inter(fontSize: height / 60),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: height / 30),
            GestureDetector(
              onTap: () async {
                const url = "https://www.instagram.com/animishxsharma";
                var encoded = Uri.parse(url);
                if (await canLaunchUrl(encoded)) {
                  await launchUrl(encoded,
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5.0),
                width: width / 1.7,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: isDarkMode ? Colors.blue : Colors.lightBlue),
                    borderRadius: BorderRadius.circular(3)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message,
                      color: Colors.blue,
                      size: width / 12,
                    ),
                    Text(
                      "    Contact Dev",
                      style: GoogleFonts.poppins(
                          fontSize: width / 20,
                          color: isDarkMode
                              ? Colors.blue.shade300
                              : Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
