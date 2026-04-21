// import 'dart:convert';
// import 'package:employee_app/services/apis_services.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
//
// class AttensanceController extends GetxController {
//   ApiServices apiServices = ApiServices();
//   LatLng? currentLocation;
//
//   // Store as nullable doubles
//   double officeLat = 0.0;
//   // LatLng maplatlong = LatLng(22.25872800, 70.78921800);
//   double officeLng = 0.0;
//
//   var isLoading = true.obs;
//   RxString attendenceType = "".obs;
//   RxString status = ''.obs;
//   RxString time = ''.obs;
//   String userId = "";
//    var Attsdancehistorylist = [].obs;
//
//   @override
//   void onInit() {
//     isLoading = false.obs;
//     fetchcompanylocation();
//     super.onInit();
//   }
//
//   Future<void> fetchcompanylocation() async {
//     isLoading.value = true;
//     try {
//       http.Response response = await apiServices.FetchCompanylocation();
//
//       if (response.statusCode == 200) {
//         var extractdata = jsonDecode(response.body);
//         print("extractdata  $extractdata");
//
//         if (extractdata["status"] == "true" || extractdata["status"] == true) {
//           var data = extractdata["data"];
//           // Handle if 'data' is a List instead of a Map
//           Map<String, dynamic> locationMap;
//           if (data is List && data.isNotEmpty) {
//             locationMap = data[0]; // Take the first object in the list
//           } else if (data is Map<String, dynamic>) {
//             locationMap = data;
//           } else {
//             print("Invalid data format");
//             return;
//           }
//
//           // Use double.tryParse because APIs often send numbers as Strings
//           // and .toDouble() only works if the value is already a num type.
//           officeLat = double.tryParse(locationMap["latitude"].toString()) ?? 22.25872800;
//           officeLng = double.tryParse(locationMap["longitude"].toString()) ?? 70.78921800;
//
//           print("officeLat ====> $officeLat");
//           print("officeLng ====> $officeLng");
//           isLoading.value = false;
//
//           // IMPORTANT: Trigger a UI update if you're using GetX variables
//           update();
//         }
//       } else {
//         print("Failed to fetch location: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching location: $e");
//     }
//   }
//
//   // Future<void> fetchcompanylocation() async {
//   //   try {
//   //     http.Response response = await apiServices.FetchCompanylocation();
//   //
//   //     if (response.statusCode == 200) {
//   //       var extractdata = jsonDecode(response.body);
//   //       print("extractdata  $extractdata");
//   //
//   //       if (extractdata["status"] == "true" || extractdata["status"] == true) {
//   //         // Check if data exists and is a Map
//   //         if (extractdata["data"] != null && extractdata["data"] is Map) {
//   //           var dataMap = extractdata["data"] as Map;
//   //
//   //           // Parse strings to double
//   //           double lat = double.tryParse(dataMap["latitude"].toString()) ?? 0.0;
//   //           double long = double.tryParse(dataMap["longitude"].toString()) ?? 0.0;
//   //           maplatlong = LatLng(lat, long);
//   //
//   //           print("officeLat ====> $lat");
//   //           print("officeLng ====> $long");
//   //         } else {
//   //           print("Data is not in expected format: ${extractdata["data"]}");
//   //         }
//   //       } else {
//   //         print("Status is not true: ${extractdata["status"]}");
//   //       }
//   //     } else {
//   //       print("Failed to fetch location: ${response.statusCode}");
//   //     }
//   //   } catch (e) {
//   //     print("Error fetching location: $e");
//   //   }
//   // }
//
//
// // check in check out
//
//   // check in And Check out
//    attandance() async {
//     http.Response response;
//
//     // UI માં જો "Check-In" હોય તો "in", નહિતર "out"
//     // .trim() અને .toLowerCase() વાપરવું જેથી સ્પેલિંગ મિસ્ટેક ના થાય
//     String currentType = attendenceType.value.trim();
//     String apiType = (currentType == "check-in") ? "checkin" : "checkout";
//
//     print("Sending user_id: $userId");
//     print("Sending type: $apiType");
//
//     response = await apiServices.attendance(
//       user_id : userId,
//       type: apiType,
//     );
//
//     if(response.statusCode == 200){
//       var data = jsonDecode(response.body);
//       print("Response: ${data}");
//
//       if(data['status'] == true || data['status'] == 'true'){
//         status.value = data['data']['status'];
//         time.value = data['data']['time'];
//
//       } else {
//         print("API Message: ${data['message']}");
//       }
//     } else {
//       print("Server Error: ${response.statusCode}");
//     }
//   }
//
//
//   // Atanhdance History
//
// void attandancehistory ()async{
//     http.Response response;
//
//     response = await apiServices.AttandanceHistory(
//         userId
//     );
//     if(response.statusCode == 200){
//       var extractdata = jsonDecode(response.body);
//       print("extractdata Attsdancehistorylist======> $extractdata");
//
//       if(extractdata["status"] == "true" || extractdata["status"] == true)
//       {
//          Attsdancehistorylist.value = extractdata["data"];
//
//       }
//     }else {
//       print("Error in Attsdancehistorylist");
//     }
//
// }
//
// }



