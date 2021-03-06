import 'package:awareness_user/models/event.dart';
import 'package:awareness_user/screens/app/event_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UpcomingEvents extends StatefulWidget {
  const UpcomingEvents({Key? key}) : super(key: key);

  @override
  State<UpcomingEvents> createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  List<Event> events = [];
  bool loading = false;

  Future<void> getEvents() async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot ref = await FirebaseFirestore.instance
          .collection('events')
          .where('status', isEqualTo: 'Approved')
          .get();
      events.clear();
      for (var i = 0; i < ref.docs.length; i++) {
        Event event = Event(
          venue: ref.docs[i]['venue'],
          images: ref.docs[i]['images'],
          uid: ref.docs[i]['uid'],
          did: ref.docs[i].id,
          title: ref.docs[i]["title"],
          status: ref.docs[i]["status"],
          startTime: DateTime.parse(
            ref.docs[i]["start_time"],
          ),
        );
        events.add(event);
      }
    } catch (e) {
      print(e);
      Get.snackbar("Oops...", "Unable to get events");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getEvents,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter

            // Loader
            loading == true
                ? const LinearProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : const SizedBox(height: 5),

            // Event List
            Expanded(
              child: events.isEmpty
                  ? const Center(child: Text('No events found.'))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => Get.to(() => EventDetails(
                              eventId: events[index].did!,
                              userId: events[index].uid!)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                                color: Colors.white,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                elevation: 2,
                                shadowColor: Colors.grey,
                                child: Column(
                                  children: [
                                    SizedBox(
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8)),
                                          child: Image(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                                events[index].images.first),
                                          ),
                                        )),
                                    ListTile(
                                      title: Text(
                                        events[index].title!.toUpperCase(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(events[index].venue!),
                                              const Icon(
                                                Icons.location_pin,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat.jm().format(
                                                  (events[index].startTime!),
                                                ),
                                                style: TextStyle(
                                                  color: Colors.blue
                                                      .withOpacity(0.7),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Text(
                                                DateFormat.yMMMMd().format(
                                                    (events[index].startTime!)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        );
                      }),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
