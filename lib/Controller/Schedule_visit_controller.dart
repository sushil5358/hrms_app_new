import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../services/apis_services.dart';
import 'package:http/http.dart' as http;

class SchedulevisitController  extends GetxController{

  ApiServices apiServices = ApiServices();

  // Sample visit data - Changed to RxList for reactivity
  final RxList<Map<String, dynamic>> upcomingVisits = <Map<String, dynamic>>[
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
  ].obs;


  TextEditingController clientNameController = TextEditingController();
  TextEditingController clientAddressController = TextEditingController();
  TextEditingController visitPurposeController = TextEditingController ();
  TextEditingController contactPersonController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController meetingAgendaController = TextEditingController();
  TextEditingController meetingOutcomeController = TextEditingController();
  TextEditingController searchLocationController = TextEditingController();

  var Scheduldate = Rx<DateTime?>(null);
  var Scheduletime = Rx<TimeOfDay?>(null);

  var rescheduleDate = Rx<DateTime?>(null);
  var rescheduleTime = Rx<TimeOfDay?>(null);
  TextEditingController rescheduleNoteController = TextEditingController();

   var workcategory = [].obs;

  var selectedworkcategory = ''.obs;

  String userId = "";

  String get DateText {
    if (Scheduldate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(Scheduldate.value!);
  }

  String get timeText {
    if (Scheduletime.value == null) return '';
    // Format TimeOfDay to string
    final hour = Scheduletime.value!.hour.toString().padLeft(2, '0');
    final minute = Scheduletime.value!.minute.toString().padLeft(2, '0');
    final period = Scheduletime.value!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void Schedulevisit (BuildContext context) async{
    http.Response response;
    response = await apiServices.fieldEmployeeScheduleVisit(
      clientname : clientNameController.text,
      date : Scheduldate.toString(),
      time : Scheduletime.toString(),
      location : searchLocationController.text,
      address : clientAddressController.text,
      visitpurpose : visitPurposeController.text,
      contactperson : contactPersonController.text,
      contactno : contactNumberController.text,
      meetingagenda : meetingAgendaController.text,
      additionalnotes : notesController.text,
      user_id: userId,
    );
    if(response.statusCode == 200){
      var extractdata = jsonDecode(response.body);
      print("extractdata====> $extractdata");

      if(extractdata["status"] == "true" || extractdata["status"] == true){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green,
                content: Text(extractdata["message"]))
        );

      }else{

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text("Something Went Wrong"))
        );
      }

    }else{

    }

  }



   // select work category
  void SelectWorkcategory() async{
    http.Response response;
    response = await apiServices.SelectworkCategory();
    if(response.statusCode == 200){
      var extractdata =   jsonDecode(response.body);
      print("extractdata $extractdata");

      if(extractdata["status"] == "true" || extractdata["status"] == true)
      {
        workcategory.value = extractdata["data"];
        print("workcategory ===> $workcategory");
      }

    }else{
      print("Error in fetch workcategory");
    }
  }

  // reschedule visite

void reschedulevisit (BuildContext context)async{
    http.Response response;
    response = await apiServices.Reschedulevisit(
        visit_id : "",
        user_id: userId,
        new_date: rescheduleDate.toString(),
        new_time:rescheduleTime.toString(),
        reason: rescheduleNoteController.text,
    );
    if(response.statusCode == 200){
      var extractdata = jsonDecode(response.body);
      print("extractdata====> $extractdata");

      if(extractdata["status"] == "true" || extractdata["status"] == true){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green,
                content: Text(extractdata["message"]))
        );

      }else{

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text("Something Went Wrong"))
        );
      }

    }else{

    }
}


}