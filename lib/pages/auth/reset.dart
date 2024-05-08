// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/auth/loginorregister.dart';
import 'package:letters/components/custom_button.dart';
import 'package:letters/components/custom_textfield.dart';
import 'package:letters/pages/auth/login.dart';

class ResetPage extends StatelessWidget {
  ResetPage({super.key});
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final authService = AuthService();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
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
                padding: EdgeInsets.only(right: width / 6),
                child: const Text(
                  "*Email will only be sent to valid registered emails",
                  style: TextStyle(color: Colors.grey),
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
                                      builder: (context) => LoginOrRegister()));
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
