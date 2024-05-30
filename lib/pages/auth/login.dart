// ignore_for_file: unnecessary_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/custom/custom_button.dart';
import "package:letters/components/custom/custom_textfield.dart";
import 'package:letters/pages/auth/reset.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final void Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    double height = MediaQuery.of(context).size.height;
    void login(BuildContext context) async {
      final authServivce = AuthService();

      try {
        await authServivce.signInWithEmailandPassword(
            _emailController.text.trim(), _pwController.text);
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(e.toString()),
                ));
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: !isDarkMode
                  ? [const Color(0xFFff6e7f), const Color(0xffbfe9ff)]
                  : [const Color(0xffbdc3c7), const Color(0xff2c3e50)],
            ),
          ),
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/login.png", width: width),
              Text(
                "Welcome Back !",
                style: GoogleFonts.playfairDisplay(
                  fontSize: width / 9,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              SizedBox(height: height / 35),
              CustomTextField(
                hintText: "Email",
                icon: const Icon(Icons.email_outlined),
                isPass: false,
                controller: _emailController,
              ),
              const SizedBox(height: 25),
              CustomTextField(
                hintText: "Password",
                isPass: true,
                icon: const Icon(Icons.password),
                controller: _pwController,
              ),
              const SizedBox(height: 30.0),
              CustomButton(
                buttonText: "Login",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.grey.shade900,
                    duration: const Duration(seconds: 2),
                    content: Row(
                      children: <Widget>[
                        const CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                        Text("  Signing-In...",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.background,
                            ))
                      ],
                    ),
                  ));
                  Future.delayed(const Duration(milliseconds: 50), () {
                    login(context);
                  });
                },
                btn_color: const Color(0xff8338ec),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Doesn't have an account ? "),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Register",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: !isDarkMode
                            ? Colors.purple.shade600
                            : Colors.blue.shade300,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Forgot your password ? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ResetPage()));
                    },
                    child: Text(
                      "Reset Password",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: !isDarkMode
                            ? Colors.purple.shade600
                            : Colors.blue.shade300,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
