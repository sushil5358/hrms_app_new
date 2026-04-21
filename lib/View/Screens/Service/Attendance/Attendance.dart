// import 'dart:math';
// import 'package:employee_app/utils/colers.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:intl/intl.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../Controller/Attendance_controller.dart';
// import 'history.dart';
//
// class Attendance extends StatefulWidget {
//   const Attendance({super.key});
//
//   @override
//   State<Attendance> createState() => _AttendanceState();
// }
//
// enum ShiftType { day, night, rotational }
// enum AttendanceStatus { present, late, halfDay, absent }
// enum DateFilterType { today, thisWeek, thisMonth, custom }
//
// // Location model for attendance records
// class LocationData {
//   final double latitude;
//   final double longitude;
//   final String address;
//
//   LocationData({
//     required this.latitude,
//     required this.longitude,
//     required this.address,
//   });
//
//   LatLng get latLng => LatLng(latitude, longitude);
//
//   String get formattedCoordinates =>
//       '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
// }
//
// // Model class for attendance records
// class AttendanceRecord {
//   final DateTime date;
//   final ShiftType shift;
//   final DateTime? checkIn;
//   final DateTime? checkOut;
//   final AttendanceStatus status;
//   final double? distance;
//   final bool faceVerified;
//   final LocationData? checkInLocation;
//   final LocationData? checkOutLocation;
//
//   AttendanceRecord({
//     required this.date,
//     required this.shift,
//     this.checkIn,
//     this.checkOut,
//     required this.status,
//     this.distance,
//     required this.faceVerified,
//     this.checkInLocation,
//     this.checkOutLocation,
//   });
//
//   String get formattedDate => DateFormat('dd MMM yyyy').format(date);
//
//   String get formattedDay => DateFormat('EEEE').format(date);
//
//   String get formattedCheckIn =>
//       checkIn != null ? DateFormat('hh:mm a').format(checkIn!) : '-';
//
//   String get formattedCheckOut =>
//       checkOut != null ? DateFormat('hh:mm a').format(checkOut!) : '-';
//
//   bool get hasCheckInLocation => checkInLocation != null;
//
//   bool get hasCheckOutLocation => checkOutLocation != null;
// }
//
// class _AttendanceState extends State<Attendance> {
//
//   // Inside your State class
//   final AttensanceController controller = Get.put(AttensanceController());
//
//   // Allowed radius (meters) for restricted punch (geofence)
//   final double allowedRadiusMeters = 50;
//
//   // --- Shift settings ---
//   ShiftType selectedShift = ShiftType.day;
//
//   // Stored state (you can replace with API/database)
//   DateTime? checkInTime;
//   DateTime? checkOutTime;
//   LocationData? checkInLocation;
//   LocationData? checkOutLocation;
//
//   bool isInsideOffice = false;
//   double? distanceFromOfficeMeters;
//   bool faceVerified = false;
//
//   AttendanceStatus? status;
//
//   // Track if attendance is already completed for today
//   bool hasCheckedInToday = false;
//   bool hasCheckedOutToday = false;
//
//   // Attendance history list
//   List<AttendanceRecord> attendanceHistory = [];
//
//   final DateFormat fmt = DateFormat('hh:mm a');
//
//   // Google Maps related variables
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   Set<Circle> _circles = {};
//
//   bool _mapInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _refreshLocationAndOfficeStatus();
//     _computeStatus();
//     controller.fetchcompanylocation();
//     getID();
//     _checkTodayAttendanceStatus();
//
//     // Add listener to update status when controller data changes
//     ever(controller.status, (_) {
//       setState(() {
//         _updateStatusFromAPI();
//         _checkTodayAttendanceStatus();
//       });
//     });
//
//     ever(controller.time, (_) {
//       setState(() {
//         _updateStatusFromAPI();
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
//
//   getID() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     controller.userId = await sp.getString("user_id") ?? "";
//     print("user id ===> ${controller.userId}");
//   }
//
//   // Check if user has already checked in/out today
//   void _checkTodayAttendanceStatus() {
//     final today = DateTime.now();
//
//     // Check if there's any attendance record for today in history
//     final todayRecord = attendanceHistory.firstWhere(
//           (record) => record.date.year == today.year &&
//           record.date.month == today.month &&
//           record.date.day == today.day,
//       orElse: () => AttendanceRecord(
//         date: today,
//         shift: selectedShift,
//         status: AttendanceStatus.absent,
//         faceVerified: false,
//       ),
//     );
//
//     setState(() {
//       hasCheckedInToday = todayRecord.checkIn != null;
//       hasCheckedOutToday = todayRecord.checkOut != null;
//     });
//   }
//
//   // Update status based on API data
//   void _updateStatusFromAPI() {
//     String statusValue = controller.status.value.toLowerCase();
//
//     if (statusValue.contains('present')) {
//       status = AttendanceStatus.present;
//     } else if (statusValue.contains('late')) {
//       status = AttendanceStatus.late;
//     } else if (statusValue.contains('half')) {
//       status = AttendanceStatus.halfDay;
//     } else if (statusValue.contains('absent')) {
//       status = AttendanceStatus.absent;
//     } else {
//       // If no check-in, keep as absent
//       if (checkInTime == null) {
//         status = AttendanceStatus.absent;
//       }
//     }
//   }
//
//   // Get address from coordinates (mock function - replace with actual geocoding)
//   Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
//     // In a real app, use Geocoding package to get actual address
//     await Future.delayed(const Duration(milliseconds: 100));
//     return "Location: $latitude, $longitude";
//   }
//
//   // ---------- UI HELPERS ----------
//   String shiftLabel(ShiftType s) {
//     switch (s) {
//       case ShiftType.day:
//         return "Day";
//       case ShiftType.night:
//         return "Night";
//       case ShiftType.rotational:
//         return "Rotational";
//     }
//   }
//
//   String statusLabel(AttendanceStatus s) {
//     switch (s) {
//       case AttendanceStatus.present:
//         return "Present";
//       case AttendanceStatus.late:
//         return "Late";
//       case AttendanceStatus.halfDay:
//         return "Half-day";
//       case AttendanceStatus.absent:
//         return "Absent";
//     }
//   }
//
//   Color statusColor(AttendanceStatus s) {
//     switch (s) {
//       case AttendanceStatus.present:
//         return Colors.green;
//       case AttendanceStatus.late:
//         return Colors.orange;
//       case AttendanceStatus.halfDay:
//         return Colors.deepOrange;
//       case AttendanceStatus.absent:
//         return Colors.red;
//     }
//   }
//
//   IconData statusIcon(AttendanceStatus s) {
//     switch (s) {
//       case AttendanceStatus.present:
//         return Icons.check_circle;
//       case AttendanceStatus.late:
//         return Icons.access_time;
//       case AttendanceStatus.halfDay:
//         return Icons.warning_amber_rounded;
//       case AttendanceStatus.absent:
//         return Icons.cancel;
//     }
//   }
//
//   // ---------- SHIFT RULES ----------
//   DateTime _shiftStartToday(ShiftType shift) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//
//     switch (shift) {
//       case ShiftType.day:
//         return today.add(const Duration(hours: 9, minutes: 0)); // 9:00 AM
//       case ShiftType.night:
//         return today.add(const Duration(hours: 21, minutes: 0)); // 9:00 PM
//       case ShiftType.rotational:
//         final isEvenDay = today.day % 2 == 0;
//         return isEvenDay
//             ? today.add(const Duration(hours: 9))
//             : today.add(const Duration(hours: 21));
//     }
//   }
//
//   AttendanceStatus _statusFromCheckIn(DateTime? inTime, ShiftType shift) {
//     if (inTime == null) return AttendanceStatus.absent;
//
//     final start = _shiftStartToday(shift);
//     final diffMinutes = inTime.difference(start).inMinutes;
//
//     if (diffMinutes <= 10) return AttendanceStatus.present;
//     if (diffMinutes <= 60) return AttendanceStatus.late;
//     if (diffMinutes <= 240) return AttendanceStatus.halfDay;
//     return AttendanceStatus.absent;
//   }
//
//   void _computeStatus() {
//     setState(() {
//       if (controller.status.value.isNotEmpty) {
//         _updateStatusFromAPI();
//       } else {
//         status = _statusFromCheckIn(checkInTime, selectedShift);
//       }
//     });
//   }
//
//   // Add current attendance to history after checkout
//   void _addToHistory() async {
//     if (checkInTime != null) {
//       // Get address for check-in location
//       String checkInAddress = "Unknown location";
//       if (checkInLocation != null) {
//         checkInAddress = await _getAddressFromLatLng(
//           checkInLocation!.latitude,
//           checkInLocation!.longitude,
//         );
//       }
//
//       // Get address for check-out location
//       String checkOutAddress = "Unknown location";
//       if (checkOutLocation != null) {
//         checkOutAddress = await _getAddressFromLatLng(
//           checkOutLocation!.latitude,
//           checkOutLocation!.longitude,
//         );
//       }
//
//       final record = AttendanceRecord(
//         date: DateTime.now(),
//         shift: selectedShift,
//         checkIn: checkInTime,
//         checkOut: checkOutTime,
//         status: status ?? AttendanceStatus.absent,
//         distance: distanceFromOfficeMeters,
//         faceVerified: faceVerified,
//         checkInLocation: checkInLocation != null ? LocationData(
//           latitude: checkInLocation!.latitude,
//           longitude: checkInLocation!.longitude,
//           address: checkInAddress,
//         ) : null,
//         checkOutLocation: checkOutLocation != null ? LocationData(
//           latitude: checkOutLocation!.latitude,
//           longitude: checkOutLocation!.longitude,
//           address: checkOutAddress,
//         ) : null,
//       );
//
//       setState(() {
//         attendanceHistory.insert(0, record);
//         hasCheckedInToday = true;
//         hasCheckedOutToday = checkOutTime != null;
//       });
//
//       // Save to SharedPreferences for persistence
//       await _saveAttendanceStatus();
//     }
//   }
//
//   // Save attendance status to SharedPreferences
//   Future<void> _saveAttendanceStatus() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     final today = DateTime.now();
//     final dateKey = "${today.year}-${today.month}-${today.day}";
//
//     await sp.setBool('checked_in_$dateKey', hasCheckedInToday);
//     await sp.setBool('checked_out_$dateKey', hasCheckedOutToday);
//
//     if (checkInTime != null) {
//       await sp.setString('check_in_time_$dateKey', checkInTime!.toIso8601String());
//     }
//     if (checkOutTime != null) {
//       await sp.setString('check_out_time_$dateKey', checkOutTime!.toIso8601String());
//     }
//   }
//
//   // Load attendance status from SharedPreferences
//   Future<void> _loadAttendanceStatus() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     final today = DateTime.now();
//     final dateKey = "${today.year}-${today.month}-${today.day}";
//
//     setState(() {
//       hasCheckedInToday = sp.getBool('checked_in_$dateKey') ?? false;
//       hasCheckedOutToday = sp.getBool('checked_out_$dateKey') ?? false;
//
//       if (hasCheckedInToday) {
//         final checkInStr = sp.getString('check_in_time_$dateKey');
//         if (checkInStr != null) {
//           checkInTime = DateTime.parse(checkInStr);
//         }
//       }
//
//       if (hasCheckedOutToday) {
//         final checkOutStr = sp.getString('check_out_time_$dateKey');
//         if (checkOutStr != null) {
//           checkOutTime = DateTime.parse(checkOutStr);
//         }
//       }
//     });
//   }
//
//   // ---------- LOCATION + GEOFENCE WITH MAP ----------
//   Future<void> _refreshLocationAndOfficeStatus() async {
//     final ok = await _ensureLocationPermission();
//     if (!ok) return;
//
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       final dist = Geolocator.distanceBetween(
//         pos.latitude,
//         pos.longitude,
//         controller.officeLat,
//         controller.officeLng,
//       );
//
//       setState(() {
//         distanceFromOfficeMeters = dist;
//         isInsideOffice = dist <= allowedRadiusMeters;
//         controller.currentLocation = LatLng(pos.latitude, pos.longitude);
//       });
//
//       _updateMapMarkers();
//     } catch (e) {
//       setState(() {
//         isInsideOffice = false;
//       });
//     }
//   }
//
//   void _updateMapMarkers() {
//     if (!_mapInitialized) return;
//
//     setState(() {
//       _markers = {
//         // Office marker
//         Marker(
//           markerId: const MarkerId('office'),
//           position: LatLng(controller.officeLat, controller.officeLng),
//           infoWindow: const InfoWindow(title: 'Office Location'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ),
//
//         // Current location marker (if available)
//         if (controller.currentLocation != null)
//           Marker(
//             markerId: const MarkerId('current'),
//             position: controller.currentLocation!,
//             infoWindow: InfoWindow(
//               title: 'Your Location',
//               snippet: 'Distance: ${distanceFromOfficeMeters?.toStringAsFixed(1)}m',
//             ),
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//           ),
//       };
//
//       _circles = {
//         // Geofence circle around office
//         Circle(
//           circleId: const CircleId('geofence'),
//           center: LatLng(controller.officeLat, controller.officeLng),
//           radius: allowedRadiusMeters,
//           fillColor: Colors.blue.withOpacity(0.2),
//           strokeColor: Colors.blue,
//           strokeWidth: 2,
//         ),
//       };
//     });
//
//     // Animate camera to show both office and current location
//     if (_mapController != null && controller.currentLocation != null) {
//       _animateCameraToShowBoth();
//     }
//   }
//
//   void _animateCameraToShowBoth() {
//     if (_mapController == null || controller.currentLocation == null) return;
//
//     // Calculate bounds to show both points
//     final bounds = LatLngBounds(
//       southwest: LatLng(
//         min(controller.officeLat, controller.currentLocation!.latitude),
//         min(controller.officeLng, controller.currentLocation!.longitude),
//       ),
//       northeast: LatLng(
//         max(controller.officeLat, controller.currentLocation!.latitude),
//         max(controller.officeLng, controller.currentLocation!.longitude),
//       ),
//     );
//
//     _mapController!.animateCamera(
//       CameraUpdate.newLatLngBounds(bounds, 100),
//     );
//   }
//
//   Future<bool> _ensureLocationPermission() async {
//     final status = await Permission.locationWhenInUse.request();
//     if (!status.isGranted) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Location permission is required.")),
//         );
//       }
//       return false;
//     }
//
//     final enabled = await Geolocator.isLocationServiceEnabled();
//     if (!enabled) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please enable GPS/Location services.")),
//         );
//       }
//       return false;
//     }
//     return true;
//   }
//
//   // ---------- FACE RECOGNITION (STUB) ----------
//   Future<bool> _verifyFace() async {
//     await Future.delayed(const Duration(milliseconds: 600));
//     return true;
//   }
//
//   // ---------- CHECK IN / OUT ----------
//   bool get canCheckIn {
//     // Can check in only if:
//     // 1. No check-in time recorded yet
//     // 2. Has not checked in today according to history
//     // 3. API status doesn't show already checked in
//     return checkInTime == null &&
//         !hasCheckedInToday &&
//         controller.status.value.isEmpty;
//   }
//
//   bool get canCheckOut {
//     // Can check out only if:
//     // 1. Has checked in but not checked out yet
//     // 2. Has not checked out today according to history
//     return checkInTime != null &&
//         checkOutTime == null &&
//         !hasCheckedOutToday;
//   }
//
//   Future<void> _handleCheckIn() async {
//     // Double check if already checked in today
//     if (hasCheckedInToday) {
//       _showAlreadyCheckedInDialog();
//       return;
//     }
//
//     if (checkInTime != null) {
//       _toast("You have already checked in today!");
//       return;
//     }
//
//     controller.attendenceType.value = "check-in";
//     await _refreshLocationAndOfficeStatus();
//
//     if (!isInsideOffice) {
//       _showLocationErrorDialog();
//       return;
//     }
//
//     final verified = await _verifyFace();
//     if (!verified) {
//       _toast("Face verification failed. Try again.");
//       return;
//     }
//
//     // Save check-in location
//     if (controller.currentLocation != null) {
//       final address = await _getAddressFromLatLng(
//         controller.currentLocation!.latitude,
//         controller.currentLocation!.longitude,
//       );
//
//       setState(() {
//         checkInLocation = LocationData(
//           latitude: controller.currentLocation!.latitude,
//           longitude: controller.currentLocation!.longitude,
//           address: address,
//         );
//       });
//     }
//
//     controller.attandance();
//
//     setState(() {
//       faceVerified = true;
//       checkInTime = DateTime.now();
//       hasCheckedInToday = true;
//     });
//
//     await _saveAttendanceStatus();
//     _computeStatus();
//     _toast("Checked in at ${fmt.format(checkInTime!)}");
//   }
//
//   Future<void> _handleCheckOut() async {
//     // Double check if already checked out today
//     if (hasCheckedOutToday) {
//       _showAlreadyCheckedOutDialog();
//       return;
//     }
//
//     if (checkOutTime != null) {
//       _toast("You have already checked out today!");
//       return;
//     }
//
//     if (checkInTime == null) {
//       _toast("Please check in first before checking out!");
//       return;
//     }
//
//     controller.attendenceType.value = "check-out";
//     await _refreshLocationAndOfficeStatus();
//
//     if (!isInsideOffice) {
//       _showLocationErrorDialog();
//       return;
//     }
//
//     final verified = await _verifyFace();
//     if (!verified) {
//       _toast("Face verification failed. Try again.");
//       return;
//     }
//
//     // Save check-out location
//     if (controller.currentLocation != null) {
//       final address = await _getAddressFromLatLng(
//         controller.currentLocation!.latitude,
//         controller.currentLocation!.longitude,
//       );
//
//       setState(() {
//         checkOutLocation = LocationData(
//           latitude: controller.currentLocation!.latitude,
//           longitude: controller.currentLocation!.longitude,
//           address: address,
//         );
//       });
//     }
//
//     controller.attandance();
//
//     setState(() {
//       faceVerified = true;
//       checkOutTime = DateTime.now();
//       hasCheckedOutToday = true;
//     });
//
//     // Add to history after checkout
//     _addToHistory();
//     await _saveAttendanceStatus();
//     _toast("Checked out at ${fmt.format(checkOutTime!)}");
//   }
//
//   void _showAlreadyCheckedInDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Already Checked In'),
//         content: const Text(
//           'You have already checked in for today. '
//               'You cannot check in multiple times on the same day.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAlreadyCheckedOutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Already Checked Out'),
//         content: const Text(
//           'You have already checked out for today. '
//               'Your attendance for today is complete.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showLocationErrorDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Outside Office Location'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('You are outside the allowed geofence area.'),
//             const SizedBox(height: 8),
//             Text(
//               'Distance from office: ${distanceFromOfficeMeters?.toStringAsFixed(1)}m\n'
//                   'Allowed radius: ${allowedRadiusMeters.toStringAsFixed(0)}m',
//             ),
//             const SizedBox(height: 8),
//             const Text('Please move inside the office premises to mark attendance.'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _toast(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   // ---------- MAP VIEW ----------
//   Widget _buildMapView() {
//     return Container(
//       height: 300,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Obx(() {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Stack(
//             children: [
//               if(controller.isLoading.value)
//                 Center(child: LoadingAnimationWidget.hexagonDots(
//                   color: primary_color,
//                   size: 50,
//                 )),
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(controller.officeLat, controller.officeLng),
//                   zoom: 16,
//                 ),
//                 markers: _markers,
//                 circles: _circles,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 zoomControlsEnabled: true,
//                 compassEnabled: true,
//                 onMapCreated: (controller) {
//                   _mapController = controller;
//                   _mapInitialized = true;
//                   _updateMapMarkers();
//                 },
//               ),
//               // Distance overlay
//               Positioned(
//                 top: 16,
//                 right: 16,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         isInsideOffice ? Icons.check_circle : Icons.warning,
//                         color: isInsideOffice ? Colors.green : Colors.orange,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         distanceFromOfficeMeters == null
//                             ? 'Unknown'
//                             : '${distanceFromOfficeMeters!.toStringAsFixed(0)}m',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: isInsideOffice ? Colors.green : Colors.orange,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   // Helper method for building status rule rows
//   Widget _buildStatusRuleRow({
//     required AttendanceStatus status,
//     required String rule,
//     required String example,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: Colors.grey.shade200),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Status column
//           Expanded(
//             flex: 2,
//             child: Row(
//               children: [
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: statusColor(status),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     statusLabel(status),
//                     style: TextStyle(
//                       color: statusColor(status),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Rule column
//           Expanded(
//             flex: 3,
//             child: Text(
//               rule,
//               style: const TextStyle(fontSize: 12),
//             ),
//           ),
//           // Example column
//           Expanded(
//             flex: 2,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//               decoration: BoxDecoration(
//                 color: statusColor(status).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 example,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: statusColor(status),
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------- UI ----------
//   @override
//   Widget build(BuildContext context) {
//     final start = _shiftStartToday(selectedShift);
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         backgroundColor: primary_color,
//         foregroundColor: Colors.white,
//         title: const Text("Attendance"),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.to(()=> History());
//             },
//             child: Text(
//               "History",
//               style: TextStyle(color: button_color, fontSize: 16),
//             ),
//           )
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await _refreshLocationAndOfficeStatus();
//           _computeStatus();
//           await _loadAttendanceStatus();
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 12),
//
//                 // Status banner for today's attendance
//                 if (hasCheckedOutToday)
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     margin: const EdgeInsets.only(bottom: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.green),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.check_circle, color: Colors.green),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Attendance Complete",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                               Text(
//                                 "You have already completed your attendance for today.",
//                                 style: TextStyle(color: Colors.green.shade700),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 else if (hasCheckedInToday && !hasCheckedOutToday)
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     margin: const EdgeInsets.only(bottom: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.orange),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.access_time, color: Colors.orange),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Checked In",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orange,
//                                 ),
//                               ),
//                               Text(
//                                 "You have checked in but not checked out yet.",
//                                 style: TextStyle(color: Colors.orange.shade700),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 Text(
//                   "Shift start: ${DateFormat('hh:mm a').format(start)}",
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Google Maps Card
//                 _card(
//                   title: "Restricted Punch (Office GPS)",
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildMapView(),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Icon(
//                             isInsideOffice ? Icons.verified : Icons.location_off,
//                             color: isInsideOffice ? Colors.green : Colors.red,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               isInsideOffice
//                                   ? "You are inside office radius."
//                                   : "You are outside office radius.",
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Distance: ${distanceFromOfficeMeters == null ? "-" : distanceFromOfficeMeters!.toStringAsFixed(1)} m (Allowed: ${allowedRadiusMeters.toStringAsFixed(0)} m)",
//                       ),
//                       const SizedBox(height: 8),
//                       OutlinedButton.icon(
//                         onPressed: _refreshLocationAndOfficeStatus,
//                         icon: const Icon(Icons.refresh),
//                         label: const Text("Re-check location"),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 _card(
//                   title: "Check-in / Check-out",
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Tooltip(
//                               message: hasCheckedInToday
//                                   ? "You have already checked in today"
//                                   : (canCheckIn ? "Check in for today" : "Check in not available"),
//                               child: ElevatedButton.icon(
//                                 onPressed: canCheckIn && !hasCheckedInToday ? _handleCheckIn : null,
//                                 icon: const Icon(Icons.login),
//                                 label: const Text("Check-in"),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: hasCheckedInToday ? Colors.grey : Colors.green,
//                                   foregroundColor: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Tooltip(
//                               message: hasCheckedOutToday
//                                   ? "You have already checked out today"
//                                   : (canCheckOut ? "Check out after check-in" : "Check out not available"),
//                               child: ElevatedButton.icon(
//                                 onPressed: canCheckOut && !hasCheckedOutToday ? _handleCheckOut : null,
//                                 icon: const Icon(Icons.logout),
//                                 label: const Text("Check-out"),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: hasCheckedOutToday ? Colors.grey : Colors.red,
//                                   foregroundColor: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Obx(() {
//                         if (controller.attendenceType.value == "check-in") {
//                           return _kv("Check-in time", controller.time.value);
//                         } else if (controller.attendenceType.value == "check-out") {
//                           return _kv("Check-out time", controller.time.value);
//                         } else if (checkInTime != null) {
//                           return Column(
//                             children: [
//                               _kv("Check-in time", fmt.format(checkInTime!)),
//                               if (checkOutTime != null)
//                                 _kv("Check-out time", fmt.format(checkOutTime!)),
//                             ],
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       }),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // Updated Status Card with API Data
//                 _card(
//                   title: "Attendance Status",
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Current status indicator with API data
//                       Container(
//                         margin: const EdgeInsets.only(bottom: 16),
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: status == null
//                               ? Colors.grey.shade100
//                               : statusColor(status!).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: status == null
//                                 ? Colors.grey.shade300
//                                 : statusColor(status!),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             // Status Icon from API
//                             Icon(
//                               status == null ? Icons.help_outline : statusIcon(status!),
//                               color: status == null ? Colors.grey : statusColor(status!),
//                               size: 32,
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Current Status",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey.shade600,
//                                     ),
//                                   ),
//                                   Obx(() {
//                                     String statusText = controller.status.value;
//                                     if (statusText.isEmpty) {
//                                       statusText = status == null ? "Not Marked" : statusLabel(status!);
//                                     }
//                                     return Row(
//                                       children: [
//                                         Text(
//                                           statusText,
//                                           style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold,
//                                             color: status == null
//                                                 ? Colors.black87
//                                                 : statusColor(status!),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         if (controller.status.value.isNotEmpty)
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 6, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: statusColor(status!).withOpacity(0.2),
//                                               borderRadius: BorderRadius.circular(12),
//                                             ),
//                                             child: Obx(() {
//                                               return Text(
//                                                 controller.time.value,
//                                                 style: TextStyle(
//                                                   fontSize: 11,
//                                                   color: statusColor(status!),
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               );
//                                             }),
//                                           ),
//                                       ],
//                                     );
//                                   }),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Status Rules Section
//                       const SizedBox(height: 8),
//                       const Text(
//                         "Status Rules",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//
//                       // Rules Table
//                       Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           children: [
//                             // Table Header
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(8),
//                                   topRight: Radius.circular(8),
//                                 ),
//                               ),
//                               child: const Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 2,
//                                     child: Text(
//                                       "Status",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 3,
//                                     child: Text(
//                                       "Check-in Time Rule",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 2,
//                                     child: Text(
//                                       "Example",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 13,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // Table Rows
//                             _buildStatusRuleRow(
//                               status: AttendanceStatus.present,
//                               rule: "Within 10 minutes of shift start",
//                               example: "9:00 AM - 9:10 AM",
//                             ),
//                             _buildStatusRuleRow(
//                               status: AttendanceStatus.late,
//                               rule: "10 - 60 minutes late",
//                               example: "9:11 AM - 10:00 AM",
//                             ),
//                             _buildStatusRuleRow(
//                               status: AttendanceStatus.halfDay,
//                               rule: "1 - 4 hours late",
//                               example: "10:01 AM - 1:00 PM",
//                             ),
//                             _buildStatusRuleRow(
//                               status: AttendanceStatus.absent,
//                               rule: "More than 4 hours late or no check-in",
//                               example: "After 1:00 PM",
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       // Shift Start Time Info
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.blue.withOpacity(0.2)),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               size: 18,
//                               color: Colors.blue.shade700,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 "Your shift starts at ${DateFormat('hh:mm a').format(_shiftStartToday(selectedShift))}",
//                                 style: TextStyle(
//                                   color: Colors.blue.shade700,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _card({required String title, required Widget child}) {
//     return Card(
//       elevation: 5,
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _kv(String k, String v) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Expanded(child: Text(k, style: const TextStyle(color: Colors.black54))),
//           Expanded(
//             flex: 2,
//             child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'dart:math';
import 'package:employee_app/Model/rulesModel.dart';
import 'package:employee_app/utils/colers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Controller/Attendance_controller.dart';
import 'history.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

