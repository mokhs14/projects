import 'package:awareness_user/screens/app/event_tile.dart';
import 'package:awareness_user/screens/app/upcoming_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  String? userName;

  Future<void> getFirebaseUserData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      var data = value.docs[0].data();
      setState(() {
        userName = data['name'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getFirebaseUserData();
  }

  final List<Tab> myTabs = <Tab>[
    const Tab(
      child: Text('Upcoming Events'),
    ),
    const Tab(
      child: Text(
        'Your Events',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          elevation: 0.5,
          toolbarHeight: 80,
          bottom: TabBar(
            tabs: myTabs,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2, top: 5),
                child: Text(
                  'Hello,  $userName',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Text(
                  DateFormat.yMMMMEEEEd().format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [UpcomingEvents(), EventTile()],
        ),
      ),
    );
  }
}
