import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoogleSignIn googleSignIn = GoogleSignIn();

class HomeGoogle extends StatefulWidget {
  @override
  _HomeGoogleState createState() => _HomeGoogleState();
}

class _HomeGoogleState extends State<HomeGoogle> {
  PageController? pageController;
  TextEditingController UPIcontroller = TextEditingController();
  bool isAuth = false;
  int pageIndex = 0, flags = 0, points = 0;
  // double distance1 = 0, distance2 = 0, distance3 = 0;

  bool isProfile = false;
  var image;
  int ranking = 0;
  String imageLink1 = "",imageLink2 = "",imageLink3 = "",imageLink4 = "",imageLink5 = "";
  int position = 0;
  String? UPIid;
  double lat1 = 0, lat2 = 0, lat3 = 0, long1 = 0, long2 = 0, long3 = 0;
  double minelat1 = 0, minelat2 = 0,minelat3 = 0,minelat4 = 0,minelat5 = 0,minelat6 = 0,minelat7 = 0,minelat8 = 0,minelat9 = 0,minelat10 = 0,minelat11 = 0,minelat12 = 0,minelat13 = 0,minelat14 = 0,minelat15 = 0,minelat16 = 0,minelat17 = 0,minelat18 = 0,minelat19 = 0,minelat20 = 0,
      minelat21 = 0,minelat22 = 0,minelat23 = 0,minelat24 = 0,minelat25 = 0,minelat26 = 0,minelat27 = 0,minelat28 = 0,minelat29 = 0,minelat30 = 0,minelat31 = 0,minelat32 = 0,minelat33 = 0,minelat34 = 0,minelat35 = 0,minelat36 = 0,minelat37 = 0,minelat38 = 0,minelat39 = 0,minelat40 = 0;

  double minelong1 = 0, minelong2 = 0,minelong3 = 0,minelong4 = 0,minelong5 = 0,minelong6 = 0,minelong7 = 0,minelong8 = 0,minelong9 = 0,minelong10 = 0,minelong11 = 0,minelong12 = 0,minelong13 = 0,minelong14 = 0,minelong15 = 0,minelong16 = 0,minelong17 = 0,minelong18 = 0,minelong19 = 0,minelong20 = 0,
      minelong21 = 0,minelong22 = 0,minelong23 = 0,minelong24 = 0,minelong25 = 0,minelong26 = 0,minelong27 = 0,minelong28 = 0,minelong29 = 0,minelong30 = 0,minelong31 = 0,minelong32 = 0,minelong33 = 0,minelong34 = 0,minelong35 = 0,minelong36 = 0,minelong37 = 0,minelong38 = 0,minelong39 = 0,minelong40 = 0;

