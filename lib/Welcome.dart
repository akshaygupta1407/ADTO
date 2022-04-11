import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Login.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}


class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade50,       //fromRGBO(49, 53, 55, 80),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400
                  ,
                ),
                Text(
                  "Lets get Started",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.black),
                ),
                SizedBox(height: 0,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Login()));
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      // backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(255, 177, 17, 100)),
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(46, 140, 252, 100)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Sign in',style: TextStyle(fontSize: 16,),),
                    ),
                  ),
                ),
                SizedBox(height: 18,),
                // Container(
                //     child: GestureDetector(
                //       onTap: (){
                //         //add functions of this button here
                //       },
                //       child: Container(
                //         height: 50.0,
                //         decoration: BoxDecoration(
                //           gradient: LinearGradient(
                //             begin: Alignment.centerLeft,
                //             end: Alignment.centerRight,
                //             colors: [Colors.green, Colors.yellow],
                //           ),
                //           borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //         ),
                //         child: Center(
                //           child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18.0),),
                //         ),
                //       ),
                //     )
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
