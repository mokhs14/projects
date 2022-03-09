import 'package:awareness_user/screens/app/home.dart';
import 'package:awareness_user/screens/auth/otp.dart';
import 'package:awareness_user/screens/auth/signup.dart';
import 'package:awareness_user/screens/auth/user_details.dart';
import 'package:awareness_user/services/fcm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FCMNotification fcmNotification = FCMNotification();
  GetStorage getStorage = GetStorage();

  bool loading = false;

  Future<void> userSignIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user!.emailVerified) {
        Get.to(() => const Home());
        setState(() {
          loading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });
      if (e.code == 'user-not-found') {
        Get.snackbar('Error', 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Get.snackbar('Error', 'Wrong password provided for the user.');
      }
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
                      color: Color(0xFF29357c),
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
                          return 'Please enter your email';
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
                      obscureText: true,
                      decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.password),
                          labelText: 'Password',
                          hintText: 'Enter Your Password',
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
                                    setState(() {
                                      loading = true;
                                      userSignIn(emailController.text,
                                          passwordController.text);
                                    });
                                  }
                                },
                          icon: loading
                              ? const Text('Loading')
                              : const Icon(Icons.person),
                          label: loading
                              ? const CupertinoActivityIndicator()
                              : const Text('Login'),
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))))),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('or'),
                    TextButton(
                        onPressed: () {
                          Get.to(() => const SignUpScreen());
                        },
                        child: const Text('Sign Up'))
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
