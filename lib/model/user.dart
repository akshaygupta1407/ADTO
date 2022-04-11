import 'package:cloud_firestore/cloud_firestore.dart';

class Details{
  // String id;
  // final String name;
  // final int age;

  final String businessName;
  final String distance;
  final String startTime;
  final String endTime;
  final String imageUrl;
  final String latitude,longitude;

  Details({
   required this.businessName,
    required this.distance,
    required this.startTime,
    required this.endTime,
    required this.imageUrl,
    required this.latitude,
    required this.longitude


});
  Map<String, dynamic> toJson()=>{
    'BusinessName' : businessName,
    'Distance' : distance,
    'StartTime' : startTime,
    'EndTime' : endTime,
    'ImageUrl' : imageUrl,
    'Latitude' : latitude,
    'Longitude' : longitude,
  };

  static Details fromJson(Map<String,dynamic> json) => Details(
    businessName: json['BusinessName'],
    distance: json['Distance'],
    startTime: json['StartTime'],
    endTime: json['EndTime'],
    imageUrl: json['ImageUrl'],
    latitude: json['Latitude'],
    longitude: json['Longitude'],
  );
}