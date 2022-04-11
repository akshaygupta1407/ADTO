import 'package:adto/College/details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
enum LoginScreen {
  SHOW_MOBILE_ENTER_WIDGET,
  SHOW_OTP_FORM_WIDGET,
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  LoginScreen currentState = LoginScreen.SHOW_MOBILE_ENTER_WIDGET;
  TextEditingController  phoneController = TextEditingController();
  TextEditingController  otpController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationID = "";
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String mobileNumber = "";
  // CollectionReference users = FirebaseFirestore.instance.collection('users');



  void signInWithPhoneAuthCred(AuthCredential phoneAuthCredential) async
  {

    try {
      final authCred = await _auth.signInWithCredential(phoneAuthCredential);

      if(authCred.user != null)
      {
        // await users.add({
        //   'MobileNumber' : mobileNumber,
        // });
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Details1()));
        SharedPreferences prefs =
        await SharedPreferences.getInstance();
        prefs.setString('email', mobileNumber);
      }
    } on FirebaseAuthException catch (e) {

      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Some Error Occured. Try Again Later')));
    }
  }


  showMobilePhoneWidget(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: isLoading ? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          CircularProgressIndicator(color:Color.fromRGBO(46, 140, 252, 100) ,),
          Text('Loading...'),
        ],
      )) : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            "Verify your Phone Number",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 7,
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                // enabledBorder: const OutlineInputBorder(
                //   // width: 0.0 produces a thin "hairline" border
                //   borderSide: const BorderSide(color:Colors.black, width: 0.0),
                //     b
                // ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(46, 140, 252, 100), width: 2.0),
                      borderRadius: BorderRadius.circular(12),
                  ),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: Color.fromRGBO(46, 140, 252, 100),),),
                  hintText: "91+  Enter Your PhoneNumber"),
              onChanged: (value){
                  mobileNumber = value;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // ElevatedButton(onPressed: (){}, child: Text("Send OTP"),),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(46, 100, 252, 100)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),),
                ),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await _auth.verifyPhoneNumber(
                      phoneNumber: "+91${phoneController.text}",
                      verificationCompleted: (phoneAuthCredential) async {
                      },
                      verificationFailed: (verificationFailed) {
                        print(verificationFailed);
                      },
                      codeSent: (verificationID, resendingToken) async {
                        setState(() {
                          currentState = LoginScreen.SHOW_OTP_FORM_WIDGET;
                          this.verificationID = verificationID;
                        });
                      },
                      codeAutoRetrievalTimeout: (verificationID) async {});
                },
                child: Text("Send OTP")),
          ),
          SizedBox(
            height: 16,
          ),
          Spacer(),
        ],
      ),
    );
  }

  showOtpFormWidget(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            "Enter your OTP",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 7,
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(46, 100, 252, 100), width: 2.0),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: "Enter Your OTP"),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(46, 100, 252, 100)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),),
                ),

                onPressed: () {

              AuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otpController.text);
              signInWithPhoneAuthCred(phoneAuthCredential);
            }, child: Text("Verify")),
          ),
          SizedBox(
            height: 16,
          ),
          Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentState == LoginScreen.SHOW_MOBILE_ENTER_WIDGET
          ? showMobilePhoneWidget(context)
          : showOtpFormWidget(context),
    );
  }

}
