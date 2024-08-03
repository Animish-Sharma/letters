// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/auth/loginorregister.dart';
import 'package:letters/components/custom/custom_button.dart';
import 'package:letters/components/custom/custom_textfield.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ResetPage extends StatelessWidget {
  ResetPage({super.key});
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final authService = AuthService();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: !isDarkMode
                  ? [const Color(0xFFc2e59c), const Color(0xff64b3f4)]
                  : [const Color(0xff6369D1), const Color(0xffc77dff)],
            ),
          ),
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/reset.png", width: width),
              SizedBox(height: height / 20),
              Text(
                "Reset Password",
                style: GoogleFonts.playfairDisplay(fontSize: height / 25),
              ),
              SizedBox(height: height / 30),
              CustomTextField(
                hintText: "Email",
                icon: const Icon(Icons.email_outlined),
                isPass: false,
                controller: _emailController,
              ),
              Padding(
                padding: EdgeInsets.only(right: width / 6, left: width / 50),
                child: Text(
                  "*Email will only be sent to valid registered emails",
                  style: TextStyle(
                      color: !isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300),
                ),
              ),
              SizedBox(height: height / 20),
              CustomButton(
                buttonText: "Send Email",
                btn_color: Colors.green,
                onTap: () async {
                  if (_emailController.text.isNotEmpty) {
                    await authService
                        .resetPassword(_emailController.text.trim());
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3))),
                        title: const Text("Email Sent"),
                        content: Text(
                            "Email with a link is sent to ${_emailController.text.trim()}. Click on the link and reset your password from there."),
                        actions: [
                          MaterialButton(
                            child: const Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginOrRegister()));
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3))),
                        title: Text("Email cannot be empty"),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: height / 15),
            ],
          ),
        ),
      ),
    );
  }
}
