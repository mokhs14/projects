import 'dart:io';
import 'package:awareness_user/screens/app/home.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({Key? key}) : super(key: key);
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  bool loading = false;

  final ref = FirebaseFirestore.instance
      .collection('users')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

  final nameController = TextEditingController();

  final phoneController = TextEditingController();

  XFile? _image;

  final _picker = ImagePicker();

  void _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _cropImage(filePath) async {
    File? croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      maxWidth: 1080,
      maxHeight: 1080,
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                children: [
                  Stack(children: [
                    Container(
                      color: Colors.blue,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                    ),
                    Positioned(
                      top: 170,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          'Fill in with your Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: const [
                            Text('All fields are manditory ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey,
                                    letterSpacing: 0.5)),
                            Text('*',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.red))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.defaultDialog(
                                  title: 'Choose Photo',
                                  content: Column(
                                    children: [
                                      ListTile(
                                        title: const Text('Camera'),
                                        leading: const Icon(Icons.camera),
                                        onTap: () {
                                          _imgFromCamera();
                                          Get.back();
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Gallery'),
                                        leading: const Icon(Icons.photo_album),
                                        onTap: () {
                                          _imgFromGallery();
                                          Get.back();
                                        },
                                      ),
                                    ],
                                  ));
                            },
                            child: CircleAvatar(
                              radius: 50,
                              child: _image != null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                      child: Image.file(
                                        File(_image!.path),
                                        height: 110,
                                        width: 110,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter Your Name',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        controller: phoneController,
                        decoration: const InputDecoration(
                            labelText: 'Ph No.',
                            hintText: 'Enter Your Phone Number',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 60,
                child: ElevatedButton.icon(
                    onPressed: () {
                      if (_image == null) {
                        Get.snackbar("Image Can't Be Empty !",
                            "Please Upload an Image to continue");
                      } else if (_formKey.currentState!.validate()) {
                        Get.defaultDialog(
                          title: 'Update Details',
                          content: const Text('Add Details to Account ?'),
                          textConfirm: 'Yes',
                          confirmTextColor: Colors.white,
                          cancelTextColor: Colors.black,
                          onConfirm: () async {
                            setState(() {
                              loading = true;
                            });
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            Get.back();
                            TaskSnapshot image = await FirebaseStorage.instance
                                .ref(
                                    'userProfileImages/${UniqueKey().toString() + _image!.name}')
                                .putFile(File(_image!.path));
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                              'email': FirebaseAuth.instance.currentUser!.email,
                              'profile_img': await image.ref.getDownloadURL(),
                              'name': nameController.text,
                              'phone': phoneController.text,
                              'uid': uid,
                            }).whenComplete(() => setState(() {
                                      _image = null;
                                      nameController.clear();

                                      Get.offAll(() => const Home());
                                      setState(() {
                                        loading = false;
                                      });
                                    }));
                          },
                          textCancel: 'No',
                        );
                      }
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('Proceed'),
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
