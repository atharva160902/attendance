import 'package:attendance/mapscreen.dart';
import 'package:attendance/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:attendance/calendarscreen.dart';
import 'package:attendance/profilescreen.dart';
import 'package:attendance/todayscreen.dart';
import 'model/user.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = const Color(0xffeef444c);

  int currentIndex = 2;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarCheck,
    FontAwesomeIcons.check,
    FontAwesomeIcons.mapLocationDot,
    FontAwesomeIcons.userLarge,
  ];

  @override
  void initState() {
    super.initState();
    _startLocationService();
    getId().then((value){
    _getCredentials();
    _getProfilePic();
    });
  }

  void _getCredentials() async{
    try{
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("student").doc(User.id).get();
      setState((){
        User.canEdit = doc['canEdit'];
        User.firstName = doc['firstName'];
        User.lastName = doc['lastName'];
        User.birthDate = doc['birthDate'];
        User.address = doc['address'];
        User.ScholarshipName = doc['ScholarshipName'];
      });
    } catch(e) {
      return;
    }
  }

  void _getProfilePic() async{
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("student").doc(User.id).get();
    setState((){
      User.profilePicLink = doc['profilePic'];
    });
  }

  void _startLocationService() async{
    LocationService().initialize();

    LocationService().getLongitude().then((value){
      setState((){
        User.long = value!;
      });

      LocationService().getLatitude().then((value){
        setState((){
          User.lat = value!;
        });
      });
    });
  }

  Future<void> getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("student")
        .where('id', isEqualTo: User.studentId)
        .get();

    setState(() {
      User.id = snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
          children: [
            new CalendarScreen(),
            new TodayScreen(),
            new MapScreen(),
            new ProfileScreen(),
          ],
      ),
      bottomNavigationBar: Container(
        height: 65,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(const Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    child: Container(
                      height: screenHeight,
                      width: screenWidth,
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              navigationIcons[i],
                              color:
                              i == currentIndex ? primary : Colors.black54,
                              size: i == currentIndex ? 30 : 26,
                            ),
                            i == currentIndex
                                ? Container(
                              margin: EdgeInsets.only(top: 6),
                              height: 3,
                              width: 22,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(40)),
                                color: primary,
                              ),
                            )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
