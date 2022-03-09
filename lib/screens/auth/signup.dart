import 'package:awareness_user/screens/app/home.dart';
import 'package:awareness_user/screens/auth/user_details.dart';

import 'package:awareness_user/services/fcm.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FCMNotification fcmNotification = FCMNotification();
  GetStorage getStorage = GetStorage();

  bool loading = false;

  Future<void> signUpUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user!.emailVerified) {
        Get.off(() => const UserDetails());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar('Error', 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar('Error', 'The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> verifyUser(String email) async {
    final data = await http
        .get(Uri.parse('https://womena.herokuapp.com/users/email/$email'));
    print(data.body);
    print(data.statusCode);
    if (data.statusCode == 404) {
      setState(() {
        loading == false;
      });
      Get.snackbar('UnAuthorized User',
          'You are not an authorized user of this app , Contact us for enquires');
    }
    if (data.statusCode == 200) {
      await signUpUser(emailController.text, passwordController.text);
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              loading
                  ? const LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      color: Colors.blue,
                    )
                  : const SizedBox(
                      height: 5,
                    ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Join Us To Start Saving',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    "Lets Create Awareness Together",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey),
                  )
                ],
              ),
              const SizedBox(
                height: 130,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.email),
                          labelText: 'Email Address',
                          hintText: 'Enter Your Email',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Password';
                        }
                        return null;
                      },
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.password),
                          labelText: 'Password',
                          hintText: 'Enter Your Phone Number',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton.icon(
                          onPressed: loading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    verifyUser(emailController.text);
                                  }
                                },
                          icon: loading
                              ? const Text('Loading')
                              : const Icon(Icons.person),
                          label: loading
                              ? const CupertinoActivityIndicator()
                              : const Text('Sign Up'),
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))))),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
