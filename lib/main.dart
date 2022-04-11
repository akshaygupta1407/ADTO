// @dart=2.9
import 'package:adto/GoogleSignIn.dart';
import 'package:adto/Welcome.dart';
import 'package:adto/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'College/details.dart';
import 'Login.dart';
import 'package:flutter/services.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,home: Login(),
  // HomeGoogle(),
  // email==null ? Welcome() : Details1()
  )
  );
}

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//
//     return MaterialApp(
//       title: 'Auto',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home:
//       // Welcome(),
//       Details1(),
//       //Login(),
//       // Home(),
//     );
//   }
// }