enum ShiftType { day, night, rotational }
enum AttendanceStatus { present, late, halfDay, absent }
enum DateFilterType { today, thisWeek, thisMonth, custom }

// Location model for attendance records
class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

// Model class for attendance records
class AttendanceRecord {
  final DateTime date;
  final ShiftType shift;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final double? distance;
  final bool faceVerified;
  final LocationData? checkInLocation;
  final LocationData? checkOutLocation;

  AttendanceRecord({
    required this.date,
    required this.shift,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.distance,
    required this.faceVerified,
    this.checkInLocation,
    this.checkOutLocation,
  });

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);

  String get formattedDay => DateFormat('EEEE').format(date);

  String get formattedCheckIn =>
      checkIn != null ? DateFormat('hh:mm a').format(checkIn!) : '-';

  String get formattedCheckOut =>
      checkOut != null ? DateFormat('hh:mm a').format(checkOut!) : '-';

  bool get hasCheckInLocation => checkInLocation != null;

  bool get hasCheckOutLocation => checkOutLocation != null;
}

class _AttendanceState extends State<Attendance> {

  // Inside your State class

  // final AttensanceController controller = Get.put(AttensanceController());

  final AttensanceController controller = Get.isRegistered<AttensanceController>()
      ? Get.find<AttensanceController>()
      : Get.put(AttensanceController());


