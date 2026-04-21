import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:employee_app/services/apis_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ShiftscheduleController extends GetxController{

  ApiServices apiServices =ApiServices();

  TextEditingController reasonController = TextEditingController();
  TextEditingController additionalnoteController = TextEditingController();


  RxList sifttype = [].obs;

  String? SelectedSift;

  String userId = "";

  var date = Rx<DateTime?>(null);

  String get DateText {
    if (date.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(date.value!);
  }

  // sift type

  void SiftSchecduleChangetype ( )async{
    http.Response response;
    response = await apiServices.ShiftScheduleChangeRequest();

    if(response.statusCode ==200 ){
      var extractdata = jsonDecode(response.body);
      print("extractdata ShiftScheduleChangeRequest ==> $extractdata");

      if(extractdata["status"] == true || extractdata["status"] == true){

        sifttype.value = extractdata["data"];
        print("sifttype ShiftScheduleChangeRequest ==> $sifttype");

      }
    }else{
      print("Error in ShiftScheduleChangeRequest");
    }
  }

  void ShiftScheduleChangeRequest (BuildContext context) async {
    http.Response response;

    response = await apiServices.ShiftScheduleChangeRequestApi(
      user_id: userId,
      selectshift: SelectedSift ?? "",
      date: date.toString(),
      reason: reasonController.text,
      additionalnote: additionalnoteController.text,
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