  bool progress = true;
  bool mineFlags = true;
  var allData, allFlagsData;
  String? DispayName, PhotoUrl, Email, UserID;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final usersRef = FirebaseFirestore.instance.collection('flagusers');
  User? currentUser;
  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('flagusers');
  CollectionReference collectionRef1 =
      FirebaseFirestore.instance.collection('flags');
  // CollectionReference linkRefernce = FirebaseFirestore.instance.collection('Links');

  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  String username = "";
  bool _isListenLocation = false, _isGetLocation = false;
  String currentLatitude = "", currentLongitude = "";
  // flags coordinates
  String latitudeFlag1 = "",
      longitudeFlag1 = "",
      latitudeFlag2 = "",
      longitudeFlag2 = "",
      latitudeFlag3 = "",
      longitudeFlag3 = "";
  @override
  void initState() {
    // detects when user signed in

    super.initState();
    pageController = PageController();
    setState(() {
      image = NetworkImage("$PhotoUrl");
      flags = 0;
      points = 0;
      UPIcontroller.clear();
    });
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account!);
    }, onError: (err) {
      print('Error Signing in : $err');
    });
    // Reauthenticate  user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account!);
    }).catchError((err) {
      print('Error Signing in : $err');
    });
    getData();
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

  int number = 1;
  getData() async {
    QuerySnapshot querySnapshot = await collectionRef.get();
    // QuerySnapshot querySnapshot1 = await collectionRef1.get();
    setState(() {
      allData = querySnapshot.docs
          .map((doc) => Details1.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      UPIcontroller.clear();
    });
    int j = 0;
    allData.sort((a, b) {
      int d1 = a.points;
      int d2 = b.points;
      return d2.compareTo(d1);
    });

    while (j < allData.length) {
      if (allData[j].id == UserID) {
        // print(allData[j].id);
        print(UserID);
        setState(() {
          username = allData[j].displayName;
          flags = allData[j].flags;
          points = allData[j].points;
          UPIid = allData[j].upiId;
          position = j + 1;
        });
        break;
      }
      j++;
    }
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      setState(() async {
        isAuth = true;
        pageIndex = 0;
        // await Future.delayed(Duration(seconds: 1));
        getData();
      });
    } else {
      setState(
        () {
          isAuth = false;
        },
      );
    }
  }

  createUserInFirestore() async {
    //1) check if user exists in users collection in database according to their id
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user?.id).get();
    if (!doc.exists) {
      usersRef.doc(user?.id).set({
        "id": user?.id,
        "photoUrl": user?.photoUrl,
        "email": user?.email,
        "displayName": user?.displayName,
        "Flags": 0,
        "Points": 0,
        "UPI": "",
      });
    }
    setState(() {
      DispayName = user?.displayName;
      Email = user?.email;
      PhotoUrl = user?.photoUrl;
      UserID = user?.id;
    });
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    // HapticFeedback.heavyImpact();
    pageController?.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    if (pageIndex == 2 || pageIndex == 1 || pageIndex == 0) {
      getData();
    }
  }
  void setData1(slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags)async
  {
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": "-1",
      "Longitude1": "-1",
      "Latitude2": slat2,
      "Longitude2": slong2,
      "Latitude3": slat3,
      "Longitude3": slong3,
      "Year": year,
      "Month": month,
      "Date": date,
      "Hour": hour,
      "Minute": minute,
      "Year1": year1,
      "Month1": month1,
      "Date1": date1,
      "Hour1": hour1,
      "Minute1": minute1,
      "Year2": year2,
      "Month2": month2,
      "Date2": date2,
      "Hour2": hour2,
      "Minute2": minute2,
      "Year3": year3,
      "Month3": month3,
      "Date3": date3,
      "Hour3": hour3,
      "Minute3": minute3,
      "TotalFlags": totalflags - 1,
      'ImageLink1': imageLink1,
      'ImageLink2': imageLink2,
      'ImageLink3': imageLink3,
    });
  }
  void setData2(slat1,slong1,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags)async
  {
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude2": "-1",
      "Longitude2": "-1",
      "Latitude1": slat1,
      "Longitude1": slong1,
      "Latitude3": slat3,
      "Longitude3": slong3,
      "Year": year,
      "Month": month,
      "Date": date,
      "Hour": hour,
      "Minute": minute,
      "Year1": year1,
      "Month1": month1,
      "Date1": date1,
      "Hour1": hour1,
      "Minute1": minute1,
      "Year2": year2,
      "Month2": month2,
      "Date2": date2,
      "Hour2": hour2,
      "Minute2": minute2,
      "Year3": year3,
      "Month3": month3,
      "Date3": date3,
      "Hour3": hour3,
      "Minute3": minute3,
      "TotalFlags": totalflags-1,
      'ImageLink1' : imageLink1,
      'ImageLink2' : imageLink2,
      'ImageLink3' : imageLink3,
    });
  }
  void setData3(slat1,slong1,slat2,slong2,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags)async
  {
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude3": "-1",
      "Longitude3": "-1",
      "Latitude2": slat2,
      "Longitude2": slong2,
      "Latitude1": slat1,
      "Longitude1": slong1,
      "Year": year,
      "Month": month,
      "Date": date,
      "Hour": hour,
      "Minute": minute,
      "Year1": year1,
      "Month1": month1,
      "Date1": date1,
      "Hour1": hour1,
      "Minute1": minute1,
      "Year2": year2,
      "Month2": month2,
      "Date2": date2,
      "Hour2": hour2,
      "Minute2": minute2,
      "Year3": year3,
      "Month3": month3,
      "Date3": date3,
      "Hour3": hour3,
      "Minute3": minute3,
      "TotalFlags": totalflags-1,
      'ImageLink1' : imageLink1,
      'ImageLink2' : imageLink2,
      'ImageLink3' : imageLink3,
    });
  }
  void setUserData1(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,)async{
    await collectionRef.doc("$UserID").set({
      "id": UserID,
      "photoUrl": PhotoUrl,
      "email": Email,
      "displayName": DispayName,
      "Flags": flags+1,
      "Points": points+100,
      'UPI': UPIid,
    });
  }
  void setUserData2(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,)async{
    await collectionRef.doc("$UserID").set({
      "id": UserID,
      "photoUrl": PhotoUrl,
      "email": Email,
      "displayName": DispayName,
      "Flags": flags+1,
      "Points": points+100,
      'UPI': UPIid,
    });
  }
  void setUserData3(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,)async{
    await collectionRef.doc("$UserID").set({
      "id": UserID,
      "photoUrl": PhotoUrl,
      "email": Email,
      "displayName": DispayName,
      "Flags": flags+1,
      "Points": points+100,
      'UPI': UPIid,
    });
  }
  void setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,)async{
    await collectionRef.doc("$UserID").set({
      "id": UserID,
      "photoUrl": PhotoUrl,
      "email": Email,
      "displayName": DispayName,
      "Flags": flags,
      "Points": points-10,
      'UPI': UPIid,
    });
  }

  void mineData1(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : "-1", 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : "-1", 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData2(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : "-1", 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : "-1", 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData3(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' :"-1",'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' :"-1", 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData4(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : "-1",'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : "-1",'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData5(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : "-1",'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : "-1",'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData6(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' :"-1",'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : "-1",'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData7(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : "-1",'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : "-1",'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }void mineData8(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : "-1",'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : "-1",'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData9(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : "-1",'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' :"-1",'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData10(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : "-1",'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : "-1",'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData11(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : "-1",'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : "-1",'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData12(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : "-1",'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : "-1",'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData13(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : "-1",'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : "-1",'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData14(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : "-1",'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' :"-1",'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData15(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : "-1",'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : "-1",'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData16(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : "-1",'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : "-1",'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }void mineData17(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' :"-1",'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : "-1",'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }void mineData18(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : "-1",'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : "-1",'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData19(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : "-1",'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : "-1",'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData20(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' :"-1",'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : "-1",'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData21(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : "-1",'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : "-1",'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData22(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : "-1",'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : "-1",'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }void mineData23(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : "-1",'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : "-1",'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData24(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : "-1",'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : "-1",'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData25(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : "-1",'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : "-1",'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData26(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' :"-1",'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : "-1",'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData27(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : "-1",'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : "-1",'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData28(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : "-1",'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : "-1",'minelong29' : minelong29.toString(),'minelong30' : minelong30.toString(),

    });
  }
  void mineData29(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : "-1",'minelat30' : minelat30.toString(),
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : "-1",'minelong30' : minelong30.toString(),

    });
  }
  void mineData30(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
      minute2,year3,month3,date3,hour3,minute3,totalflags, minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6,
      minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10, minelat11, minelong11, minelat12, minelong12,
      minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18,
      minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29,
      minelat30, minelong30,
      )async{
    await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
      "Latitude1": slat1, "Longitude1": slong1, "Latitude2": slat2, "Longitude2": slong2, "Latitude3": slat3, "Longitude3": slong3, "Year": year, "Month": month, "Date": date, "Hour": hour, "Minute": minute, "Year1": year1, "Month1": month1, "Date1": date1, "Hour1": hour1, "Minute1": minute1, "Year2": year2, "Month2": month2, "Date2": date2, "Hour2": hour2, "Minute2": minute2, "Year3": year3, "Month3": month3, "Date3": date3, "Hour3": hour3, "Minute3": minute3, "TotalFlags": totalflags, 'ImageLink1' : imageLink1, 'ImageLink2' : imageLink2, 'ImageLink3' : imageLink3,
      'minelat1' : minelat1.toString(), 'minelat2' : minelat2.toString(), 'minelat3' : minelat3.toString(),'minelat4' : minelat4.toString(),'minelat5' : minelat5.toString(),'minelat6' : minelat6.toString(),'minelat7' : minelat7.toString(),'minelat8' : minelat8.toString(),'minelat9' : minelat9.toString(),'minelat10' : minelat10.toString(),'minelat11' : minelat11.toString(),'minelat12' : minelat12.toString(),'minelat13' : minelat13.toString(),'minelat14' : minelat14.toString(),'minelat15' : minelat15.toString(),'minelat16' : minelat16.toString(),'minelat17' : minelat17.toString(),'minelat18' : minelat18.toString(),'minelat19' : minelat19.toString(),'minelat20' : minelat20.toString(),'minelat21' : minelat21.toString(),'minelat22' : minelat22.toString(),'minelat23' : minelat23.toString(),'minelat24' : minelat24.toString(),'minelat25' : minelat25.toString(),'minelat26' : minelat26.toString(),'minelat27' : minelat27.toString(),'minelat28' : minelat28.toString(),'minelat29' : minelat29.toString(),'minelat30' :"-1",
      'minelong1' : minelong1.toString(), 'minelong2' : minelong2.toString(), 'minelong3' : minelong3.toString(), 'minelong4' : minelong4.toString(),'minelong5' : minelong5.toString(),'minelong6' : minelong6.toString(),'minelong7' : minelong7.toString(),'minelong8' : minelong8.toString(),'minelong9' : minelong9.toString(),'minelong10' : minelong10.toString(),'minelong11' : minelong11.toString(),'minelong12' : minelong12.toString(),'minelong13' : minelong13.toString(),'minelong14' : minelong14.toString(),'minelong15' : minelong15.toString(),'minelong16' : minelong16.toString(),'minelong17' : minelong17.toString(),'minelong18' : minelong18.toString(),'minelong19' : minelong19.toString(),'minelong20' : minelong20.toString(),'minelong21' : minelong21.toString(),'minelong22' : minelong22.toString(),'minelong23' : minelong23.toString(),'minelong24' : minelong24.toString(),'minelong25' : minelong25.toString(),'minelong26' : minelong26.toString(),'minelong27' : minelong27.toString(),'minelong28' : minelong28.toString(),'minelong29' : minelong29.toString(),'minelong30' : "-1",

    });
  }








  void dialogNotification()async{

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Alert!!"),
          content: new Text("Flag Found!!"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                getData();
                Navigator.of(context).pop();
                Future.delayed(Duration(seconds: 1));
              },
            ),
          ],
        );
      },
    );
  }

  void dialogNotificationmine1()async{
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Alert!!"),
          content: new Text("You stepped on mine"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                getData();
                Navigator.of(context).pop();
                Future.delayed(Duration(seconds: 1));
              },
            ),
          ],
        );
      },
    );
  }

  //home
  Scaffold home(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade50,
        title: Text(
          "Home",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder(
          stream: location.onLocationChanged,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              var data = snapshot.data as LocationData;
              currentLatitude = data.latitude.toString();
              currentLongitude = data.longitude.toString();
              double currlat = double.parse(currentLatitude);
              double currlong = double.parse(currentLongitude);
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance.collection('flags').snapshots(),
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
                    final data = docs[0].data();
                    lat1 = double.parse(data['Latitude1']);
                    lat2 = double.parse(data['Latitude2']);
                    lat3 = double.parse(data['Latitude3']);
                    long1 = double.parse(data['Longitude1']);
                    long2 = double.parse(data['Longitude2']);
                    long3 = double.parse(data['Longitude3']);

                    String slat1 = (data['Latitude1']);
                    String slat2 = (data['Latitude2']);
                    String slat3 = (data['Latitude3']);
                    String slong1 = (data['Longitude1']);
                    String slong2 = (data['Longitude2']);
                    String slong3 = (data['Longitude3']);
                    int year = data['Year'];
                    int month = data['Month'];
                    int date = data['Date'];
                    int hour = data['Hour'];
                    int minute = data['Minute'];

                    int year1 = data['Year1'];
                    int month1 = data['Month1'];
                    int date1 = data['Date1'];
                    int hour1 = data['Hour1'];
                    int minute1 = data['Minute1'];

                    int year2 = data['Year2'];
                    int month2 = data['Month2'];
                    int date2 = data['Date2'];
                    int hour2 = data['Hour2'];
                    int minute2 = data['Minute2'];

                    int year3 = data['Year3'];
                    int month3 = data['Month3'];
                    int date3 = data['Date3'];
                    int hour3 = data['Hour3'];
                    int minute3 = data['Minute3'];

                    imageLink1 = data['ImageLink1'];
                    imageLink2 = data['ImageLink2'];
                    imageLink3 = data['ImageLink3'];
                    // mine latitude
                    minelat1 = double.parse(data['minelat1']);
                    minelat2 = double.parse(data['minelat2']);
                    minelat3 = double.parse(data['minelat3']);

                    minelat4 = double.parse(data['minelat4']);
                    minelat5 = double.parse(data['minelat5']);
                    minelat6 = double.parse(data['minelat6']);
                    minelat7 = double.parse(data['minelat7']);
                    minelat8 = double.parse(data['minelat8']);
                    minelat9 = double.parse(data['minelat9']);
                    minelat10 = double.parse(data['minelat10']);
                    minelat11 = double.parse(data['minelat11']);
                    minelat12 = double.parse(data['minelat12']);
                    minelat13 = double.parse(data['minelat13']);
                    minelat14 = double.parse(data['minelat14']);
                    minelat15 = double.parse(data['minelat15']);
                    minelat16 = double.parse(data['minelat16']);
                    minelat17 = double.parse(data['minelat17']);
                    minelat18 = double.parse(data['minelat18']);
                    minelat19 = double.parse(data['minelat19']);
                    minelat20 = double.parse(data['minelat20']);
                    minelat21 = double.parse(data['minelat21']);
                    minelat22 = double.parse(data['minelat22']);
                    minelat23 = double.parse(data['minelat23']);
                    minelat24 = double.parse(data['minelat24']);
                    minelat25 = double.parse(data['minelat25']);
                    minelat26 = double.parse(data['minelat26']);
                    minelat27 = double.parse(data['minelat27']);
                    minelat28 = double.parse(data['minelat28']);
                    minelat29 = double.parse(data['minelat29']);
                    minelat30 = double.parse(data['minelat30']);
                    // minelat31 = double.parse()data['minelat31'];
                    // minelat32 = double.parse()data['minelat32'];
                    // minelat33 = double.parse()data['minelat33'];
                    // minelat34 = double.parse()data['minelat34'];
                    // minelat35 = double.parse()data['minelat35'];
                    // minelat36 = double.parse()data['minelat36'];
                    // minelat37 = double.parse()data['minelat37'];
                    // minelat38 = double.parse()data['minelat38'];
                    // minelat39 = double.parse()data['minelat39'];
                    // minelat40 = double.parse()data['minelat40'];
                    // // // mine longitude
                    minelong1 = double.parse(data['minelong1']);
                    minelong2 = double.parse(data['minelong2']);
                    minelong3 = double.parse(data['minelong3']);
                    minelong4 = double.parse(data['minelong4']);
                    minelong5 = double.parse(data['minelong5']);
                    minelong6 = double.parse(data['minelong6']);
                    minelong7 = double.parse(data['minelong7']);
                    minelong8 = double.parse(data['minelong8']);
                    minelong9 = double.parse(data['minelong9']);
                    minelong10 = double.parse(data['minelong10']);
                    minelong11 = double.parse(data['minelong11']);
                    minelong12 = double.parse(data['minelong12']);
                    minelong13 = double.parse(data['minelong13']);
                    minelong14 = double.parse(data['minelong14']);
                    minelong15 = double.parse(data['minelong15']);
                    minelong16 = double.parse(data['minelong16']);
                    minelong17 = double.parse(data['minelong17']);
                    minelong18 = double.parse(data['minelong18']);
                    minelong19 = double.parse(data['minelong19']);
                    minelong20 = double.parse(data['minelong20']);
                    minelong21 = double.parse(data['minelong21']);
                    minelong22 = double.parse(data['minelong22']);
                    minelong23 = double.parse(data['minelong23']);
                    minelong24 = double.parse(data['minelong24']);
                    minelong25 = double.parse(data['minelong25']);
                    minelong26 = double.parse(data['minelong26']);
                    minelong27 = double.parse(data['minelong27']);
                    minelong28 = double.parse(data['minelong28']);
                    minelong29 = double.parse(data['minelong29']);
                    minelong30 = double.parse(data['minelong30']);

                    // minelong31 = double.parse(data['minelong31'];
                    // minelong32 = double.parse(data['minelong32'];
                    // minelong33 = double.parse(data['minelong33'];
                    // minelong34 = double.parse(data['minelong34'];
                    // minelong35 = double.parse(data['minelong35'];
                    // minelong36 = double.parse(data['minelong36'];
                    // minelong37 = double.parse(data['minelong37'];
                    // minelong38 = double.parse(data['minelong38'];
                    // minelong39 = double.parse(data['minelong39'];
                    // minelong40 = double.parse(data['minelong40'];



                    int totalflags = data['TotalFlags'];
                    var startTime = DateTime(year, month, date, hour, minute); // TODO: change this to your DateTime from firebase
                    var startTime1 = DateTime(year1, month1, date1, hour1, minute1);
                    var startTime2 = DateTime(year2, month2, date2, hour2, minute2);
                    var startTime3 = DateTime(year3, month3, date3, hour3, minute3);
                    var currentTime = DateTime.now();
                    print(currlat);print(currlong);

                    double distance1 =
                        calculateDistance(lat1, long1, currlat, currlong);
                    distance1 =
                        double.parse(((distance1) * 1000).toStringAsFixed(3));
                    double distance2 =
                        calculateDistance(lat2, long2, currlat, currlong);
                    distance2 =
                        double.parse(((distance2) * 1000).toStringAsFixed(3));
                    double distance3 =
                        calculateDistance(lat3, long3, currlat, currlong);
                    distance3 =
                        double.parse(((distance3) * 1000).toStringAsFixed(3));



                    double mineDistance1 =calculateDistance(minelat1, minelong1, currlat, currlong);
                    double mineDistance2 =calculateDistance(minelat2, minelong2, currlat, currlong);
                    double mineDistance3 =calculateDistance(minelat3, minelong3, currlat, currlong);
                    double mineDistance4 =calculateDistance(minelat4, minelong4, currlat, currlong);
                    double mineDistance5 =calculateDistance(minelat5, minelong5, currlat, currlong);
                    double mineDistance6 =calculateDistance(minelat6, minelong6, currlat, currlong);
                    double mineDistance7 =calculateDistance(minelat7, minelong7, currlat, currlong);
                    double mineDistance8 =calculateDistance(minelat8, minelong8, currlat, currlong);
                    double mineDistance9 =calculateDistance(minelat9, minelong9, currlat, currlong);
                    double mineDistance10 =calculateDistance(minelat10, minelong10, currlat, currlong);
                    double mineDistance11 =calculateDistance(minelat11, minelong11, currlat, currlong);
                    double mineDistance12 =calculateDistance(minelat12, minelong12, currlat, currlong);
                    double mineDistance13 =calculateDistance(minelat13, minelong13, currlat, currlong);
                    double mineDistance14 =calculateDistance(minelat14, minelong14, currlat, currlong);
                    double mineDistance15 =calculateDistance(minelat15, minelong15, currlat, currlong);
                    double mineDistance16 =calculateDistance(minelat16, minelong16, currlat, currlong);
                    double mineDistance17 =calculateDistance(minelat17, minelong17, currlat, currlong);
                    double mineDistance18 =calculateDistance(minelat18, minelong18, currlat, currlong);
                    double mineDistance19 =calculateDistance(minelat19, minelong19, currlat, currlong);
                    double mineDistance20=calculateDistance(minelat20, minelong20, currlat, currlong);
                    double mineDistance21 =calculateDistance(minelat21, minelong21, currlat, currlong);
                    double mineDistance22 =calculateDistance(minelat22, minelong22, currlat, currlong);
                    double mineDistance23 =calculateDistance(minelat23, minelong23, currlat, currlong);
                    double mineDistance24 =calculateDistance(minelat24, minelong24, currlat, currlong);
                    double mineDistance25 =calculateDistance(minelat25, minelong25, currlat, currlong);
                    double mineDistance26 =calculateDistance(minelat26, minelong26, currlat, currlong);
                    double mineDistance27 =calculateDistance(minelat27, minelong27, currlat, currlong);
                    double mineDistance28 =calculateDistance(minelat28, minelong28, currlat, currlong);
                    double mineDistance29 =calculateDistance(minelat29, minelong29, currlat, currlong);
                    double mineDistance30 =calculateDistance(minelat30, minelong30, currlat, currlong);

                    mineDistance1 = double.parse(((mineDistance1) * 1000).toStringAsFixed(3));
                    mineDistance2 = double.parse(((mineDistance2) * 1000).toStringAsFixed(3));
                    mineDistance3 = double.parse(((mineDistance3) * 1000).toStringAsFixed(3));
                    mineDistance4 = double.parse(((mineDistance4) * 1000).toStringAsFixed(3));
                    mineDistance5 = double.parse(((mineDistance5) * 1000).toStringAsFixed(3));
                    mineDistance6 = double.parse(((mineDistance6) * 1000).toStringAsFixed(3));
                    mineDistance7 = double.parse(((mineDistance7) * 1000).toStringAsFixed(3));
                    mineDistance8 = double.parse(((mineDistance8) * 1000).toStringAsFixed(3));
                    mineDistance9 = double.parse(((mineDistance9) * 1000).toStringAsFixed(3));
                    mineDistance10 = double.parse(((mineDistance10) * 1000).toStringAsFixed(3));
                    mineDistance11 = double.parse(((mineDistance11) * 1000).toStringAsFixed(3));
                    mineDistance12 = double.parse(((mineDistance12) * 1000).toStringAsFixed(3));
                    mineDistance13 = double.parse(((mineDistance13) * 1000).toStringAsFixed(3));
                    mineDistance14 = double.parse(((mineDistance14) * 1000).toStringAsFixed(3));
                    mineDistance15 = double.parse(((mineDistance15) * 1000).toStringAsFixed(3));
                    mineDistance16 = double.parse(((mineDistance16) * 1000).toStringAsFixed(3));
                    mineDistance17 = double.parse(((mineDistance17) * 1000).toStringAsFixed(3));
                    mineDistance18 = double.parse(((mineDistance18) * 1000).toStringAsFixed(3));
                    mineDistance19 = double.parse(((mineDistance19) * 1000).toStringAsFixed(3));
                    mineDistance20 = double.parse(((mineDistance20) * 1000).toStringAsFixed(3));
                    mineDistance21 = double.parse(((mineDistance21) * 1000).toStringAsFixed(3));
                    mineDistance22 = double.parse(((mineDistance22) * 1000).toStringAsFixed(3));
                    mineDistance23 = double.parse(((mineDistance23) * 1000).toStringAsFixed(3));
                    mineDistance24 = double.parse(((mineDistance24) * 1000).toStringAsFixed(3));
                    mineDistance25 = double.parse(((mineDistance25) * 1000).toStringAsFixed(3));
                    mineDistance26 = double.parse(((mineDistance26) * 1000).toStringAsFixed(3));
                    mineDistance27 = double.parse(((mineDistance27) * 1000).toStringAsFixed(3));
                    mineDistance28 = double.parse(((mineDistance28) * 1000).toStringAsFixed(3));
                    mineDistance29 = double.parse(((mineDistance29) * 1000).toStringAsFixed(3));
                    mineDistance30 = double.parse(((mineDistance30) * 1000).toStringAsFixed(3));



                    calculateDistance(lat1, long1, currlat, currlong);
                    var diff = (currentTime.difference(startTime).inSeconds) * -1;
                    var diff1 = (currentTime.difference(startTime1).inSeconds) * -1;
                    var diff2 = (currentTime.difference(startTime2).inSeconds) * -1;
                    var diff3 = (currentTime.difference(startTime3).inSeconds) * -1;


                    int seconds = (diff % 60).toInt();
                    int minutes = ((diff % 3600) / 60).toInt();
                    int hours = ((diff % 86400) / 3600).toInt();
                    int days = ((diff % (86400 * 30)) / 86400).toInt();
                    int months = ((diff % (86400 * 30*12)) / (86400 * 30)).toInt();

                    int seconds1 = (diff1 % 60).toInt();
                    int minutes1 = ((diff1 % 3600) / 60).toInt();
                    int hours1 = ((diff1 % 86400) / 3600).toInt();
                    int days1 = ((diff1 % (86400 * 30)) / 86400).toInt();
                    int months1 = ((diff1 % (86400 * 30*12)) / (86400 * 30)).toInt();

                    int seconds2 = (diff2 % 60).toInt();
                    int minutes2 = ((diff2 % 3600) / 60).toInt();
                    int hours2 = ((diff2 % 86400) / 3600).toInt();
                    int days2 = ((diff2 % (86400 * 30)) / 86400).toInt();
                    int months2 = ((diff2 % (86400 * 30*12)) / (86400 * 30)).toInt();

                    int seconds3 = (diff3 % 60).toInt();
                    int minutes3 = ((diff3 % 3600) / 60).toInt();
                    int hours3 = ((diff3 % 86400) / 3600).toInt();
                    int days3 = ((diff3 % (86400 * 30)) / 86400).toInt();
                    int months3 = ((diff3 % (86400 * 30*12)) / (86400 * 30)).toInt();

                    if(mineDistance1 <= 10)
                      {
                        mineData1(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                            minute2,year3,month3,date3,hour3,minute3,totalflags,
                          minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                          minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                        setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                        dialogNotificationmine1();
                        getData();
                      }
                    if(mineDistance12 <= 10)
                    {
                      mineData2(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance3 <= 10)
                    {
                      mineData3(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance4 <= 10)
                    {
                      mineData4(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance5 <= 10)
                    {
                      mineData5(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance6 <= 10)
                    {
                      mineData6(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance7 <= 10)
                    {
                      mineData7(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance8 <= 10)
                    {
                      mineData8(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance9 <= 10)
                    {
                      mineData9(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance10 <= 10)
                    {
                      mineData10(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance11 <= 10)
                    {
                      mineData11(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance12 <= 10)
                    {
                      mineData12(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance13 <= 10)
                    {
                      mineData13(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance14 <= 10)
                    {
                      mineData14(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance15 <= 10)
                    {
                      mineData15(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance16 <= 10)
                    {
                      mineData16(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance17 <= 10)
                    {
                      mineData17(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance18 <= 10)
                    {
                      mineData18(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance19 <= 10)
                    {
                      mineData19(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance20 <= 10)
                    {
                      mineData20(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance21 <= 10)
                    {
                      mineData21(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance22 <= 10)
                    {
                      mineData22(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance23 <= 10)
                    {
                      mineData23(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance24 <= 10)
                    {
                      mineData24(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance25 <= 10)
                    {
                      mineData25(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance26 <= 10)
                    {
                      mineData26(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance27 <= 10)
                    {
                      mineData27(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance28 <= 10)
                    {
                      mineData28(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance29 <= 10)
                    {
                      mineData29(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }
                    if(mineDistance30 <= 10)
                    {
                      mineData30(slat1,slong1,slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                        minute2,year3,month3,date3,hour3,minute3,totalflags,
                        minelat1, minelong1, minelat2, minelong2, minelat3, minelong3, minelat4, minelong4, minelat5, minelong5, minelat6, minelong6, minelat7, minelong7, minelat8, minelong8, minelat9, minelong9, minelat10, minelong10,
                        minelat11, minelong11, minelat12, minelong12, minelat13, minelong13, minelat14, minelong14, minelat15, minelong15, minelat16, minelong16, minelat17, minelong17, minelat18, minelong18, minelat19, minelong19, minelat20, minelong20, minelat21, minelong21, minelat22, minelong22, minelat23, minelong23, minelat24, minelong24, minelat25, minelong25, minelat26, minelong26, minelat27, minelong27, minelat28, minelong28, minelat29, minelong29, minelat30, minelong30,);
                      setUserDataMine(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotificationmine1();
                      getData();
                    }


                     if (distance1 <= 10) {
                       setData1(slat2,slong2,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                           minute2,year3,month3,date3,hour3,minute3,totalflags);
                       setUserData1(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                       dialogNotification();
                       getData();
                    }

                    if (distance2 <= 10) {
                      setData2(slat1,slong1,slat3,slong3,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                          minute2,year3,month3,date3,hour3,minute3,totalflags);
                      setUserData2(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotification();
                      getData();
                    }
                    if (distance3 <=10) {
                      setData3(slat1,slong1,slat2,slong2,year,month,date,hour,minute,year1,month1,date1,hour1,minute1,year2,month2,date2,hour2,
                          minute2,year3,month3,date3,hour3,minute3,totalflags);
                      setUserData3(UserID,PhotoUrl,Email,DispayName,flags,points,UPIid,);
                      dialogNotification();
                      getData();
                    }
                    // if (diff <= 0 &&
                    //     //!(lat1 == -1 && lat2 == -1 && lat3 == -1) &&
                    //     totalflags<0) {
                    //   totalflags = totalflags - 3;
                    //   setState(() async {
                    //     await collectionRef1.doc("XJ32MbbWc0QaWyVF2Grm").set({
                    //       "Latitude3": "-1",
                    //       "Longitude3": "-1",
                    //       "Latitude2": "-1",
                    //       "Longitude2": "-1",
                    //       "Latitude1": "-1",
                    //       "Longitude1": "-1",
                    //       "Year": year,
                    //       "Month": month,
                    //       "Date": date,
                    //       "Hour": hour,
                    //       "Minute": minute,
                    //       "Year1": year1,
                    //       "Month1": month1,
                    //       "Date1": date1,
                    //       "Hour1": hour1,
                    //       "Minute1": minute1,
                    //       "Year2": year2,
                    //       "Month2": month2,
                    //       "Date2": date2,
                    //       "Hour2": hour2,
                    //       "Minute2": minute2,
                    //       "Year3": year3,
                    //       "Month3": month3,
                    //       "Date3": date3,
                    //       "Hour3": hour3,
                    //       "Minute3": minute3,
                    //       "TotalFlags": totalflags,
                    //       'ImageLink1' : imageLink1,
                    //       'ImageLink2' : imageLink2,
                    //       'ImageLink3' : imageLink3,
                    //       // 'minelat1' : minelat1.toString(),
                    //       // 'minelat2' : minelat2.toString(),
                    //       // 'minelat3' : minelat3.toString(),
                    //       // 'minelat4' : minelat4.toString(),
                    //       // 'minelat5' : minelat5.toString(),
                    //       // 'minelat6' : minelat6.toString(),
                    //       // 'minelat7' : minelat7.toString(),
                    //       // 'minelat8' : minelat8.toString(),
                    //       // 'minelat9' : minelat9.toString(),
                    //       // 'minelat10' : minelat10.toString(),
                    //       // 'minelat11' : minelat11.toString(),
                    //       // 'minelat12' : minelat12.toString(),
                    //       // 'minelat13' : minelat13.toString(),
                    //       // 'minelat14' : minelat14.toString(),
                    //       // 'minelat15' : minelat15.toString(),
                    //       // 'minelat16' : minelat16.toString(),
                    //       // 'minelat17' : minelat17.toString(),
                    //       // 'minelat18' : minelat18.toString(),
                    //       // 'minelat19' : minelat19.toString(),
                    //       // 'minelat20' : minelat20.toString(),
                    //       // 'minelat21' : minelat21.toString(),
                    //       // 'minelat22' : minelat22.toString(),
                    //       // 'minelat23' : minelat23.toString(),
                    //       // 'minelat24' : minelat24.toString(),
                    //       // 'minelat25' : minelat25.toString(),
                    //       // 'minelat26' : minelat26.toString(),
                    //       // 'minelat27' : minelat27.toString(),
                    //       // 'minelat28' : minelat28.toString(),
                    //       // 'minelat29' : minelat29.toString(),
                    //       // 'minelat30' : minelat30.toString(),
                    //       //
                    //       // 'minelong1' : minelong1.toString(),
                    //       // 'minelong2' : minelong2.toString(),
                    //       // 'minelong3' : minelong3.toString(),
                    //       // 'minelong4' : minelong4.toString(),
                    //       // 'minelong5' : minelong5.toString(),
                    //       // 'minelong6' : minelong6.toString(),
                    //       // 'minelong7' : minelong7.toString(),
                    //       // 'minelong8' : minelong8.toString(),
                    //       // 'minelong9' : minelong9.toString(),
                    //       // 'minelong10' : minelong10.toString(),
                    //       // 'minelong11' : minelong11.toString(),
                    //       // 'minelong12' : minelong12.toString(),
                    //       // 'minelong13' : minelong13.toString(),
                    //       // 'minelong14' : minelong14.toString(),
                    //       // 'minelong15' : minelong15.toString(),
                    //       // 'minelong16' : minelong16.toString(),
                    //       // 'minelong17' : minelong17.toString(),
                    //       // 'minelong18' : minelong18.toString(),
                    //       // 'minelong19' : minelong19.toString(),
                    //       // 'minelong20' : minelong20.toString(),
                    //       // 'minelong21' : minelong21.toString(),
                    //       // 'minelong22' : minelong22.toString(),
                    //       // 'minelong23' : minelong23.toString(),
                    //       // 'minelong24' : minelong24.toString(),
                    //       // 'minelong25' : minelong25.toString(),
                    //       // 'minelong26' : minelong26.toString(),
                    //       // 'minelong27' : minelong27.toString(),
                    //       // 'minelong28' : minelong28.toString(),
                    //       // 'minelong29' : minelong29.toString(),
                    //       // 'minelong30' : minelong30.toString(),
                    //     });
                    //     // if (await Vibration.hasVibrator()) {
                    //     //   Vibration.vibrate();
                    //     // }
                    //     // showDialog(
                    //     //   context: context,
                    //     //   builder: (BuildContext context) {
                    //     //     return AlertDialog(
                    //     //       title: new Text("Alert!!"),
                    //     //       content: new Text("Times Up!!"),
                    //     //       actions: <Widget>[
                    //     //         new FlatButton(
                    //     //           child: new Text("OK"),
                    //     //           onPressed: () {
                    //     //             Navigator.of(context).pop();
                    //     //           },
                    //     //         ),
                    //     //       ],
                    //     //     );
                    //     //   },
                    //     //);
                    //   });
                    // }
                    return ListView(
                      children: [
                        Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                diff > 0
                                    ? Text(
                                        "$months months $days days $hours hrs $minutes min",
                                        style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(""),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
                                  child: lat1==-1 || diff <= 0 || diff1<=0 ? Container(height: 160) : Container(
                                    height: 160,
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child:
                                              Container(
                                                height: 80,
                                                width: 80,
                                                child: Image(
                                                  image: NetworkImage('$imageLink1'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Text(formattedDate,textAlign: TextAlign.center,style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 9),
                                                  child: lat1 == -1 || diff <= 0 || diff1<=0
                                                      ? Text(
                                                          'Flag Not Available',
                                                          style:
                                                              TextStyle(fontSize: 20),
                                                          textAlign: TextAlign.end,
                                                        )
                                                      : Text(
                                                          '$distance1 m',
                                                          style:
                                                              TextStyle(fontSize: 20,color: Colors.black),
                                                          textAlign: TextAlign.end,
                                                        ),
                                                ),
                                                diff1>=0 && lat1 !=-1 ? Padding(
                                                  padding: const EdgeInsets.fromLTRB(9, 20, 20, 20),
                                                  child: Text(
                                                    "$days1 days $hours1 hrs $minutes1 min",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ) : Text(""),
                                              ],
                                            )),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                        // image: DecorationImage(
                                        //   image: NetworkImage('$imageLink1'),
                                        //   fit: BoxFit.cover,
                                        //   colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.darken),
                                        // ),
                                        boxShadow: [
                                          BoxShadow(
                                            // color: Colors.grey.shade300,
                                            // color: Colors.green.shade100,

                                            offset: Offset(6, 6),
                                            blurRadius: 15,
                                            spreadRadius: 1,
                                          ),
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: lat2==-1 || diff <= 0 || diff2<=0 ? Container(height: 160) :Container(
                                    height: 160,
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                height: 80,
                                                width: 80,
                                                child: Image(
                                                  image: NetworkImage('$imageLink2'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 9),
                                                  child: lat2 == -1 || diff <= 0 || diff2<=0
                                                      ? Text(
                                                    'Flag Not Available',
                                                    style:
                                                    TextStyle(fontSize: 20),
                                                    textAlign: TextAlign.end,
                                                  )
                                                      : Text(
                                                    '$distance2 m',
                                                    style:
                                                    TextStyle(fontSize: 20,color: Colors.black),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                                diff2>=0 && lat2 !=-1 ? Padding(
                                                  padding: const EdgeInsets.fromLTRB(9, 20, 20, 20),
                                                  child: Text(
                                                    "$days2 days $hours2 hrs $minutes2 min",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ) : Text(""),
                                              ],
                                            )),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                        // image: DecorationImage(
                                        //   image: NetworkImage('$imageLink2'),
                                        //   fit: BoxFit.cover,
                                        //   colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
                                        // ),
                                        boxShadow: [
                                          BoxShadow(
                                            // color: Colors.grey.shade300,
                                            offset: Offset(6, 6),
                                            blurRadius: 15,
                                            spreadRadius: 1,
                                          ),
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                // lat2 == -1
                                //     ? Text("Flag2 Not Available")
                                //     : Text(
                                //         "$distance2 m",
                                //       ),
                                SizedBox(
                                  width: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: lat3==-1 || diff <= 0 || diff3<=0 ? Container(height: 160) :Container(
                                    height: 160,
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child:Container(
                                                child: Image(
                                                  image: NetworkImage('$imageLink3'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 9),
                                                  child: lat3 == -1 || diff <= 0 || diff3<=0
                                                      ? Text(
                                                    'Flag Not Available',
                                                    style:
                                                    TextStyle(fontSize: 20),
                                                    textAlign: TextAlign.end,
                                                  )
                                                      : Text(
                                                    '$distance3 m',
                                                    style:
                                                    TextStyle(fontSize: 20,color: Colors.black),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                                diff3>=0 && lat3 !=-1  ? Padding(
                                                  padding: const EdgeInsets.fromLTRB(9, 20, 20, 20),
                                                  child: Text(
                                                    "$days3 days $hours3 hrs $minutes3 min",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ) : Text(""),
                                              ],
                                            )),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                        // image: DecorationImage(
                                        //   image: NetworkImage('$imageLink3'),
                                        //   fit: BoxFit.cover,
                                        //   colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
                                        // ),
                                        boxShadow: [
                                          BoxShadow(
                                            // color: Colors.grey.shade300,
                                            offset: Offset(6, 6),
                                            blurRadius: 15,
                                            spreadRadius: 1,
                                          ),
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                totalflags >= 0
                                    ? Text(
                                        "Total Countries Remaining : $totalflags",
                                        style: TextStyle(fontSize: 20),
                                      )
                                    : Text(
                                        "Total Countries Remaining : 0",
                                        style: TextStyle(fontSize: 20),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return LinearProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                    backgroundColor: Colors.white,
                  );
                },
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
  // leaderboard

  Scaffold leaderboard() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade50,
        title: Text("LeaderBoard",style: TextStyle(color: Colors.black),),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('flagusers').snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasError) return Text('Error = ${snapshot.error}');
          if (!snapshot.hasData) {
            return LinearProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
              backgroundColor: Colors.white,
            );
          }
          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            docs.sort((a, b) {
              int d1 = a["Points"];
              int d2 = b["Points"];
              return d2.compareTo(d1);
            });
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final data = docs[i].data();
                String p = data['Points'].toString();
                String pic = data['photoUrl'];
                var rank = i+1;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Card(
                      color: Colors.grey.shade50,
                      // elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      shadowColor: Colors.blueGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                          leading: Container(
                            width: 80,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('#$rank'),
                                    SizedBox(width: 5,),
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        "$pic",
                                      ),
                                      radius: 25,
                                      backgroundColor: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          title: Text(
                            data['displayName'],
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text('Points:' + '$p'),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return LinearProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }
  //profile
  Scaffold profile() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade50,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () {
              logout();
              setState(() {
                isAuth = false;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(
            //   height: 20,
            // ),
            // Center(child: Container(child:Text("Profile",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),)),
            SizedBox(height: 30),
            Center(
              child: Container(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    "$PhotoUrl",
                  ),
                  radius: 80,
                  backgroundColor: Colors.red,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "$DispayName",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 7),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                height: 50,
                width: double.infinity,
                child: Center(
                    child: Text(
                  "Ranking : $position",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
            // SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 7),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: double.infinity,
                child: Center(
                    child: Text(
                  "Flags Collected : $flags",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 7),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                width: double.infinity,
                child: Center(
                    child: Text(
                  "Points : $points",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "UPI ID - $UPIid",
                        textAlign: TextAlign.start,
                      )),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 7),
                    child: TextField(
                      controller: UPIcontroller,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(46, 100, 252, 100),
                                width: 2.0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: "Enter Your UPI"),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 7),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromRGBO(46, 100, 252, 100)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        print(UPIcontroller.text);
                        await collectionRef.doc("$UserID").set({
                          "id": UserID,
                          "photoUrl": PhotoUrl,
                          "email": Email,
                          "displayName": DispayName,
                          "Flags": flags,
                          "Points": points,
                          'UPI': UPIcontroller.text.toString(),
                        });
                        getData();
                      },
                      child: Text("Submit your UPI ID"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Scaffold Loading() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: CircularProgressIndicator(
              color: Color.fromRGBO(46, 140, 252, 100),
            )),
            Text("Loading"),
          ],
        ),
      ),
    );
  }

  Scaffold buildAuthScreen(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          home(context),
          leaderboard(),
          profile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.black,
        //backgroundColor: Theme.of(context).accentColor,
        currentIndex: pageIndex,
        onTap: onTap,
        //inactiveColor: Theme.of(context).primaryColor,
        activeColor: Colors.white,
        // activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: pageIndex == 0 ? Icon(Icons.home) : Icon(Icons.home_outlined),
          ),
          BottomNavigationBarItem(
            icon: pageIndex == 1
                ? Icon(Icons.leaderboard)
                : Icon(Icons.leaderboard_outlined),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding:
                  pageIndex == 2 ? EdgeInsets.all(5.0) : EdgeInsets.all(5.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage("$PhotoUrl"),
                radius: pageIndex == 2 ? 16 : 13,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: login,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      child: Text(
                        "Flag Hunt",
                        style: TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Container(
                      width: 260,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/google_signin_button.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen(context) : buildUnAuthScreen();
  }
}

class Details1 {
  final int flags;
  final int points;
  final String displayName;
  final String email;
  final String id;
  final String photoUrl;
  final String upiId;
  Details1({
    required this.flags,
    required this.points,
    required this.displayName,
    required this.email,
    required this.id,
    required this.photoUrl,
    required this.upiId,
  });
  static Details1 fromJson(Map<String, dynamic> json) => Details1(
        flags: json['Flags'],
        points: json['Points'],
        displayName: json['displayName'],
        email: json['email'],
        id: json['id'],
        photoUrl: json['photoUrl'],
        upiId: json['UPI'],
      );
}

class Details2 {
  final String Latitude1;
  final String Latitude2;
  final String Latitude3;
  final String Longitude1;
  final String Longitude2;
  final String Longitude3;
  Details2({
    required this.Latitude1,
    required this.Latitude2,
    required this.Latitude3,
    required this.Longitude1,
    required this.Longitude2,
    required this.Longitude3,
  });
  static Details2 fromJson(Map<String, dynamic> json1) => Details2(
        Latitude1: json1['Latitude1'],
        Latitude2: json1['Latitude2'],
        Latitude3: json1['Latitude3'],
        Longitude1: json1['Longitude1'],
        Longitude2: json1['Longitude2'],
        Longitude3: json1['Longitude3'],
      );
}

/*
  Scaffold leaderboard() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade50,
        title: Text("LeaderBoard",style: TextStyle(color: Colors.black),),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('flagusers').snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasError) return Text('Error = ${snapshot.error}');
          if (!snapshot.hasData) {
            return LinearProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
              backgroundColor: Colors.white,
            );
          }
          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            docs.sort((a, b) {
              int d1 = a["Points"];
              int d2 = b["Points"];
              return d2.compareTo(d1);
            });
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final data = docs[i].data();
                String p = data['Points'].toString();
                String pic = data['photoUrl'];
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Card(
                    color: Colors.blue.shade50,
                    // elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    shadowColor: Colors.blueGrey,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        leading: Container(
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "$pic",
                                ),
                                radius: 25,
                                backgroundColor: Colors.red,
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          data['displayName'],
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text('Points:' + '$p'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return LinearProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }
*/


/*
  Scaffold leaderboard() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade50,
        title: Text(
          "LeaderBoard",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('flagusers').snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasError) return Text('Error = ${snapshot.error}');
          if (!snapshot.hasData) {
            return LinearProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
              backgroundColor: Colors.white,
            );
          }
          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            docs.sort((a, b) {
              int d1 = a["Points"];
              int d2 = b["Points"];
              return d2.compareTo(d1);
            });
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final data = docs[i].data();
                var count = i;
                final data1 = docs[0].data();
                final data2 = docs[1].data();
                final data3 = docs[2].data();

                String p = data['Points'].toString();
                String p1 = data1['Points'].toString();
                String p2 = data2['Points'].toString();
                String p3 = data3['Points'].toString();
                String pic = data['photoUrl'];
                String pic1 = data1['photoUrl'];
                String pic2 = data2['photoUrl'];
                String pic3 = data3['photoUrl'];
                var rank = i+1;
                return i == 0
                    ? Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('https://badgeos.org/wp-content/uploads/2018/06/badges_0004_leaderboard-300x300.png'),
                            fit: BoxFit.cover,
                            // colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.12), BlendMode.darken),
                            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstOut),
                          ),
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: Offset(6, 6),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ]),
                        height: 300,
                        width: double.infinity,
                        // color: Colors.yellowAccent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: count >= 1 ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('#2nd',style: TextStyle(fontWeight: FontWeight.bold),),
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundImage: NetworkImage(
                                              "$pic2",
                                            ),
                                          ),
                                          Text(data2['displayName'],style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text('Points : $p2'),
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text('#1st',style: TextStyle(fontWeight: FontWeight.bold),),
                                        CircleAvatar(
                                          radius: 70,
                                          backgroundImage: NetworkImage(
                                            "$pic1",
                                          ),
                                        ),
                                        Text(data1['displayName'],style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('Points : $p1'),
                                      ],
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('#3nd',style: TextStyle(fontWeight: FontWeight.bold),),
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundImage: NetworkImage(
                                            "$pic3",
                                          ),
                                        ),
                                        Text(data3['displayName'],style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('Points : $p3'),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      )
                    : i > 2
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Card(
                              color: Colors.grey.shade50,
                              // elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              shadowColor: Colors.blueGrey,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  leading: Container(
                                    width: 80,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text('#$rank'),
                                            SizedBox(width: 5,),
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                "$pic",
                                              ),
                                              radius: 25,
                                              backgroundColor: Colors.red,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    data['displayName'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text('Points:' + '$p'),
                                ),
                              ),
                            ),
                          )
                        : Container();
              },
            );
          }
          return LinearProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }*/// 'minelat1' : minelat1.toString(),
// 'minelat2' : minelat2.toString(),
// 'minelat3' : minelat3.toString(),
// 'minelat4' : minelat4.toString(),
// 'minelat5' : minelat5.toString(),
// 'minelat6' : minelat6.toString(),
// 'minelat7' : minelat7.toString(),
// 'minelat8' : minelat8.toString(),
// 'minelat9' : minelat9.toString(),
// 'minelat10' : minelat10.toString(),
// 'minelat11' : minelat11.toString(),
// 'minelat12' : minelat12.toString(),
// 'minelat13' : minelat13.toString(),
// 'minelat14' : minelat14.toString(),
// 'minelat15' : minelat15.toString(),
// 'minelat16' : minelat16.toString(),
// 'minelat17' : minelat17.toString(),
// 'minelat18' : minelat18.toString(),
// 'minelat19' : minelat19.toString(),
// 'minelat20' : minelat20.toString(),
// 'minelat21' : minelat21.toString(),
// 'minelat22' : minelat22.toString(),
// 'minelat23' : minelat23.toString(),
// 'minelat24' : minelat24.toString(),
// 'minelat25' : minelat25.toString(),
// 'minelat26' : minelat26.toString(),
// 'minelat27' : minelat27.toString(),
// 'minelat28' : minelat28.toString(),
// 'minelat29' : minelat29.toString(),
// 'minelat30' : minelat30.toString(),
//
// 'minelong1' : minelong1.toString(),
// 'minelong2' : minelong2.toString(),
// 'minelong3' : minelong3.toString(),
// 'minelong4' : minelong4.toString(),
// 'minelong5' : minelong5.toString(),
// 'minelong6' : minelong6.toString(),
// 'minelong7' : minelong7.toString(),
// 'minelong8' : minelong8.toString(),
// 'minelong9' : minelong9.toString(),
// 'minelong10' : minelong10.toString(),
// 'minelong11' : minelong11.toString(),
// 'minelong12' : minelong12.toString(),
// 'minelong13' : minelong13.toString(),
// 'minelong14' : minelong14.toString(),
// 'minelong15' : minelong15.toString(),
// 'minelong16' : minelong16.toString(),
// 'minelong17' : minelong17.toString(),
// 'minelong18' : minelong18.toString(),
// 'minelong19' : minelong19.toString(),
// 'minelong20' : minelong20.toString(),
// 'minelong21' : minelong21.toString(),
// 'minelong22' : minelong22.toString(),
// 'minelong23' : minelong23.toString(),
// 'minelong24' : minelong24.toString(),
// 'minelong25' : minelong25.toString(),
// 'minelong26' : minelong26.toString(),
// 'minelong27' : minelong27.toString(),
// 'minelong28' : minelong28.toString(),
// 'minelong29' : minelong29.toString(),
// 'minelong30' : minelong30.toString(),