import 'package:flutter/material.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/pages/drawer/dev.dart';
import 'package:letters/pages/drawer/profile.dart';
import 'package:letters/pages/drawer/search.dart';
import 'package:letters/pages/drawer/settings.dart';
import 'package:letters/themes/theme_provider.dart';
import "package:provider/provider.dart";

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void logout() async {
      final authService = AuthService();

      await authService.signOut();
    }

    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: <Widget>[
          SizedBox(height: height / 12),
          Container(
            padding: const EdgeInsets.only(top: 25),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.message,
                    size: width / 5,
                    color: isDarkMode
                        ? Colors.blue.shade300
                        : Colors.blue.shade500,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: height / 15),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              onTap: () {
                Navigator.of(context).pop();
              },
              title: Text(
                "H O M E",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500),
              ),
              leading: const Icon(Icons.home, color: Colors.grey),
            ),
          ),
          SizedBox(height: height / 80),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SearchPage()));
              },
              title: Text(
                "S E A R C H",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500),
              ),
              leading: const Icon(Icons.search, color: Colors.grey),
            ),
          ),
          SizedBox(height: height / 80),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProfilePage()));
              },
              title: Text(
                "P R O F I L E",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500),
              ),
              leading: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
          SizedBox(height: height / 80),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
              title: Text(
                "S E T T I N G S",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500),
              ),
              leading: const Icon(Icons.settings, color: Colors.grey),
            ),
          ),
          SizedBox(height: height / 80),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const DevPage()));
              },
              title: Text(
                "D E V E L O P E R",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500),
              ),
              leading: const Icon(Icons.grid_view, color: Colors.grey),
            ),
          ),
          SizedBox(height: height / 3.5),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              onTap: logout,
              title: Text(
                "L O G O U T",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500),
              ),
              leading: const Icon(Icons.logout, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
