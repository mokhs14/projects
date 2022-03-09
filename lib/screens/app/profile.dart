import 'package:awareness_user/screens/app/add_event.dart';
import 'package:awareness_user/screens/auth/login.dart';
import 'package:awareness_user/screens/auth/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Account',
        ),
        leadingWidth: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              child: ListTile(
                onTap: () {
                  Get.to(() => const AddEvent());
                },
                title: const Text('Create Event'),
                trailing: const Icon(
                  Icons.arrow_right,
                  size: 26,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              child: ListTile(
                onTap: () {
                  Get.to(() => const UserDetails());
                },
                title: const Text('Edit Profile'),
                trailing: const Icon(
                  Icons.arrow_right,
                  size: 26,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              child: ListTile(
                onTap: () {
                  Get.defaultDialog(
                      title: 'Log Out',
                      middleText: 'Do You Want To Log Out This Account ?',
                      textCancel: 'No',
                      textConfirm: 'Yes',
                      onConfirm: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => const LoginScreen());
                      });
                },
                title: const Text('Logout'),
                trailing: const Icon(
                  Icons.arrow_right,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