import 'dart:convert';
import 'package:employee_app/Model/rulesModel.dart';
import 'package:employee_app/services/apis_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/colers.dart' as Colors;

class AttensanceController extends GetxController {
  ApiServices apiServices = ApiServices();
  LatLng? currentLocation;

  GoogleMapController? mapController;
  RxBool mapInitialized = false.obs;

  RxSet<Marker> markers = <Marker>{}.obs;
  RxSet<Circle> circles = <Circle>{}.obs;

  // Store as nullable doubles
  double officeLat = 0.0;
  // LatLng maplatlong = LatLng(22.25872800, 70.78921800);
  double officeLng = 0.0;

  var isLoading = true.obs;
  RxString attendenceType = "".obs;
  RxString status = ''.obs;
  RxString time = ''.obs;
  String userId = "";
  String companyId = "";
  var Attsdancehistorylist = [].obs;
  RxInt companyDistance = 0.obs;
  RxList rulesList = <Rulesmodel>[].obs;

  @override
  void onInit() {
    isLoading = false.obs;
    getID();
    super.onInit();
  }


  @override
  void onClose() {
    mapController?.dispose();
    mapController = null;
    markers.clear();
    circles.clear();
    super.onClose();
  }

  void resetMapState() {
    mapInitialized.value = false;
    mapController = null;
    markers.clear();
    circles.clear();
  }


  getID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = await sp.getString("user_id") ?? "";
    companyId = await sp.getString('company_id') ?? "";

    print("user id ===> ${userId}");
    print("comapnyid ===> ${companyId}");

