//
//
// import 'package:flutter/material.dart';
//
// class StudentProfile extends StatelessWidget {
//   StudentProfile(this.PhotoUrl);
//   String PhotoUrl;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text("Profile"),
//       ),
//       body: Column(
//         // mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(height: 20,),
//           // Center(child: Container(child:Text("Profile",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),)),
//           SizedBox(height: 50),
//           Center(
//             child: Container(
//               child: CircleAvatar(
//                 backgroundImage:
//                 NetworkImage(
//                     "$PhotoUrl",
//                 ),
//                 radius: 80,
//                 backgroundColor: Colors.red,
//
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
