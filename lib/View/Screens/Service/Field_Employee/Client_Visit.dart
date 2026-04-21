import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Controller/Schedule_visit_controller.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class ClientVisit extends StatefulWidget {
  const ClientVisit({super.key});

  @override
  State<ClientVisit> createState() => _ClientVisitState();
}

class _ClientVisitState extends State<ClientVisit>
    with SingleTickerProviderStateMixin {
  SchedulevisitController controller = SchedulevisitController();

  late TabController _tabController;
  int _selectedTabIndex = 0;



  // Complete work controllers
  final _workTitleController = TextEditingController();
  final _workCategoryController = TextEditingController();
  final _completeWorkNotesController = TextEditingController();
  DateTime? _workCompleteDateTime;
  LatLng? _workCompleteLocation;
  List<Map<String, dynamic>> _workPhotos = [];
  bool _isWorkPhotoUploading = false;

  // Filter variables - using chips
  String _selectedDateFilter = 'All';
  String _selectedStatusFilter = 'All';

  // Filter options
  final List<String> _dateFilters = ['All', 'Today', 'Tomorrow', 'Next Week'];
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Overdue',
    'Rescheduled'
  ];

  // Date and time
  DateTime? _visitDateTime;
  TimeOfDay? _visitTime;
  List<Map<String, dynamic>> _visitPhotos = [];
  bool _isUploading = false;

  // Map variables
  GoogleMapController? _mapController;
  GoogleMapController? _workMapController;
  Set<Marker> _markers = {};
  Set<Marker> _workMarkers = {};
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  LatLng? _workLocation;
  bool _isMapReady = false;
  bool _isLoadingLocation = false;
  bool _isWorkLocationLoading = false;
  String _locationStatus = '';
  final Set<Polyline> _polylines = {};

  // Search
  List<Placemark> _searchResults = [];
  bool _isSearching = false;

  // Work categories
  final List<String> _workCategories = [
    'Meeting',
    'Site Visit',
    'Installation',
    'Maintenance',
    'Training',
    'Consultation',
    'Inspection',
    'Delivery',
    'Other',
  ];

  // Sample visit data
  final List<Map<String, dynamic>> _upcomingVisits = [
    {
      'id': 'VIS001',
      'clientName': 'ABC Corporation',
      'purpose': 'Product Demo',
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': '10:30 AM',
      'contactPerson': 'Mr. Sharma',
      'status': 'Scheduled',
      'statusColor': Colors.blue,
      'location': LatLng(19.0760, 72.8777),
      'address': 'Mumbai, Maharashtra',
    },
    {
      'id': 'VIS002',
      'clientName': 'XYZ Industries',
      'purpose': 'Contract Signing',
      'date': DateTime.now().add(const Duration(days: 3)),
      'time': '2:00 PM',
      'contactPerson': 'Ms. Patel',
      'status': 'Scheduled',
      'statusColor': Colors.blue,
      'location': LatLng(19.1136, 72.8697),
      'address': 'Andheri East, Mumbai',
    },
    {
      'id': 'VIS006',
      'clientName': 'Tech Mahindra',
      'purpose': 'Technical Review',
      'date': DateTime.now().add(const Duration(days: 5)),
      'time': '11:00 AM',
      'contactPerson': 'Mr. Patil',
      'status': 'Overdue',
      'statusColor': Colors.red,
      'location': LatLng(19.0760, 72.8777),
      'address': 'Pune, Maharashtra',
    },
    {
      'id': 'VIS007',
      'clientName': 'Infosys Ltd',
      'purpose': 'Project Kickoff',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'time': '3:00 PM',
      'contactPerson': 'Ms. Reddy',
      'status': 'Overdue',
      'statusColor': Colors.red,
      'location': LatLng(19.0760, 72.8777),
      'address': 'Bangalore, Karnataka',
    },
  ];

  final List<Map<String, dynamic>> _completedVisits = [
    {
      'id': 'VIS003',
      'clientName': 'Tech Solutions Ltd',
      'purpose': 'Site Visit',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'time': '11:15 AM',
      'contactPerson': 'Mr. Kumar',
      'status': 'Completed',
      'statusColor': Colors.green,
      'outcome': 'Positive - Follow up next week',
      'location': LatLng(19.0596, 72.8295),
      'address': 'Powai, Mumbai',
      'workTitle': 'Site Inspection',
      'workCategory': 'Site Visit',
      'workCompleteDateTime': DateTime.now().subtract(const Duration(days: 1)),
      'workLocation': LatLng(19.0596, 72.8295),
      'workPhotos': [],
      'workNotes': 'Completed site inspection successfully',
    },
    {
      'id': 'VIS004',
      'clientName': 'Global Enterprises',
      'purpose': 'Initial Meeting',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'time': '3:30 PM',
      'contactPerson': 'Ms. Singh',
      'status': 'Completed',
      'statusColor': Colors.green,
      'outcome': 'Interested in products',
      'location': LatLng(19.0178, 72.8478),
      'address': 'Navi Mumbai',
      'workTitle': 'Client Meeting',
      'workCategory': 'Meeting',
      'workCompleteDateTime': DateTime.now().subtract(const Duration(days: 3)),
      'workLocation': LatLng(19.0178, 72.8478),
      'workPhotos': [],
      'workNotes': 'Discussed product requirements',
    },
    {
      'id': 'VIS005',
      'clientName': 'Innovation Hub',
      'purpose': 'Demo',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'time': '10:00 AM',
      'contactPerson': 'Mr. Mehta',
      'status': 'Cancelled',
      'statusColor': Colors.red,
      'outcome': 'Rescheduled',
      'location': LatLng(18.9750, 72.8258),
      'address': 'CBD Belapur',
    },
    {
      'id': 'VIS008',
      'clientName': 'Wipro Technologies',
      'purpose': 'Training Session',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'time': '2:30 PM',
      'contactPerson': 'Mr. Singh',
      'status': 'Completed',
      'statusColor': Colors.green,
      'outcome': 'Training completed successfully',
      'location': LatLng(19.0760, 72.8777),
      'address': 'Mumbai, Maharashtra',
      'workTitle': 'Technical Training',
      'workCategory': 'Training',
      'workCompleteDateTime': DateTime.now().subtract(const Duration(days: 7)),
      'workLocation': LatLng(19.0760, 72.8777),
      'workPhotos': [],
      'workNotes': 'Trained 15 developers',
    },
  ];

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  // Get filtered upcoming visits based on selected filters
  List<Map<String, dynamic>> get _filteredUpcomingVisits {
    return _upcomingVisits.where((visit) {
      // Date filter
      bool dateMatch = true;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final visitDate = DateTime(
          visit['date'].year, visit['date'].month, visit['date'].day);

      switch (_selectedDateFilter) {
        case 'Today':
          dateMatch = visitDate.isAtSameMomentAs(today);
          break;
        case 'Tomorrow':
          final tomorrow = today.add(const Duration(days: 1));
          dateMatch = visitDate.isAtSameMomentAs(tomorrow);
          break;
        case 'Next Week':
          final nextWeek = today.add(const Duration(days: 7));
          dateMatch =
              visitDate.isAfter(today.subtract(const Duration(days: 1))) &&
                  visitDate.isBefore(nextWeek.add(const Duration(days: 1)));
          break;
        default:
          dateMatch = true;
      }

      // Status filter
      bool statusMatch = true;
      switch (_selectedStatusFilter) {
        case 'Pending':
          statusMatch = visit['status'] == 'Scheduled';
          break;
        case 'Overdue':
          statusMatch = visit['status'] == 'Overdue';
          break;
        case 'Rescheduled':
          statusMatch = visit['status'] == 'Rescheduled';
          break;
        default:
          statusMatch = true;
      }

      return dateMatch && statusMatch;
    }).toList();
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _visitDateTime = DateTime.now();
    _visitTime = TimeOfDay.now();
    controller.rescheduleDate.value = DateTime.now();
    controller.rescheduleTime.value = TimeOfDay.now();
    _workCompleteDateTime = DateTime.now();
    _checkLocationPermission();
    controller.SelectWorkcategory();
    getID();
  }

  getID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    controller.userId = await sp.getString("user_id") ?? "";
  }


  @override
  void dispose() {
    _tabController.dispose();
    controller.rescheduleNoteController.dispose();
    _workTitleController.dispose();
    _workCategoryController.dispose();
    _completeWorkNotesController.dispose();
    _mapController?.dispose();
    _workMapController?.dispose();
    super.dispose();
  }

  // Location permission check
  Future<bool> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else {
      _showSnackBar(
          'Location permission is required for map features', Colors.orange);
      return false;
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Getting current location...';
    });

    try {
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = _currentLocation;
        _isLoadingLocation = false;
        _locationStatus = 'Location found';
      });

      // Get address from coordinates
      await _getAddressFromLatLng(position.latitude, position.longitude);

      // Update map camera
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 15),
        );
      }

      // Add marker
      _addMarker(_currentLocation!, 'Current Location', 'Your current location',
          Colors.green);

      _showSnackBar('Current location updated', Colors.green);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationStatus = 'Error getting location';
      });
      _showSnackBar('Error getting location: $e', Colors.red);
    }
  }

  // Get work current location for complete work
  Future<void> _getWorkCurrentLocation() async {
    setState(() {
      _isWorkLocationLoading = true;
    });

    try {
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _workLocation = LatLng(position.latitude, position.longitude);
        _isWorkLocationLoading = false;
      });

      // Update map camera
      if (_workMapController != null) {
        _workMapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_workLocation!, 15),
        );
      }

      // Add marker
      _addWorkMarker(
          _workLocation!, 'Work Location', 'Work completion location',
          Colors.green);

      _showSnackBar('Work location updated', Colors.green);
    } catch (e) {
      setState(() {
        _isWorkLocationLoading = false;
      });
      _showSnackBar('Error getting location: $e', Colors.red);
    }
  }

  // Get address from coordinates
  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '${place.street}, ${place.locality}, ${place
            .administrativeArea}, ${place.country} - ${place.postalCode}';
        controller.clientAddressController.text = address;
      }
    } catch (e) {
      controller.clientAddressController.text =
      'Location: $latitude, $longitude';
    }
  }

  // Search location
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        locations.first.latitude,
        locations.first.longitude,
      );

      setState(() {
        _searchResults = placemarks;
        _isSearching = false;
      });

      if (locations.isNotEmpty) {
        LatLng searchLocation = LatLng(
            locations.first.latitude, locations.first.longitude);
        _selectedLocation = searchLocation;

        // Update map
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(searchLocation, 14),
          );
        }

        _addMarker(searchLocation, 'Searched Location', query, Colors.orange);
        await _getAddressFromLatLng(
            searchLocation.latitude, searchLocation.longitude);
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showSnackBar('Location not found', Colors.orange);
    }
  }

  // Add marker to map
  void _addMarker(LatLng position, String title, String snippet, Color color) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(
            title: title,
            snippet: snippet,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            color == Colors.green ? BitmapDescriptor.hueGreen :
            color == Colors.orange ? BitmapDescriptor.hueOrange :
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    });
  }

  // Add work marker to map
  void _addWorkMarker(LatLng position, String title, String snippet,
      Color color) {
    setState(() {
      _workMarkers.clear();
      _workMarkers.add(
        Marker(
          markerId: MarkerId('work_location'),
          position: position,
          infoWindow: InfoWindow(
            title: title,
            snippet: snippet,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            color == Colors.green ? BitmapDescriptor.hueGreen : BitmapDescriptor
                .hueBlue,
          ),
        ),
      );
    });
  }

  Future<DateTime?> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _visitDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;

    if (picked != null) {
      setState(() {
        _visitDateTime = picked;
      });
    }
  }

  Future<TimeOfDay?> selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _visitTime ?? TimeOfDay.now(),
    );
    return picked;

    if (picked != null) {
      setState(() {
        _visitTime = picked;
      });
    }
  }

  // // Reschedule date picker
  // Future<void> _selectRescheduleDate() async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _rescheduleDate ?? DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(const Duration(days: 365)),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: const ColorScheme.light(
  //             primary: Colors.orange,
  //             onPrimary: Colors.white,
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //
  //   if (picked != null) {
  //     setState(() {
  //       _rescheduleDate = picked;
  //     });
  //   }
  // }
  //
  // // Reschedule time picker
  // Future<void> _selectRescheduleTime() async {
  //   TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: _rescheduleTime ?? TimeOfDay.now(),
  //   );
  //
  //   if (picked != null) {
  //     setState(() {
  //       _rescheduleTime = picked;
  //     });
  //   }
  // }

  Future<void> _pickPhotos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          for (var file in result.files) {
            _visitPhotos.add({
              'name': file.name,
              'size': file.size,
              'path': file.path,
              'extension': file.extension,
            });
          }
          _isUploading = false;
        });

        _showSnackBar('${result.files.length} photo(s) uploaded', Colors.green);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  // Pick work photos
  Future<void> _pickWorkPhotos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _isWorkPhotoUploading = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          for (var file in result.files) {
            _workPhotos.add({
              'name': file.name,
              'size': file.size,
              'path': file.path,
              'extension': file.extension,
            });
          }
          _isWorkPhotoUploading = false;
        });

        _showSnackBar(
            '${result.files.length} work photo(s) uploaded', Colors.green);
      }
    } catch (e) {
      setState(() {
        _isWorkPhotoUploading = false;
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _visitPhotos.removeAt(index);
    });
  }

  void _removeWorkPhoto(int index) {
    setState(() {
      _workPhotos.removeAt(index);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }



  // Show complete work dialog
  void _showCompleteWorkDialog(Map<String, dynamic> visit) {
    _workTitleController.clear();
    _workCategoryController.clear();
    _completeWorkNotesController.clear();
    _workPhotos.clear();
    _workMarkers.clear();
    _workLocation = null;
    _workCompleteDateTime = DateTime.now();

    // Reset selected work category
    controller.selectedworkcategory.value = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Text('Complete Work'),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visit info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit['clientName'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Visit: ${_dateFormat.format(visit['date'])} at ${visit['time']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Work Title
                      const Text(
                        'Work Title *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _workTitleController,
                        decoration: InputDecoration(
                          hintText: 'Enter work title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.green, width: 1.5),
                          ),
                          prefixIcon: const Icon(Icons.title, color: Colors.green),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Work Category - FIXED VERSION without Obx inside StatefulBuilder
                      const Text(
                        'Work Category *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Use ValueListenableBuilder or just rebuild with setState
                      DropdownButtonFormField<String>(
                        value: controller.selectedworkcategory.value.isNotEmpty
                            ? controller.selectedworkcategory.value
                            : null,
                        hint: const Text("Choose work category"),
                        decoration: InputDecoration(
                          hintText: "Choose work category",
                          prefixIcon: const Icon(Icons.work_history_outlined ,color: Colors.green,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.green, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: controller.workcategory.map((e) {
                          String categoryName = e['category_name']?.toString() ?? '';
                          if (categoryName.isEmpty) return null;
                          return DropdownMenuItem<String>(
                            child: Text(categoryName),
                            value: categoryName,
                          );
                        }).where((item) => item != null).toList().cast<DropdownMenuItem<String>>(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedworkcategory.value = value;
                            // Force rebuild of the dialog
                            setState(() {});
                            print("=========>category ${controller.selectedworkcategory.value}");
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select work category';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Complete Date & Time
                      const Text(
                        'Complete Date & Time *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _workCompleteDateTime ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _workCompleteDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _workCompleteDateTime != null
                                      ? _dateTimeFormat.format(_workCompleteDateTime!)
                                      : 'Select date & time',
                                  style: TextStyle(
                                    color: _workCompleteDateTime != null
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Work Location with Map
                      const Text(
                        'Work Location *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Current Location Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _getWorkCurrentLocation();
                                setState(() {});
                              },
                              icon: const Icon(Icons.my_location, size: 16),
                              label: const Text('Use Current Location'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Map Preview
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _workLocation ?? const LatLng(19.0760, 72.8777),
                                  zoom: 14,
                                ),
                                markers: _workMarkers,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: true,
                                compassEnabled: true,
                                onMapCreated: (controller) {
                                  _workMapController = controller;
                                },
                                onTap: (LatLng latLng) {
                                  setState(() {
                                    _workLocation = latLng;
                                    _addWorkMarker(latLng, 'Work Location',
                                        '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}',
                                        Colors.blue);
                                  });
                                },
                              ),
                              if (_isWorkLocationLoading)
                                Container(
                                  color: Colors.black54,
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(color: Colors.white),
                                        SizedBox(height: 10),
                                        Text(
                                          'Getting location...',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      if (_workLocation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.green.shade700, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Selected: ${_workLocation!.latitude.toStringAsFixed(6)}, ${_workLocation!.longitude.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Work Photos
                      const Text(
                        'Work Photos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            if (_workPhotos.isEmpty)
                              InkWell(
                                onTap: () async {
                                  await _pickWorkPhotos();
                                  setState(() {});
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text("Tap to upload photos",
                                        style: TextStyle(color: Colors.grey.shade600)),
                                    const SizedBox(height: 4),
                                    Text("JPG, PNG", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                  ],
                                ),
                              ),
                            if (_isWorkPhotoUploading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  children: [
                                    LinearProgressIndicator(),
                                    SizedBox(height: 8),
                                    Text("Uploading..."),
                                  ],
                                ),
                              ),
                            if (_workPhotos.isNotEmpty)
                              Column(
                                children: [
                                  ..._workPhotos.asMap().entries.map((entry) {
                                    return ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.image, color: Colors.green),
                                      title: Text(entry.value['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
                                      subtitle: Text(_formatFileSize(entry.value['size'])),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.close, size: 16),
                                        onPressed: () {
                                          _removeWorkPhoto(entry.key);
                                          setState(() {});
                                        },
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () async {
                                      await _pickWorkPhotos();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text("Add More Photos"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Additional Notes
                      const Text(
                        'Additional Notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _completeWorkNotesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter any additional notes about the work...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.green, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_workTitleController.text.isEmpty) {
                      _showSnackBar('Please enter work title', Colors.orange);
                      return;
                    }
                    if (controller.selectedworkcategory.value.isEmpty) {
                      _showSnackBar('Please select work category', Colors.orange);
                      return;
                    }
                    if (_workCompleteDateTime == null) {
                      _showSnackBar('Please select complete date & time', Colors.orange);
                      return;
                    }
                    if (_workLocation == null) {
                      _showSnackBar('Please select work location', Colors.orange);
                      return;
                    }

                    // Add to completed visits
                    setState(() {
                      Map<String, dynamic> completedVisit = {
                        'id': 'VIS${_completedVisits.length + 1}',
                        'clientName': visit['clientName'],
                        'purpose': visit['purpose'],
                        'date': visit['date'],
                        'time': visit['time'],
                        'contactPerson': visit['contactPerson'],
                        'status': 'Completed',
                        'statusColor': Colors.green,
                        'outcome': 'Work completed successfully',
                        'location': visit['location'],
                        'address': visit['address'],
                        'workTitle': _workTitleController.text,
                        'workCategory': controller.selectedworkcategory.value,
                        'workCompleteDateTime': _workCompleteDateTime,
                        'workLocation': _workLocation,
                        'workPhotos': List.from(_workPhotos),
                        'workNotes': _completeWorkNotesController.text,
                      };
                      _completedVisits.add(completedVisit);
                      _upcomingVisits.remove(visit);
                    });

                    Navigator.pop(context);
                    _showSnackBar('Work completed successfully', Colors.green);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete Work'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show reschedule dialog
  void _showRescheduleDialog(Map<String, dynamic> visit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.edit_calendar, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  const Text('Reschedule Visit'),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current visit info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit['clientName'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Current: ${_dateFormat.format(
                                  visit['date'])} at ${visit['time']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // New Date
                      const Text(
                        'New Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: controller.rescheduleDate.value ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                                const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.orange,
                                    onPrimary: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              controller.rescheduleDate.value = picked;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16,
                                  color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.rescheduleDate.value != null
                                      ? _dateFormat.format(controller.rescheduleDate.value!)
                                      : 'Select new date',
                                  style: TextStyle(
                                    color: controller.rescheduleDate != null ? Colors
                                        .black : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const Icon(
                                  Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // New Time
                      const Text(
                        'New Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: controller.rescheduleTime.value ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              controller.rescheduleTime.value = picked;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, size: 16,
                                  color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.rescheduleTime.value != null
                                      ? controller.rescheduleTime.value!.format(context)
                                      : 'Select new time',
                                  style: TextStyle(
                                    color: controller.rescheduleTime.value != null ? Colors
                                        .black : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const Icon(
                                  Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Reason/Note
                      const Text(
                        'Reason for Rescheduling',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.rescheduleNoteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Please provide reason for rescheduling...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.orange, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.rescheduleNoteController.clear();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.rescheduleDate.value != null &&
                        controller.rescheduleTime.value != null &&
                        controller.rescheduleNoteController.text.isNotEmpty) {
                      // Update visit with new schedule
                      setState(() {
                        visit['date'] = controller.rescheduleDate.value;
                        visit['time'] = controller.rescheduleTime.value!.format(context);
                        visit['status'] = 'Rescheduled';
                        visit['statusColor'] = Colors.orange;
                        visit['rescheduleNote'] = controller.rescheduleNoteController
                            .text;
                      });
                      controller.reschedulevisit(context);
                      Navigator.pop(context);
                      controller.rescheduleNoteController.clear();
                      _showSnackBar(
                          'Visit rescheduled successfully', Colors.green);
                    } else {
                      _showSnackBar('Please fill all fields', Colors.orange);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reschedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Field Employee"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: "Schedule Visit", icon: Icon(Icons.calendar_month)),
            Tab(text: "Upcoming", icon: Icon(Icons.upcoming)),
            Tab(text: "History", icon: Icon(Icons.history)),
          ],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildScheduleVisitTab(),
            _buildUpcomingVisitsTab(),
            _buildVisitHistoryTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: Schedule New Visit
  Widget _buildScheduleVisitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade500,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.add_business, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Schedule New And Start Visit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Plan your client meetings and visits",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Visit Form
          Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Visit Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Client Name
                  _buildLabel("Client Name *", Icons.business),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.clientNameController,
                    decoration: _buildInputDecoration(
                        "Enter client name", Icons.business),
                  ),

                  const SizedBox(height: 16),

                  // Visit Date & Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Date *", Icons.calendar_today),
                          const SizedBox(height: 8),
                          Obx(() {
                            return TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                  text: controller.DateText),
                              onTap: () async {
                                DateTime? pickedDate = await selectDate();
                                if (pickedDate != null) {
                                  controller.Scheduldate.value = pickedDate;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Select date",
                                prefixIcon: const Icon(Icons.date_range),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (controller.Scheduldate.value == null) {
                                  return 'Required';
                                }
                                return null;
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Time *", Icons.access_time),
                          const SizedBox(height: 8),
                          Obx(() {
                            return TextFormField(
                              readOnly: true,
                              controller: TextEditingController(text: controller.timeText),
                              onTap: () async {
                                TimeOfDay? pickedTime = await selectTime();
                                if (pickedTime != null) {
                                  controller.Scheduletime.value = pickedTime;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Select time",
                                prefixIcon: const Icon(Icons.access_time), // Changed icon to time icon
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (controller.Scheduletime.value == null) {
                                  return 'Required';
                                }
                                return null;
                              },
                            );
                          })

                        ],
                      ),


                  const SizedBox(height: 16),

                  // Location Search Section
                  _buildLabel("Client Location *", Icons.location_on),
                  const SizedBox(height: 8),

                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: TextField(
                            controller: controller.searchLocationController,
                            decoration: InputDecoration(
                              hintText: "Search location...",
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _isSearching
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 1.5),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                            ),
                            onSubmitted: _searchLocation,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.my_location, color: Colors
                              .white),
                          onPressed: _getCurrentLocation,
                          tooltip: 'Get current location',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Map Preview
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation ??
                                  const LatLng(19.0760, 72.8777),
                              zoom: 12,
                            ),
                            markers: _markers,
                            polylines: _polylines,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: true,
                            compassEnabled: true,
                            onMapCreated: (controller) {
                              _mapController = controller;
                              _isMapReady = true;
                            },
                            onTap: (LatLng latLng) {
                              setState(() {
                                _selectedLocation = latLng;
                                _addMarker(latLng, 'Selected Location',
                                    '${latLng.latitude.toStringAsFixed(
                                        6)}, ${latLng.longitude.toStringAsFixed(
                                        6)}',
                                    Colors.blue);
                              });
                              _getAddressFromLatLng(
                                  latLng.latitude, latLng.longitude);
                            },
                          ),
                          if (_isLoadingLocation)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                        color: Colors.white),
                                    SizedBox(height: 10),
                                    Text(
                                      'Getting location...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Selected location info
                  if (_selectedLocation != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue.shade700,
                              size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selected: ${_selectedLocation!.latitude
                                  .toStringAsFixed(6)}, ${_selectedLocation!
                                  .longitude.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Client Address (Auto-filled from map)
                  _buildLabel("Client Address", Icons.location_on),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.clientAddressController,
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                        "Address will appear here", Icons.location_on),
                    readOnly: true,
                  ),

                  const SizedBox(height: 16),

                  // Visit Purpose
                  _buildLabel("Visit Purpose *", Icons.meeting_room),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.visitPurposeController,
                    decoration: _buildInputDecoration(
                        "e.g., Meeting, Demo, Site Visit", Icons.meeting_room),
                  ),

                  const SizedBox(height: 16),

                  // Contact Person
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Contact Person", Icons.person),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.contactPersonController,
                              decoration: _buildInputDecoration(
                                  "Person name", Icons.person),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Contact No.", Icons.phone),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.contactNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration(
                                  "Phone", Icons.phone),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Meeting Agenda
                  _buildLabel("Meeting Agenda", Icons.disc_full),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.meetingAgendaController,
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                        "What will be discussed", Icons.disc_full),
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  _buildLabel("Additional Notes", Icons.note),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.notesController,
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                        "Any special instructions", Icons.note),
                  ),

                  const SizedBox(height: 24),

                  // Schedule Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.Schedulevisit(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Schedule Visit",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: Upcoming Visits with Filter Chips
  Widget _buildUpcomingVisitsTab() {
    return Column(
      children: [
        // Filter Section with Chips
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Filter Chips
              const Text(
                'Date Filter',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _dateFilters.map((filter) {
                    return _buildFilterChip(
                      filter,
                      _selectedDateFilter == filter,
                      _getDateFilterColor(filter),
                          () {
                        setState(() {
                          _selectedDateFilter = filter;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Status Filter Chips
              const Text(
                'Status Filter',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statusFilters.map((filter) {
                    return _buildFilterChip(
                      filter,
                      _selectedStatusFilter == filter,
                      _getStatusFilterColor(filter),
                          () {
                        setState(() {
                          _selectedStatusFilter = filter;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              // Clear Filters Button
              if (_selectedDateFilter != 'All' ||
                  _selectedStatusFilter != 'All')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDateFilter = 'All';
                            _selectedStatusFilter = 'All';
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear All Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Visits List
        Expanded(
          child: _filteredUpcomingVisits.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No upcoming visits match your filters',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredUpcomingVisits.length,
            itemBuilder: (context, index) {
              final visit = _filteredUpcomingVisits[index];
              return _buildUpcomingVisitCard(visit);
            },
          ),
        ),
      ],
    );
  }

  // Helper method to build filter chips
  Widget _buildFilterChip(String label, bool isSelected, Color color,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: color,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: color,
          width: 1,
        ),
        avatar: isSelected ? null : Icon(
          _getFilterIcon(label),
          size: 16,
          color: color,
        ),
      ),
    );
  }

  // Helper method to get icon for filter
  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Today':
        return Icons.today;
      case 'Tomorrow':
        return Icons.calendar_today;
      case 'Next Week':
        return Icons.date_range;
      case 'Pending':
        return Icons.pending;
      case 'Overdue':
        return Icons.warning;
      case 'Rescheduled':
        return Icons.update;
      default:
        return Icons.filter_list;
    }
  }

  // Helper method to get color for date filter
  Color _getDateFilterColor(String filter) {
    switch (filter) {
      case 'Today':
        return Colors.green;
      case 'Tomorrow':
        return Colors.blue;
      case 'Next Week':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get color for status filter
  Color _getStatusFilterColor(String filter) {
    switch (filter) {
      case 'Pending':
        return Colors.orange;
      case 'Overdue':
        return Colors.red;
      case 'Rescheduled':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildUpcomingVisitCard(Map<String, dynamic> visit) {
    bool isOverdue = visit['status'] == 'Overdue';
    bool isRescheduled = visit['status'] == 'Rescheduled';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOverdue ? Colors.red.withOpacity(0.3) :
          isRescheduled ? Colors.orange.withOpacity(0.3) :
          Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOverdue ? Colors.red.withOpacity(0.1) :
            isRescheduled ? Colors.orange.withOpacity(0.1) :
            visit['statusColor'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isOverdue ? Icons.warning :
            isRescheduled ? Icons.update :
            Icons.business,
            color: isOverdue ? Colors.red :
            isRescheduled ? Colors.orange :
            visit['statusColor'],
          ),
        ),
        title: Text(
          visit['clientName'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isOverdue ? Colors.red.shade700 :
            isRescheduled ? Colors.orange.shade700 :
            Colors.black,
          ),
        ),
        subtitle: Text(visit['purpose']),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildVisitDetailRow(Icons.calendar_today, 'Date',
                    '${_dateFormat.format(visit['date'])} at ${visit['time']}'),
                _buildVisitDetailRow(
                    Icons.person, 'Contact', visit['contactPerson']),
                _buildVisitDetailRow(
                    Icons.location_on, 'Location', visit['address']),
                if (isOverdue)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This visit is overdue. Please take immediate action.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (visit['rescheduleNote'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, color: Colors.orange.shade700,
                            size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: ${visit['rescheduleNote']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showRescheduleDialog(visit);
                        },
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Reschedule'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showCompleteWorkDialog(visit);
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Complete Work', style: TextStyle(
                            fontSize: 13
                        ),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,

                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: Visit History
  Widget _buildVisitHistoryTab() {
    return _completedVisits.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No visit history',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedVisits.length,
      itemBuilder: (context, index) {
        final visit = _completedVisits[index];
        return _buildHistoryVisitCard(visit);
      },
    );
  }

  Widget _buildHistoryVisitCard(Map<String, dynamic> visit) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: visit['statusColor'].withOpacity(0.3)),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: visit['statusColor'].withOpacity(0.1),
          child: Icon(Icons.business, color: visit['statusColor'], size: 16),
        ),
        title: Text(
          visit['clientName'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(visit['purpose']),
            Text(
              _dateFormat.format(visit['date']),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: visit['statusColor'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: visit['statusColor']),
          ),
          child: Text(
            visit['status'],
            style: TextStyle(
              color: visit['statusColor'],
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildVisitDetailRow(
                    Icons.person, 'Contact', visit['contactPerson']),
                _buildVisitDetailRow(Icons.access_time, 'Time', visit['time']),
                _buildVisitDetailRow(
                    Icons.location_on, 'Location', visit['address']),
                if (visit['workTitle'] != null)
                  _buildVisitDetailRow(
                      Icons.title, 'Work Title', visit['workTitle']),
                if (visit['workCategory'] != null)
                  _buildVisitDetailRow(
                      Icons.category, 'Work Category', visit['workCategory']),
                if (visit['workCompleteDateTime'] != null)
                  _buildVisitDetailRow(Icons.calendar_today, 'Completed On',
                      _dateTimeFormat.format(visit['workCompleteDateTime'])),
                if (visit['workLocation'] != null)
                  _buildVisitDetailRow(Icons.location_on, 'Work Location',
                      '${visit['workLocation'].latitude.toStringAsFixed(
                          6)}, ${visit['workLocation'].longitude
                          .toStringAsFixed(6)}'),
                if (visit['workPhotos'] != null &&
                    visit['workPhotos'].isNotEmpty)
                  _buildVisitDetailRow(Icons.photo, 'Work Photos',
                      '${visit['workPhotos'].length} photos'),
                if (visit['workNotes'] != null && visit['workNotes'].isNotEmpty)
                  _buildVisitDetailRow(
                      Icons.note, 'Work Notes', visit['workNotes']),
                if (visit['outcome'] != null)
                  _buildVisitDetailRow(
                      Icons.assessment, 'Outcome', visit['outcome']),
                if (visit['rescheduleNote'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, color: Colors.orange.shade700,
                            size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reschedule Note: ${visit['rescheduleNote']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showSnackBar('View details', Colors.blue);
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Common Widgets
  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primary_color),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary_color, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildPhotoUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if (_visitPhotos.isEmpty)
            InkWell(
              onTap: _pickPhotos,
              child: Column(
                children: [
                  Icon(Icons.cloud_upload, size: 40,
                      color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text("Tap to upload photos",
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text("JPG, PNG", style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
            ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  LinearProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Uploading..."),
                ],
              ),
            ),
          if (_visitPhotos.isNotEmpty)
            Column(
              children: [
                ..._visitPhotos
                    .asMap()
                    .entries
                    .map((entry) {
                  return ListTile(
                    leading: const Icon(Icons.image, color: Colors.green),
                    title: Text(entry.value['name'], maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(_formatFileSize(entry.value['size'])),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _removePhoto(entry.key),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickPhotos,
                  icon: const Icon(Icons.add),
                  label: const Text("Add More Photos"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}