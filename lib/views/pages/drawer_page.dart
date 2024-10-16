import 'package:chat_app/utils/helpers/auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDrawer extends StatefulWidget {
  final User user;

  const MyDrawer({super.key, required this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.user.isAnonymous
                    ? 'Guest User'
                    : (widget.user.displayName ?? 'No Username'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              accountEmail: !widget.user.isAnonymous
                  ? Text(widget.user.email ?? 'No Email')
                  : null,
              currentAccountPicture: CircleAvatar(
                radius: 40,
                backgroundImage: (widget.user.isAnonymous)
                    ? const AssetImage('assets/images/default_avatar.png')
                    : (widget.user.photoURL == null)
                        ? const AssetImage('assets/images/default_avatar.png')
                        : NetworkImage(widget.user.photoURL!),
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
              ),
            ),
            ListTile(
              leading: Icon(
                isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                color: Colors.blue,
              ),
              title: Text(
                isDarkTheme ? 'Dark Theme' : 'Light Theme',
                style: const TextStyle(fontSize: 18),
              ),
              trailing: Switch(
                value: isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    isDarkTheme = value;
                  });
                  Get.changeTheme(
                      isDarkTheme ? ThemeData.dark() : ThemeData.light());
                },
              ),
            ),
            const Spacer(),
            ListTile(
              title: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                bool? confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );
                if (confirmLogout == true) {
                  await AuthHelper.authHelper.sighOutUser();
                  Get.offAndToNamed('sign_in_page');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