    fetchcompanylocation();
    getcompanyDistance();
    getattendanceRules();
  }


  // Future<void> updateMapMarkers() async {
  //   // Only proceed if map is initialized AND we have valid data
  //   if (!mapInitialized.value || mapController == null) {
  //     print("Map not ready for update");
  //     return;
  //   }
  //
  //   // Ensure we have valid office coordinates
  //   if (officeLat == 0.0 || officeLng == 0.0) {
  //     print("Office coordinates not ready");
  //     return;
  //   }
  //
  //   try {
  //     print('Updating map markers - Office: $officeLat, $officeLng');
  //     print('Company Distance: ${companyDistance.value}');
  //
  //     Set<Marker> newMarkers = {};
  //
  //     final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
  //       const ImageConfiguration(size: Size(48, 48)),
  //       'assets/images/piicon.png',
  //     );
  //
  //     // Office marker only
  //     newMarkers.add(
  //       Marker(
  //         markerId: const MarkerId('office'),
  //         position: LatLng(officeLat, officeLng),
  //         infoWindow: const InfoWindow(title: 'Office Location'),
  //         icon: customIcon,
  //       ),
  //     );
  //
  //     Set<Circle> newCircles = {};
  //
  //     // Geofence circle
  //     if (companyDistance.value > 0) {
  //       newCircles.add(
  //         Circle(
  //           circleId: const CircleId('geofence'),
  //           center: LatLng(officeLat, officeLng),
  //           radius: companyDistance.value.toDouble(),
  //           fillColor: Colors.green.withOpacity(0.2),
  //           strokeColor: Colors.green,
  //           strokeWidth: 2,
  //         ),
  //       );
  //     }
  //
  //     // Update the state
  //     markers.assignAll(newMarkers);
  //     circles.assignAll(newCircles);
  //
  //     // CRITICAL: Call update() to refresh the UI
  //     update();
  //
  //     print('Map markers updated successfully');
  //   } catch (e) {
  //     print("Error updating map markers: $e");
  //   }
  // }


  void updateMapMarkers() async {
    if (!mapInitialized.value || mapController == null) return;
    if (officeLat == 0.0 || officeLng == 0.0) return;

    try {
      // Create a colored marker programmatically
      final BitmapDescriptor customIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/red_pin.png', // You still need an image
      ).catchError((e) {
        print("Error loading asset: $e");
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      });

      markers.clear();
      circles.clear();

      markers.assign(
        Marker(
          markerId: const MarkerId('office'),
          // position: LatLng(officeLat, officeLng),
          position: LatLng(22.25882,70.7884373),
          infoWindow: const InfoWindow(title: 'Office Location'),
          icon: await customIcon,
        ),
      );

      if (companyDistance.value > 0) {
        circles.assign(
          Circle(
            circleId: const CircleId('geofence'),
            center: LatLng(officeLat, officeLng),
            radius: companyDistance.value.toDouble(),
            fillColor: Colors.green.withOpacity(0.2),
            strokeColor: Colors.green,
            strokeWidth: 2,
          ),
        );
      }

      update();
      print('Marker with image added');
    } catch (e) {
      print("Error: $e");
    }
  }

  void refreshMap() {
    if (mapInitialized.value && officeLat != 0.0 && officeLng != 0.0) {
      updateMapMarkers();
    }
  }

  Future<void> getcompanyDistance() async{
    print("getcompanyDistance fun called in controller");
    try {

      http.Response response =  await apiServices.getDistance(userId);
      if(response.statusCode == 200){
        var extactdata = jsonDecode(response.body);
        print('extactdata $extactdata');
        if(extactdata["status"] == "true" || extactdata["status"] == true){
          String distance =   extactdata['allowed_distance_meters'].toString();
          companyDistance.value = int.tryParse(distance) ?? 0;
          print('companyDistance.value in getcompanyDistance fun  ${companyDistance.value}');
          // updateMapMarkers();
          update();


        }else{
          print("Error status false");


        }
      }else{
        print("Error statuscode in getcompany distance ${response.statusCode}");

      }

    }catch(e){
      print("eror in getDistance $e");

    }

  }

  Future<void> fetchcompanylocation() async {
    isLoading.value = true;
    try {
      http.Response response = await apiServices.FetchCompanylocation();

      if (response.statusCode == 200) {
        var extractdata = jsonDecode(response.body);
        print("extractdata  $extractdata");

        if (extractdata["status"] == "true" || extractdata["status"] == true) {
          var data = extractdata["data"];
          // Handle if 'data' is a List instead of a Map
          Map<String, dynamic> locationMap;
          if (data is List && data.isNotEmpty) {
            locationMap = data[0]; // Take the first object in the list
          } else if (data is Map<String, dynamic>) {
            locationMap = data;
          } else {
            print("Invalid data format");
            return;
          }

          // Use double.tryParse because APIs often send numbers as Strings
          // and .toDouble() only works if the value is already a num type.
          officeLat = double.tryParse(locationMap["latitude"].toString()) ?? 22.25872800;
          officeLng = double.tryParse(locationMap["longitude"].toString()) ?? 70.78921800;

          print("officeLat ====> $officeLat");
          print("officeLng ====> $officeLng");
          isLoading.value = false;
          // updateMapMarkers();

          // IMPORTANT: Trigger a UI update if you're using GetX variables
          update();
        }
      } else {
        print("Failed to fetch location: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  // Future<void> fetchcompanylocation() async {
  //   try {
  //     http.Response response = await apiServices.FetchCompanylocation();
  //
  //     if (response.statusCode == 200) {
  //       var extractdata = jsonDecode(response.body);
  //       print("extractdata  $extractdata");
  //
  //       if (extractdata["status"] == "true" || extractdata["status"] == true) {
  //         // Check if data exists and is a Map
  //         if (extractdata["data"] != null && extractdata["data"] is Map) {
  //           var dataMap = extractdata["data"] as Map;
  //
  //           // Parse strings to double
  //           double lat = double.tryParse(dataMap["latitude"].toString()) ?? 0.0;
  //           double long = double.tryParse(dataMap["longitude"].toString()) ?? 0.0;
  //           maplatlong = LatLng(lat, long);
  //
  //           print("officeLat ====> $lat");
  //           print("officeLng ====> $long");
  //         } else {
  //           print("Data is not in expected format: ${extractdata["data"]}");
  //         }
  //       } else {
  //         print("Status is not true: ${extractdata["status"]}");
  //       }
  //     } else {
  //       print("Failed to fetch location: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error fetching location: $e");
  //   }
  // }


// check in check out

  // check in And Check out
  attandance() async {
    http.Response response;

    // UI માં જો "Check-In" હોય તો "in", નહિતર "out"
    // .trim() અને .toLowerCase() વાપરવું જેથી સ્પેલિંગ મિસ્ટેક ના થાય
    String currentType = attendenceType.value.trim();
    String apiType = (currentType == "check-in") ? "checkin" : "checkout";

    print("Sending user_id: $userId");
    print("Sending type: $apiType");

    response = await apiServices.attendance(
      user_id : userId,
      type: apiType,
    );

    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      print("Response: ${data}");

      if(data['status'] == true || data['status'] == 'true'){
        status.value = data['data']['status'];
        time.value = data['data']['time'];

      } else {
        print("API Message: ${data['message']}");
      }
    } else {
      print("Server Error: ${response.statusCode}");
    }
  }


  // Atanhdance History

  void attandancehistory ()async{
    http.Response response;

    response = await apiServices.AttandanceHistory(
        userId
    );
    if(response.statusCode == 200){
      var extractdata = jsonDecode(response.body);
      print("extractdata Attsdancehistorylist======> $extractdata");

      if(extractdata["status"] == "true" || extractdata["status"] == true)
      {
        Attsdancehistorylist.value = extractdata["data"];

      }
    }else {
      print("Error in Attsdancehistorylist");
    }

  }

  Future<void> getattendanceRules()async{
    http.Response response;
    response = await apiServices.getattendanceRules(userId,companyId);
    if(response.statusCode == 200){
      var extractdata = jsonDecode(response.body);

      if(extractdata["success"] == "true" || extractdata["success"] == true){
        List rules = extractdata["data"]['rules'];
       rulesList.value = List<Rulesmodel>.from(rules.map((e) => Rulesmodel.fromJson(e),));

      }else{
        print('error ${extractdata["message"]}');

      }

    }else{
      print('error in status code = ${response.statusCode}');

    }


  }


}