import 'dart:async';
// import 'dart:io';
import 'package:adto/Welcome.dart';
import 'package:adto/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:math';

class Home extends StatefulWidget {
  String mobileNumber = "";

  // Home({required this.mobileNumber});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String text1 = "Start";
  String text2 = "Stop";
  String text = "Start";
  int number = 1;
  String? image;
  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  bool _isListenLocation = false, _isGetLocation = false;
  String currentLatitude = "", currentLongitude = "";
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('users');
  // Stream<List<Details>> readData() => FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) =>
  // snapshot.docs.map((doc) => Details.fromJson(doc.data())).toList());

  Future<void> getData() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionRef.get();
    // // Get data from docs and convert map to List
    final allData = querySnapshot.docs
        .map((doc) => Details.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    //querySnapshot.docs.map((doc) => doc.data()).toList();
    // dataList = querySnapshot.docs.map((doc) => Details.fromJson(doc.data() as Map<String, dynamic>)).toList();
    int j = 0;
    int rowsEffected = await DatabaseHelper.instance.delete();
    print(rowsEffected);
    while (j < allData.length) {
      // print(allData[j].Latitude);
      // print('\n');
      int i = await DatabaseHelper.instance.insert({
        DatabaseHelper.columnLatitude: allData[j].Latitude,
        DatabaseHelper.columnLongitude: allData[j].Longitude,
        DatabaseHelper.columnDistance: allData[j].Distance,
        DatabaseHelper.columnStartTime: allData[j].StartTime,
        DatabaseHelper.columnEndTime: allData[j].EndTime,
        DatabaseHelper.columnImageUrl: allData[j].ImageUrl,
      });
      print('the inserted id is $i');
      j++;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // in KM
  }

  void listenLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled!) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }
    setState(() {
      _isListenLocation = true;
    });
  }

  int? currentMonth;
  bool flag = true;
  bool getDataFlag = false;

  void operation() async {
    setState(() {
      image = null;
    });
    if (flag == false) {
      setState(() {
        flag = true;
      });
    } else {
      setState(() {
        flag = false;
      });
    }
    List<Map<String, dynamic>> queryRows =
        await DatabaseHelper.instance.queryAll();
    int it = 0;
    while (it < queryRows.length) {
      if (flag == true) {
        print("break");
        break;
      }
      double lat1 = double.parse(currentLatitude);
      double long1 = double.parse(currentLongitude);
      double lat2 = double.parse(queryRows[it]['Latitude']);
      double long2 = double.parse(queryRows[it]['Longitude']);
      double d = calculateDistance(lat1, long1, lat2, long2);
      if (d <= double.parse(queryRows[it]['Distance'])) {
        //double.parse(queryRows[it]['Distance'])
        setState(() {
          image = queryRows[it]['ImageUrl'];
        });
      } else {
        setState(() {
          image = null;
        });
      }
      await Future.delayed(Duration(seconds: 4));
      // print("Lat1 "+ currentLatitude);
      // print("Long1 " + currentLongitude);
      // print("Lat2 "+ queryRows[it]['Latitude']);
      // print("Long2 "+ queryRows[it]['Longitude']);
      print("Distance is : $d KM");
      it++;
      if (it == queryRows.length) {
        it = 0;
      }
    }
  }

  int currentDate = 1;
  void getDate() async {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    print("Day is ${date.day}");
    getData();
    if (date.day == 1) {
      if (currentDate == 1) {
        getData();
        setState(() {
          currentDate = 30;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(5, 58, 5, 100),
            title: Text("ADTO"),
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Welcome(),
                    ),
                  );
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  // color: Colors.black,
                  width: 300,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromRGBO(1, 0, 9, 100),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      getDate();

                      setState(() {
                        number = number * (-1);
                      });
                      if (number == -1) {
                        await Future.delayed(Duration(seconds: 4));
                        operation();
                      } else {
                        setState(() {
                          image = null;
                          flag = true;
                        });
                      }
                    },
                    child: number == 1 ? Text("Start") : Text("Stop"),
                  ),
                ),
                // Container(
                //   // color: Colors.black,
                //   width: 300,
                //   child: ElevatedButton(
                //     onPressed: () async {
                //       _serviceEnabled = await location.serviceEnabled();
                //       if (!_serviceEnabled!) {
                //         _serviceEnabled = await location.requestService();
                //         if (_serviceEnabled!) return;
                //       }
                //
                //       _permissionGranted = await location.hasPermission();
                //       if (_permissionGranted == PermissionStatus.denied) {
                //         _permissionGranted = await location.requestPermission();
                //         if (_permissionGranted != PermissionStatus.granted)
                //           return;
                //       }
                //       _locationData = await location.getLocation();
                //       setState(() {
                //         _isGetLocation = true;
                //       });
                //     },
                //     child: Text("Get Current Location"),
                //   ),
                // ),
                // _isGetLocation
                //     ? Text(
                //         'Location: ${_locationData!.latitude}/${_locationData!.longitude}')
                //     : Container(),
                // Container(
                //   // color: Colors.black,
                //   width: 300,
                //   child: ElevatedButton(
                //     onPressed: () async {
                //       _serviceEnabled = await location.serviceEnabled();
                //       if (!_serviceEnabled!) {
                //         _serviceEnabled = await location.requestService();
                //         if (_serviceEnabled!) return;
                //       }
                //
                //       _permissionGranted = await location.hasPermission();
                //       if (_permissionGranted == PermissionStatus.denied) {
                //         _permissionGranted = await location.requestPermission();
                //         if (_permissionGranted != PermissionStatus.granted)
                //           return;
                //       }
                //       setState(() {
                //         _isListenLocation = true;
                //       });
                //     },
                //     child: Text('Listen Location'),
                //   ),
                // ),
                StreamBuilder(
                    stream: location.onLocationChanged,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.waiting) {
                        var data = snapshot.data as LocationData;
                        currentLatitude = data.latitude.toString();
                        currentLongitude = data.longitude.toString();
                        return Container();
                        // Text(
                        //   "Location always change: \n ${data.latitude}/${data.longitude}");
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
                SizedBox(
                  height: 40,
                ),
                // FlatButton(
                //     onPressed: () async {
                //       int i = await DatabaseHelper.instance.insert({
                //         DatabaseHelper.columnLatitude: 'hey',
                //         DatabaseHelper.columnLongitude: 'hey',
                //         DatabaseHelper.columnDistance: 'hey',
                //         DatabaseHelper.columnStartTime: 'hey',
                //         DatabaseHelper.columnEndTime: 'hey',
                //         DatabaseHelper.columnImageUrl: 'hey',
                //         // DatabaseHelper.columnLatitude : "Akshay",
                //       });
                //       print('the inserted id is $i');
                //     },
                //     child: Text('Insert')),
                // FlatButton(
                //     onPressed: () async {
                //       List<Map<String, dynamic>> queryRows =
                //           await DatabaseHelper.instance.queryAll();
                //       print(queryRows);
                //     },
                //     child: Text('query')),
                // FlatButton(
                //     onPressed: () async {
                //       int updatedId = await DatabaseHelper.instance.update({
                //         DatabaseHelper.columnId: 2,
                //         // DatabaseHelper.columnName : 'Mark'
                //       });
                //       print(updatedId);
                //     },
                //     child: Text('update')),
                // FlatButton(
                //   onPressed: () async {
                //     int rowsEffected = await DatabaseHelper.instance.delete();
                //     print(rowsEffected);
                //   },
                //   child: Text('delete'),
                // ),
                SizedBox(
                  height: 30,
                ),
                // Container(
                //   // color: Colors.black,
                //   width: 300,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       setState(() {
                //         flag = true;
                //       });
                //       getData();
                //     },
                //     child: Text("Fetch"),
                //   ),
                // ),
                SizedBox(
                  height: 10,
                ),
                // Container(
                //   // color: Colors.black,
                //   width: 300,
                //   child: ElevatedButton(
                //     onPressed: () async {
                //       // setState(() {
                //       //   image = null;
                //       // });
                //       // if(flag==false)
                //       //   {
                //       //     setState(() {
                //       //       flag = true;
                //       //     });
                //       //   }
                //       // else
                //       //   {
                //       //     setState(() {
                //       //       flag = false;
                //       //     });
                //       //   }
                //       // List<Map<String, dynamic>> queryRows =
                //       // await DatabaseHelper.instance.queryAll();
                //       // int it = 0;
                //       // while(it<queryRows.length)
                //       //   {
                //       //     if(flag==true)
                //       //       {
                //       //         print("break");
                //       //         break;
                //       //       }
                //       //     double lat1 = double.parse(currentLatitude);
                //       //     double long1 = double.parse(currentLongitude);
                //       //     double lat2 = double.parse(queryRows[it]['Latitude']);
                //       //     double long2 = double.parse(queryRows[it]['Longitude']);
                //       //     double d = calculateDistance(lat1,long1,lat2,long2);
                //       //     if(d<=double.parse(queryRows[it]['Distance']))
                //       //       {
                //       //         setState(()
                //       //         {
                //       //           image = queryRows[it]['ImageUrl'];
                //       //         });
                //       //       }
                //       //     else{
                //       //       setState(() {
                //       //         image = null;
                //       //       });
                //       //     }
                //       //     await Future.delayed(Duration(seconds: 4));
                //       //     // print("Lat1 "+ currentLatitude);
                //       //     // print("Long1 " + currentLongitude);
                //       //     // print("Lat2 "+ queryRows[it]['Latitude']);
                //       //     // print("Long2 "+ queryRows[it]['Longitude']);
                //       //     print("Distance is : $d KM");
                //       //     it++;
                //       //     if(it==queryRows.length)
                //       //       {
                //       //         it = 0;
                //       //       }
                //       //   }
                //       // setState(() {
                //       //   image = queryRows[it-1]['ImageUrl'];
                //       // });
                //
                //       // print(queryRows);
                //       // print(currentLatitude);
                //       // print(currentLongitude);
                //     },
                //     child: Text("Operation"),
                //   ),
                // ),

                Container(
                  height: 150,
                  width: 150,
                  child:
                      image != null ? Image.network('$image') : FlutterLogo(),
                ),
              ],
            ),
          )),
    );
  }
}

// convert json file to map
class Details {
  final String Latitude;
  final String Longitude;
  final String Distance;
  final String StartTime;
  final String EndTime;
  final String ImageUrl;
  Details({
    required this.Latitude,
    required this.Longitude,
    required this.Distance,
    required this.StartTime,
    required this.EndTime,
    required this.ImageUrl,
  });
  static Details fromJson(Map<String, dynamic> json) => Details(
        Latitude: json['Latitude'],
        Longitude: json['Longitude'],
        Distance: json['Distance'],
        StartTime: json['StartTime'],
        EndTime: json['EndTime'],
        ImageUrl: json['ImageUrl'],
      );
} /*4.7123263494981*/
