import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance/homescreen.dart';
import 'package:attendance/loginscreen.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'model/user.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primary = const Color(0xffeef444c);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: primary,
          onSecondary: Colors.white,
        ),
        primaryColor: const Color(0xffeef444c),
        accentColor: const Color(0xffeef444c),
      ),
      home: const KeyboardVisibilityProvider(
          child: AuthCheck(),
      ),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async{
    sharedPreferences = await SharedPreferences.getInstance();

    try{
      if(sharedPreferences.getString('StudentID') != null){
        setState((){
          User.studentId= sharedPreferences.getString('StudentID')!;
          if(User.lo==false)
          {
            userAvailable = false;
            User.lo=true;
            User.id = " ";
            User.studentId = " ";
            User.canEdit = true;
            User.firstName = " ";
            User.lastName = " ";
            User.birthDate = " ";
            User.address = " ";
            User.profilePicLink = " ";
          }
          else
          {
            userAvailable = true;
          }
        });
      }
    } catch(e){
      setState((){
        userAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userAvailable ? HomeScreen() : const LoginScreen();
  }
}

