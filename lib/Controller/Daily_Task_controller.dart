import 'dart:convert';
import 'package:employee_app/services/apis_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Daily_Task_Controller extends GetxController{

  ApiServices apiServices = ApiServices();

  var Tasks = [].obs; // Observable list
  var isLoading = true.obs;

  @override
  void onInit() {
    isLoading = false.obs;
    FetchTask();
    super.onInit();
  }

  // Task
void  FetchTask () async{
  isLoading.value = true;
  http.Response responce;

  responce = await apiServices.FetchDailyTask();

  if(responce.statusCode == 200){
    var extractdata = jsonDecode(responce.body);
    print("extractdata Dayly task $extractdata");

    if(extractdata["status"] == 'true' || extractdata["status"] == true){
      Tasks.value = extractdata["data"];
      isLoading.value = false;
    }
  }else {
    print("Failed to fetch Daily task.......}");
  }
}

// Completed Task


}