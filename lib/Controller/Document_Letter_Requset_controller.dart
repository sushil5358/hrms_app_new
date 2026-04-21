import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../services/apis_services.dart';

class Document_letter_requestcontroller extends GetxController{

  ApiServices apiServices = ApiServices();

  // Form controllers for Experience Letter
  TextEditingController expPurposeController = TextEditingController();
  TextEditingController expAdditionalInfoController = TextEditingController();

  TextEditingController salPurposeController = TextEditingController();
  TextEditingController salAdditionalInfoController = TextEditingController();

  var selectedMonth = Rx<DateTime?>(null);

  String get fromDateText {
    if (selectedMonth.value == null) return '';
    return DateFormat('MMMM yyyy').format(selectedMonth.value!);
  }




  String userId = "";

// experience letter
  void expirenceletter(BuildContext context)async{
    http.Response response;

    response = await apiServices.ExperienceLetter(
        purpose_of_req : expPurposeController.text,
        additional_information : expAdditionalInfoController.text,
        user_id : userId,
    );

    if(response.statusCode == 200){
      var extractdata = jsonDecode(response.body);
      print("extractdata expirenceletter =====> $extractdata");

      if(extractdata["status"] == true || extractdata["status"] == true){
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
    }

  }


  // salary certificate
  void Salarycertificate (BuildContext context)async{
    http.Response response;

    response = await apiServices.SalaryCertificate(
      user_id : userId,
      month : selectedMonth.toString(),
      purpose_of_req : salPurposeController.text,
      additional_information : salAdditionalInfoController.text,
    );

    if(response.statusCode == 200){
      var extractdata = jsonDecode(response.body);
      print("extractdata salarycertificate =====> $extractdata");

      if(extractdata["status"] == true || extractdata["status"] == true){
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

    }
  }







}