  // Allowed radius (meters) for restricted punch (geofence)


  // --- Shift settings ---
  ShiftType selectedShift = ShiftType.day;

  // Stored state (you can replace with API/database)
  DateTime? checkInTime;
  DateTime? checkOutTime;
  LocationData? checkInLocation;
  LocationData? checkOutLocation;

  bool isInsideOffice = false;
  double? distanceFromOfficeMeters;
  bool faceVerified = false;

  AttendanceStatus? status;

  // Track if attendance is already completed for today
  bool hasCheckedInToday = false;
  bool hasCheckedOutToday = false;

  // Attendance history list
  List<AttendanceRecord> attendanceHistory = [];

  final DateFormat fmt = DateFormat('hh:mm a');

  // Google Maps related variables





  @override
  void initState() {
    super.initState();
    _refreshLocationAndOfficeStatus();
    _computeStatus();
    _checkTodayAttendanceStatus();
    _loadAttendanceStatus();

    // Add listener to update status when controller data changes
    ever(controller.status, (_) {
      setState(() {
        _updateStatusFromAPI();
        _checkTodayAttendanceStatus();
      });
    });

    ever(controller.time, (_) {
      setState(() {
        _updateStatusFromAPI();
      });
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh map when coming back to this page
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && controller.mapInitialized.value) {
        controller.refreshMap();
      }
    });
  }

  @override
  void dispose() {
    // controller.mapController?.dispose();
    // controller.dispose();
    controller.resetMapState();

    super.dispose();
  }



  // Check if user has already checked in/out today
  void _checkTodayAttendanceStatus() {
    final today = DateTime.now();

    // Check if there's any attendance record for today in history
    final todayRecord = attendanceHistory.firstWhere(
          (record) => record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day,
      orElse: () => AttendanceRecord(
        date: today,
        shift: selectedShift,
        status: AttendanceStatus.absent,
        faceVerified: false,
      ),
    );

    setState(() {
      hasCheckedInToday = todayRecord.checkIn != null;
      hasCheckedOutToday = todayRecord.checkOut != null;
    });
  }

  // Update status based on API data
  void _updateStatusFromAPI() {
    String statusValue = controller.status.value.toLowerCase();

    if (statusValue.contains('present')) {
      status = AttendanceStatus.present;
    } else if (statusValue.contains('late')) {
      status = AttendanceStatus.late;
    } else if (statusValue.contains('half')) {
      status = AttendanceStatus.halfDay;
    } else if (statusValue.contains('absent')) {
      status = AttendanceStatus.absent;
    } else {
      // If no check-in, keep as absent
      if (checkInTime == null) {
        status = AttendanceStatus.absent;
      }
    }

    setState(() {

    });
  }

  // Get address from coordinates (mock function - replace with actual geocoding)
  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    // In a real app, use Geocoding package to get actual address
    await Future.delayed(const Duration(milliseconds: 100));
    return "Location: $latitude, $longitude";
  }

  // ---------- UI HELPERS ----------
  String shiftLabel(ShiftType s) {
    switch (s) {
      case ShiftType.day:
        return "Day";
      case ShiftType.night:
        return "Night";
      case ShiftType.rotational:
        return "Rotational";
    }
  }

  String statusLabel(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return "Present";
      case AttendanceStatus.late:
        return "Late";
      case AttendanceStatus.halfDay:
        return "Half-day";
      case AttendanceStatus.absent:
        return "Absent";
    }
  }

  Color statusColorforrules(String s) {

       if(s == 'Present'){
         return Colors.green;
       }else if(s == 'Late'){
         return Colors.orange;
       }else if(s == 'Half-day'){
         return Colors.deepOrange;
       }else if(s == 'Absent'){
         return Colors.red;
       }
       else {
         return Colors.black;
       }
  }

  Color statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.halfDay:
        return Colors.deepOrange;
      case AttendanceStatus.absent:
        return Colors.red;

    }
  }

  IconData statusIcon(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.halfDay:
        return Icons.warning_amber_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel;
    }
  }

  // ---------- SHIFT RULES ----------
  DateTime _shiftStartToday(ShiftType shift) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (shift) {
      case ShiftType.day:
        return today.add(const Duration(hours: 9, minutes: 0)); // 9:00 AM
      case ShiftType.night:
        return today.add(const Duration(hours: 21, minutes: 0)); // 9:00 PM
      case ShiftType.rotational:
        final isEvenDay = today.day % 2 == 0;
        return isEvenDay
            ? today.add(const Duration(hours: 9))
            : today.add(const Duration(hours: 21));
    }
  }

  AttendanceStatus _statusFromCheckIn(DateTime? inTime, ShiftType shift) {
    if (inTime == null) return AttendanceStatus.absent;

    final start = _shiftStartToday(shift);
    final diffMinutes = inTime.difference(start).inMinutes;

    if (diffMinutes <= 10) return AttendanceStatus.present;
    if (diffMinutes <= 60) return AttendanceStatus.late;
    if (diffMinutes <= 240) return AttendanceStatus.halfDay;
    return AttendanceStatus.absent;
  }

  void _computeStatus() {
    setState(() {
      if (controller.status.value.isNotEmpty) {
        _updateStatusFromAPI();
      } else {
        status = _statusFromCheckIn(checkInTime, selectedShift);
      }
    });
  }

  // Add current attendance to history after checkout
  void _addToHistory() async {
    if (checkInTime != null) {
      // Get address for check-in location
      String checkInAddress = "Unknown location";
      if (checkInLocation != null) {
        checkInAddress = await _getAddressFromLatLng(
          checkInLocation!.latitude,
          checkInLocation!.longitude,
        );
      }

      // Get address for check-out location
      String checkOutAddress = "Unknown location";
      if (checkOutLocation != null) {
        checkOutAddress = await _getAddressFromLatLng(
          checkOutLocation!.latitude,
          checkOutLocation!.longitude,
        );
      }

      final record = AttendanceRecord(
        date: DateTime.now(),
        shift: selectedShift,
        checkIn: checkInTime,
        checkOut: checkOutTime,
        status: status ?? AttendanceStatus.absent,
        distance: distanceFromOfficeMeters,
        faceVerified: faceVerified,
        checkInLocation: checkInLocation != null ? LocationData(
          latitude: checkInLocation!.latitude,
          longitude: checkInLocation!.longitude,
          address: checkInAddress,
        ) : null,
        checkOutLocation: checkOutLocation != null ? LocationData(
          latitude: checkOutLocation!.latitude,
          longitude: checkOutLocation!.longitude,
          address: checkOutAddress,
        ) : null,
      );

      setState(() {
        attendanceHistory.insert(0, record);
        hasCheckedInToday = true;
        hasCheckedOutToday = checkOutTime != null;
      });

      // Save to SharedPreferences for persistence
      await _saveAttendanceStatus();
    }
  }

  // Save attendance status to SharedPreferences
  Future<void> _saveAttendanceStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";

    await sp.setBool('checked_in_$dateKey', hasCheckedInToday);
    await sp.setBool('checked_out_$dateKey', hasCheckedOutToday);

    if (checkInTime != null) {
      await sp.setString('check_in_time_$dateKey', checkInTime!.toIso8601String());
    }
    if (checkOutTime != null) {
      await sp.setString('check_out_time_$dateKey', checkOutTime!.toIso8601String());
    }
  }

  // Load attendance status from SharedPreferences
  Future<void> _loadAttendanceStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";

    setState(() {
      hasCheckedInToday = sp.getBool('checked_in_$dateKey') ?? false;
      hasCheckedOutToday = sp.getBool('checked_out_$dateKey') ?? false;

      if (hasCheckedInToday) {
        final checkInStr = sp.getString('check_in_time_$dateKey');
        if (checkInStr != null) {
          checkInTime = DateTime.parse(checkInStr);
        }
      }

      if (hasCheckedOutToday) {
        final checkOutStr = sp.getString('check_out_time_$dateKey');
        if (checkOutStr != null) {
          checkOutTime = DateTime.parse(checkOutStr);
        }
      }
    });
  }

  // ---------- LOCATION + GEOFENCE WITH MAP ----------
  Future<void> _refreshLocationAndOfficeStatus() async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final dist = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        controller.officeLat,
        controller.officeLng,
      );

      setState(() {
        distanceFromOfficeMeters = dist;
        isInsideOffice = dist <= controller.companyDistance.value;
        controller.currentLocation = LatLng(pos.latitude, pos.longitude);
      });

      // Don't update markers here - only update status
    } catch (e) {
      setState(() {
        isInsideOffice = false;
      });
    }
  }



  void _animateCameraToShowBoth() {
    if (controller.mapController == null || controller.currentLocation == null) return;

    // Ensure office coordinates are valid
    if (controller.officeLat == 0.0 || controller.officeLng == 0.0) return;

    try {
      // Calculate bounds to show both points
      final bounds = LatLngBounds(
        southwest: LatLng(
          min(controller.officeLat, controller.currentLocation!.latitude),
          min(controller.officeLng, controller.currentLocation!.longitude),
        ),
        northeast: LatLng(
          max(controller.officeLat, controller.currentLocation!.latitude),
          max(controller.officeLng, controller.currentLocation!.longitude),
        ),
      );

      controller.mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } catch (e) {
      print("Error animating camera: $e");
      // Fallback: just center on office
      controller.mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(controller.officeLat, controller.officeLng)),
      );
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission is required.")),
        );
      }
      return false;
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enable GPS/Location services.")),
        );
      }
      return false;
    }
    return true;
  }

  // ---------- FACE RECOGNITION (STUB) ----------
  Future<bool> _verifyFace() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  // ---------- CHECK IN / OUT ----------
  bool get canCheckIn {
    // Can check in only if:
    // 1. No check-in time recorded yet
    // 2. Has not checked in today according to history
    // 3. API status doesn't show already checked in
    return checkInTime == null &&
        !hasCheckedInToday &&
        controller.status.value.isEmpty;
  }

  bool get canCheckOut {
    // Can check out only if:
    // 1. Has checked in but not checked out yet
    // 2. Has not checked out today according to history
    return checkInTime != null &&
        checkOutTime == null &&
        !hasCheckedOutToday;
  }

  Future<void> _handleCheckIn() async {
    // Double check if already checked in today
    if (hasCheckedInToday) {
      _showAlreadyCheckedInDialog();
      return;
    }

    if (checkInTime != null) {
      _toast("You have already checked in today!");
      return;
    }

    controller.attendenceType.value = "check-in";
    await _refreshLocationAndOfficeStatus();

    if (!isInsideOffice) {
      _showLocationErrorDialog();
      return;
    }

    final verified = await _verifyFace();
    if (!verified) {
      _toast("Face verification failed. Try again.");
      return;
    }

    // Save check-in location
    if (controller.currentLocation != null) {
      final address = await _getAddressFromLatLng(
        controller.currentLocation!.latitude,
        controller.currentLocation!.longitude,
      );

      setState(() {
        checkInLocation = LocationData(
          latitude: controller.currentLocation!.latitude,
          longitude: controller.currentLocation!.longitude,
          address: address,
        );
      });
    }

    controller.attandance();

    setState(() {
      faceVerified = true;
      checkInTime = DateTime.now();
      hasCheckedInToday = true;
    });

    await _saveAttendanceStatus();
    _computeStatus();
    _toast("Checked in at ${fmt.format(checkInTime!)}");
  }

  Future<void> _handleCheckOut() async {
    // Double check if already checked out today
    if (hasCheckedOutToday) {
      _showAlreadyCheckedOutDialog();
      return;
    }

    if (checkOutTime != null) {
      _toast("You have already checked out today!");
      return;
    }

    if (checkInTime == null) {
      _toast("Please check in first before checking out!");
      return;
    }

    controller.attendenceType.value = "check-out";
    await _refreshLocationAndOfficeStatus();

    if (!isInsideOffice) {
      _showLocationErrorDialog();
      return;
    }

    final verified = await _verifyFace();
    if (!verified) {
      _toast("Face verification failed. Try again.");
      return;
    }

    // Save check-out location
    if (controller.currentLocation != null) {
      final address = await _getAddressFromLatLng(
        controller.currentLocation!.latitude,
        controller.currentLocation!.longitude,
      );

      setState(() {
        checkOutLocation = LocationData(
          latitude: controller.currentLocation!.latitude,
          longitude: controller.currentLocation!.longitude,
          address: address,
        );
      });
    }

    controller.attandance();

    setState(() {
      faceVerified = true;
      checkOutTime = DateTime.now();
      hasCheckedOutToday = true;
    });

    // Add to history after checkout
    _addToHistory();
    await _saveAttendanceStatus();
    _toast("Checked out at ${fmt.format(checkOutTime!)}");
  }

  void _showAlreadyCheckedInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already Checked In'),
        content: const Text(
          'You have already checked in for today. '
              'You cannot check in multiple times on the same day.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAlreadyCheckedOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already Checked Out'),
        content: const Text(
          'You have already checked out for today. '
              'Your attendance for today is complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Outside Office Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are outside the allowed geofence area.'),
            const SizedBox(height: 8),
            Text(
              'Distance from office: ${distanceFromOfficeMeters?.toStringAsFixed(1)}m\n'
                  'Allowed radius: ${controller.companyDistance.value.toStringAsFixed(0)}m',
            ),
            const SizedBox(height: 8),
            const Text('Please move inside the office premises to mark attendance.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------- MAP VIEW ----------
  Widget _buildMapView() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Obx(() {
        // Don't try to show map if office location isn't loaded yet
        if (controller.isLoading.value || controller.officeLat == 0.0) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: primary_color,
              size: 50,
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // ADD THE ACTUAL GOOGLE MAP WIDGET
              GoogleMap(
                 initialCameraPosition: CameraPosition(
                  target: LatLng(controller.officeLat, controller.officeLng),
                  zoom: 16,
                ),
                markers: controller.markers.toSet(),  // Use markers from controller
                circles: controller.circles.toSet(),   // Use circles from controller
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                compassEnabled: true,
                onMapCreated: (GoogleMapController mapController) {
                  controller.mapController = mapController;
                  controller.mapInitialized.value = true;
                  Future.delayed(const Duration(milliseconds: 700), () {
                    controller.updateMapMarkers();
                  }); // Call after map is created
                },
              ),
              // Distance overlay
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isInsideOffice ? Icons.check_circle : Icons.warning,
                        color: isInsideOffice ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        distanceFromOfficeMeters == null
                            ? 'Unknown'
                            : '${distanceFromOfficeMeters!.toStringAsFixed(0)}m',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isInsideOffice ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Helper method for building status rule rows
  Widget _buildStatusRuleRow({
    required String status,
    required String rule,
    required String example,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Status column
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColorforrules(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColorforrules(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rule column
          Expanded(
            flex: 3,
            child: Text(
              rule,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          // Example column
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: statusColorforrules(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                example,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColorforrules(status),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final start = _shiftStartToday(selectedShift);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("Attendance"),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(()=> History());
            },
            child: Text(
              "History",
              style: TextStyle(color: button_color, fontSize: 16),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // controller.fetchcompanylocation();
          // controller.getcompanyDistance();
          await _refreshLocationAndOfficeStatus();
          _computeStatus();
          await _loadAttendanceStatus();
          controller.getattendanceRules();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Status banner for today's attendance
                // if (hasCheckedOutToday)
                //   Container(
                //     padding: const EdgeInsets.all(12),
                //     margin: const EdgeInsets.only(bottom: 12),
                //     decoration: BoxDecoration(
                //       color: Colors.green.withOpacity(0.1),
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(color: Colors.green),
                //     ),
                //     child: Row(
                //       children: [
                //         Icon(Icons.check_circle, color: Colors.green),
                //         const SizedBox(width: 12),
                //         Expanded(
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               const Text(
                //                 "Attendance Complete",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.bold,
                //                   color: Colors.green,
                //                 ),
                //               ),
                //               Text(
                //                 "You have already completed your attendance for today.",
                //                 style: TextStyle(color: Colors.green.shade700),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   )
                // else if (hasCheckedInToday && !hasCheckedOutToday)
                //   Container(
                //     padding: const EdgeInsets.all(12),
                //     margin: const EdgeInsets.only(bottom: 12),
                //     decoration: BoxDecoration(
                //       color: Colors.orange.withOpacity(0.1),
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(color: Colors.orange),
                //     ),
                //     child: Row(
                //       children: [
                //         Icon(Icons.access_time, color: Colors.orange),
                //         const SizedBox(width: 12),
                //         Expanded(
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               const Text(
                //                 "Checked In",
                //                 style: TextStyle(
                //                   fontWeight: FontWeight.bold,
                //                   color: Colors.orange,
                //                 ),
                //               ),
                //               Text(
                //                 "You have checked in but not checked out yet.",
                //                 style: TextStyle(color: Colors.orange.shade700),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),

                Text(
                  "Shift start: ${DateFormat('hh:mm a').format(start)}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),

                // Google Maps Card
                _card(
                  title: "Restricted Punch (Office GPS)",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMapView(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            isInsideOffice ? Icons.verified : Icons.location_off,
                            color: isInsideOffice ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isInsideOffice
                                  ? "You are inside office radius."
                                  : "You are outside office radius.",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Distance: ${distanceFromOfficeMeters == null ? "-" : distanceFromOfficeMeters!.toStringAsFixed(1)} m (Allowed: ${controller.companyDistance.value.toStringAsFixed(0)} m)",
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _refreshLocationAndOfficeStatus,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Re-check location"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _card(
                  title: "Check-in / Check-out",
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Tooltip(
                              message: hasCheckedInToday
                                  ? "You have already checked in today"
                                  : (canCheckIn ? "Check in for today" : "Check in not available"),
                              child: ElevatedButton.icon(
                                onPressed: canCheckIn && !hasCheckedInToday ? _handleCheckIn : null,
                                icon: const Icon(Icons.login),
                                label: const Text("Check-in"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasCheckedInToday ? Colors.grey : Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Tooltip(
                              message: hasCheckedOutToday
                                  ? "You have already checked out today"
                                  : (canCheckOut ? "Check out after check-in" : "Check out not available"),
                              child: ElevatedButton.icon(
                                onPressed: canCheckOut && !hasCheckedOutToday ? _handleCheckOut : null,
                                icon: const Icon(Icons.logout),
                                label: const Text("Check-out"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasCheckedOutToday ? Colors.grey : Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (controller.attendenceType.value == "check-in") {
                          return _kv("Check-in time", controller.time.value);
                        } else if (controller.attendenceType.value == "check-out") {
                          return _kv("Check-out time", controller.time.value);
                        } else if (checkInTime != null) {
                          return Column(
                            children: [
                              _kv("Check-in time", fmt.format(checkInTime!)),
                              if (checkOutTime != null)
                                _kv("Check-out time", fmt.format(checkOutTime!)),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Updated Status Card with API Data
                _card(
                  title: "Attendance Status",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current status indicator with API data
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: status == null
                              ? Colors.grey.shade100
                              : statusColor(status!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: status == null
                                ? Colors.grey.shade300
                                : statusColor(status!),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Status Icon from API
                            Icon(
                              status == null ? Icons.help_outline : statusIcon(status!),
                              color: status == null ? Colors.grey : statusColor(status!),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Current Status",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Obx(() {
                                    String statusText = controller.status.value;
                                    if (statusText.isEmpty) {
                                      statusText = status == null ? "Not Marked" : statusLabel(status!);
                                    }
                                    return Row(
                                      children: [
                                        Text(
                                          statusText,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: status == null
                                                ? Colors.black87
                                                : statusColor(status!),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (controller.status.value.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusColor(status!).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Obx(() {
                                              return Text(
                                                controller.time.value,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: statusColor(status!),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              );
                                            }),
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Rules Section
                      const SizedBox(height: 8),
                      const Text(
                        "Status Rules",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rules Table
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Status",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      "Check-in Time Rule",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Example",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Table Rows
                            // _buildStatusRuleRow(
                            //   status: AttendanceStatus.present,
                            //   rule: "Within 10 minutes of shift start",
                            //   example: "0 minute - 10 minute",
                            // ),
                            // _buildStatusRuleRow(
                            //   status: AttendanceStatus.late,
                            //   rule: "10 - 60 minutes late",
                            //   example: "11 minute - 60 minute",
                            // ),
                            // _buildStatusRuleRow(
                            //   status: AttendanceStatus.halfDay,
                            //   rule: "1 - 4 hours late",
                            //   example: "61 minute - 240 minute",
                            // ),
                            // _buildStatusRuleRow(
                            //   status: AttendanceStatus.absent,
                            //   rule: "More than 4 hours late or no check-in",
                            //   example: "After 241 minute",
                            // ),

                            // Obx(
                            //   ()=> Expanded(
                            //     child: ListView.builder(
                            //       itemCount: controller.rulesList.length,
                            //       itemBuilder: (context, index) {
                            //         Rulesmodel rule = controller.rulesList.value[index];
                            //         return _buildStatusRuleRow(
                            //           status: rule.rule_name,
                            //           rule: rule.description,
                            //           example: "${rule.min_minutes} minute - ${rule.max_minutes} minute",
                            //         );
                            //
                            //     },),
                            //   ),
                            // ),
                            Obx(
                                  () => Column(
                                children: controller.rulesList.map((rule) {
                                  return _buildStatusRuleRow(
                                    status: rule.rule_name,
                                    rule: rule.description,
                                    example: "${rule.min_minutes} minute - ${rule.max_minutes} minute",
                                  );
                                }).toList(),
                              ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Shift Start Time Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Your shift starts at ${DateFormat('hh:mm a').format(_shiftStartToday(selectedShift))}",
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Card(
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(
            flex: 2,
            child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}