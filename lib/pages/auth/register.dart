import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/custom/custom_button.dart';
import 'package:letters/components/custom/custom_textfield.dart';
import 'package:letters/pages/home.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class Register extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _cpwController = TextEditingController();
  final void Function()? onTap;
  Register({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final authService = AuthService();
    void register(BuildContext context) async {
      if (_pwController.text == _cpwController.text) {
        try {
          await authService.signUpWithEmailandPassword(
              _nameController.text, _emailController.text, _pwController.text);
          if (FirebaseAuth.instance.currentUser != null) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()));
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text("Login Failed for some reason"),
                    ));
          }
        } catch (e) {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => AlertDialog(
              title: Text(e.toString()),
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3))),
            title: Text("Passwords don't match"),
          ),
        );
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
                  ? [const Color(0xff6DD5FA), const Color(0xffffffff)]
                  : [const Color(0xffc9184a), const Color(0xffffccd5)],
            ),
          ),
          height: height,
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/register.png",
                width: width / 1.5,
              ),
              Text(
                "Get Started !",
                style: GoogleFonts.playfairDisplay(
                  fontSize: width / 9,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Name",
                icon: const Icon(Icons.person),
                isPass: false,
                controller: _nameController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Email",
                icon: const Icon(Icons.email),
                isPass: false,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Password",
                icon: const Icon(Icons.password),
                isPass: true,
                controller: _pwController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: "Confirm Password",
                icon: const Icon(Icons.password_rounded),
                isPass: true,
                controller: _cpwController,
              ),
              const SizedBox(height: 30.0),
              CustomButton(
                buttonText: "Register",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.grey.shade900,
                    duration: const Duration(seconds: 2),
                    content: const Row(
                      children: <Widget>[
                        CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                        Text("  Signing-In...")
                      ],
                    ),
                  ));
                  register(context);
                },
                btn_color: Colors.purpleAccent.shade700,
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account ? "),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Login",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
