// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/auth/loginorregister.dart';
import 'package:letters/pages/user/update.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        centerTitle: true,
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text("Dark Mode"),
                CupertinoSwitch(
                    value: Provider.of<ThemeProvider>(context, listen: false)
                        .isDarkMode,
                    onChanged: (f) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    }),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UpdatePage())),
            child: Container(
              width: width / 1.1,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Update User Information"),
                  Icon(
                    Icons.arrow_right,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    size: width / 10,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: width / 15),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Delete Account"),
                      content: const Text(
                          "Are you sure you want to delete your account ?"),
                      actions: [
                        MaterialButton(
                          child: const Text("NO"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        MaterialButton(
                          child: const Text(
                            "YES",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () async {
                            await _authService.deleteUser();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginOrRegister()));
                          },
                        ),
                      ],
                    );
                  });
            },
            child: Container(
              width: width / 1.1,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Delete Account",
                    style: TextStyle(
                        color:
                            isDarkMode ? Colors.redAccent : Colors.red.shade500,
                        fontSize: width / 23),
                  ),
                  Icon(
                    Icons.delete,
                    color: isDarkMode ? Colors.redAccent : Colors.red.shade500,
                    size: width / 12,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
