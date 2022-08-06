import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:attendance/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  String birth = "Date of birth";

  late SharedPreferences sharedPreferences;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ScholarshipNameController = TextEditingController();

  void pickUploadProfilePic() async{
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    Reference ref = FirebaseStorage.instance
        .ref().child("${User.studentId.toLowerCase()}_profilepic.jpg");
    
    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState((){
        User.profilePicLink = value;
      });
      await FirebaseFirestore.instance.collection("student").doc(User.id).update({
        'profilePic': value,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                pickUploadProfilePic();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 80, bottom: 24),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: primary,
                ),
                child: Center(
                  child: User.profilePicLink == " " ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 80,
                  ) : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(User.profilePicLink),
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Text(
                  "Student ${User.studentId}",
                  style: const TextStyle(
                    fontFamily: "BebasNeue-Bold",
                    fontSize: 18,
                  ),
                ),
            ),
            const SizedBox(height: 24,),
            User.canEdit ? textField("First Name","First name",firstNameController) : field("First Name",User.firstName),
            User.canEdit ? textField("Last Name","Last name",lastNameController) : field("Last Name",User.lastName),
            User.canEdit ? GestureDetector(
              onTap: (){
                showDatePicker(context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    builder: (context, child){
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: primary,
                            secondary: primary,
                            onSecondary: Colors.white,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                                primary: primary,
                            ),
                          ),
                          textTheme: const TextTheme(
                            headline4: TextStyle(
                              fontFamily: "BebasNeue-Bold",
                            ),
                            overline:  TextStyle(
                              fontFamily: "BebasNeue-Bold",
                            ),
                            button:  TextStyle(
                              fontFamily: "BebasNeue-Bold",
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    }
                ).then((value){
                  setState((){
                    birth = DateFormat("MM/dd/yyyy").format(value!);
                  });
                });
              },
              child: field("Date of Birth", birth),
            ): field("Date of Birth", User.birthDate),
            User.canEdit ? textField("Address","Address",addressController) : field("Address",User.address),
            User.canEdit ? textField("Scholarship Name","Scholarship Name",ScholarshipNameController) : field("Scholarship Name",User.ScholarshipName),
            User.canEdit ? GestureDetector(
              onTap: () async{
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String birthDate = birth;
                String address = addressController.text;
                String ScholarshipName = ScholarshipNameController.text;
                
                if(User.canEdit){
                  if(firstName.isEmpty) {
                    showSnackBar("Please enter your first name!");
                  } else if(lastName.isEmpty){
                    showSnackBar("Please enter your last name!");
                  } else if(birthDate.isEmpty){
                    showSnackBar("Please enter your birth date!");
                  } else if(address.isEmpty){
                    showSnackBar("Please enter your address!");
                  } else if(ScholarshipName.isEmpty){
                    showSnackBar("Please enter your scholarship name!");
                  } else{
                    await FirebaseFirestore.instance.collection("student").doc(User.id).update({
                      'firstName': firstName,
                      'lastName': lastName,
                      'birthDate': birthDate,
                      'address':  address,
                      'ScholarshipName': ScholarshipName,
                      'canEdit': false,
                    }).then((value) {
                      setState((){
                        User.canEdit = false;
                        User.firstName = firstName;
                        User.lastName = lastName;
                        User.birthDate = birthDate;
                        User.address = address;
                        User.ScholarshipName = ScholarshipName;
                      });
                    });
                  }
                } else {
                  showSnackBar("You can't edit anymore, please contact support team.");
                }
              },
              child: Container(
                height: kToolbarHeight,
                width: screenWidth,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: primary,
                ),
                child: const Center(
                  child: Text(
                    "SAVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "BebasNeue-Bold",
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ) : const SizedBox(),
            GestureDetector(
              onTap: () async{
                await FirebaseFirestore.instance.collection("student").doc(User.id).update({
                  'lo': false,
                }).then((value) {
                  setState((){
                    User.lo= false;
                  });
                });
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context)=> const MyApp()),
                );
              },
              child: Container(
                height: kToolbarHeight,
                width: screenWidth,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: primary,
                ),
                child: const Center(
                  child: Text(
                    "LOGOUT",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "BebasNeue-Bold",
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget field(String title, String text){
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "BebasNeue-Bold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black54,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black54,
                fontFamily: "BebasNeue-Bold",
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textField(String title, String hint, TextEditingController controller){
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "BebasNeue-Bold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black54,
                fontFamily: "BebasNeue-Bold",
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String text){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            text,
        ),
      ),
    );
  }
}
