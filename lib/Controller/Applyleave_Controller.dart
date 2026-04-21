import 'dart:convert';
import 'dart:io';
import 'package:employee_app/services/apis_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApplyleaveController extends GetxController{

  ApiServices apiServices = ApiServices();

  TextEditingController employeeNameController = TextEditingController(); // Pre-filled example
  TextEditingController remarkController = TextEditingController();
  TextEditingController remarkcontroller = TextEditingController();
  TextEditingController fromDateTextController = TextEditingController();
  TextEditingController toDateTextController = TextEditingController();
  RxList leveTypes = [].obs;
  File? selectedFile;

  String selectedFromDayType = "";
  String selectedToDayType = "";


  var fromedate = Rx<DateTime?>(null);
  var toDate = Rx<DateTime?>(null);
  String userId = "";

  // Helper method to get formatted date string
  String get fromDateText {
    if (fromedate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(fromedate.value!);
  }

  String get toDateText {
    if (toDate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(toDate.value!);
  }

  // Dropdown values
   String? selectedLeaveType ;

  // Date format
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  // DateTime? fromedate;
  // DateTime? toDate;

// leve type
 void fetchRawLeaveTypes() async{
   http.Response response;
   response = await apiServices.fetchRawLeaveTypes();
   if(response.statusCode == 200){
   var extractdata =   jsonDecode(response.body);
   print("extractdata $extractdata");

   if(extractdata["status"] == "true" || extractdata["status"] == true)
   {
     leveTypes.value = extractdata["data"];
     print("leveTypes $leveTypes");
   }

   }else{
     print("Error in fetchRawLeaveTypes");
   }
 }

 //apply leave

void applyleave (BuildContext context) async{
   http.Response response;
  response = await apiServices.applyleave(
     empname: employeeNameController.text,
     applieddate: DateTime.now().toString(),
     attachfile: selectedFile.toString(),
     fromdate: fromedate.toString(),
     fromday: selectedFromDayType.toString(),
     leavetype: selectedLeaveType ?? "",
     remark: remarkController.text,
     todate: toDate.toString(),
     today: selectedToDayType,
     user_id: userId,
   );

  if(response.statusCode == 200){
   var extractdata = jsonDecode(response.body);
   print("extractdata $extractdata");

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