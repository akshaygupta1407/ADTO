
import 'package:adto/Welcome.dart';
import 'package:adto/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
class Details1 extends StatefulWidget {
  const Details1({Key? key}) : super(key: key);

  @override
  _Details1State createState() => _Details1State();
}

class _Details1State extends State<Details1> {
  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  bool _isListenLocation = false, _isGetLocation = false;
  String currentLatitude = "", currentLongitude = "";
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('users1');

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

  Future<void> _signOut(BuildContext context) async {

      Navigator.of(context).popUntil((route) => route.isFirst);
      // Navigator.pop();
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new Welcome()));

  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        SystemNavigator.pop();
        SystemNavigator.pop();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              // backgroundColor: Color.fromRGBO(50, 110, 246, 100),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Text("Colleges",style: TextStyle(color:Colors.blueAccent,fontSize: 30,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (context) => new Welcome()));
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.remove('email');
                    _signOut(context);
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Welcome(),
                    //   ),
                    // );
                  },
                  icon: Icon(Icons.logout,color: Colors.blueAccent,),
                ),
              ],
            ),
          ),
          body: StreamBuilder(
              stream: location.onLocationChanged,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.waiting) {
                  var data = snapshot.data as LocationData;
                  currentLatitude = data.latitude.toString();
                  currentLongitude = data.longitude.toString();
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users1')
                        .snapshots(),
                    builder: (_, snapshot) {
                      if (snapshot.hasError)
                        return Text('Error = ${snapshot.error}');
                      if (!snapshot.hasData) {
                        return LinearProgressIndicator(
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.black),
                          backgroundColor: Colors.white,
                        );
                      }
                      if (snapshot.hasData) {
                        final docs = snapshot.data!.docs;
                        docs.sort((a, b) {
                          double d1 = calculateDistance(
                              double.parse((currentLatitude)),
                              double.parse(currentLongitude),
                              double.parse(a['Latitude']),
                              double.parse(a['Longitude']));
                          double d2 = calculateDistance(
                              double.parse((currentLatitude)),
                              double.parse(currentLongitude),
                              double.parse(b['Latitude']),
                              double.parse(b['Longitude']));
                          return d1.compareTo(d2);
                        });
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (_, i) {
                            final data = docs[i].data();
                            double lat1 = double.parse((currentLatitude));
                            double long1 = double.parse(currentLongitude);
                            double lat2 = double.parse(data['Latitude']);
                            double long2 = double.parse(data['Longitude']);
                            double distance =
                                calculateDistance(lat1, long1, lat2, long2);
                            double d =
                                double.parse((distance).toStringAsFixed(2));
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Card(
                                color: Colors.blue.shade50,
                                // elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                shadowColor: Colors.blueGrey,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ListTile(
                                    title: Text(
                                      data['BusinessName'],
                                      style:
                                          TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    // subtitle: Text('Address:' + data['BusinessAddress']),

                                    subtitle: Padding(
                                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(data['BusinessAddress'],textAlign: TextAlign.left,),
                                          // Center(child: Text('$d' + ' KM',textAlign: TextAlign.center,)),
                                          Text('$d' + ' KM',textAlign: TextAlign.left,),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                  child: GestureDetector(
                                                      onTap: () async {
                                                        double latt = double.parse(data['Latitude']);
                                                        double longg = double.parse(data['Longitude']);
                                                        MapsLauncher.launchCoordinates(latt, longg);
                                                        // String googleUrl =
                                                        //     'https://www.google.com/maps/search/?api=1&query=$latt,$longg';
                                                        // if (await canLaunch(googleUrl)) {
                                                        //   await launch(googleUrl);
                                                        // } else {
                                                        //   throw 'Could not open the map.';
                                                        // }
                                                      },
                                                      child: SizedBox(
                                                        width: MediaQuery.of(context).size.width / 3,
                                                        child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                              // backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(255, 177, 17, 100)),
                                                              backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(46, 140, 252, 100)),
                                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),),
                                                            ),
                                                            onPressed: null,
                                                            child:
                                                                Text("Direction")),
                                                      )
                                                  )),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                  child: GestureDetector(

                                                      onTap: () async {

                                                      },
                                                      child: SizedBox(
                                                        width: MediaQuery.of(context).size.width / 3,
                                                        child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                                              // backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(255, 177, 17, 100)),
                                                              backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(13, 58, 169, 100)),
                                                              // backgroundColor: Colors.blue,
                                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),),
                                                            ),
                                                            onPressed: null,
                                                            child:
                                                            Text("Events")),
                                                      ))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // subtitle: Text('hello'),
                                    //subtitle: Text(data['link']),
                                    onTap: () async {
                                      String url = data['UrlLink'];
                                      await launch(url);
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return LinearProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.black),
                        backgroundColor: Colors.white,
                      );
                    },
                  );
                  // Text(
                  //   "Location always change: \n ${data.latitude}/${data.longitude}");
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      ),
    );
  }
}
