import 'dart:convert';
import 'package:employee_app/services/apis_services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HolidaylistController extends GetxController{

  ApiServices apiServices = ApiServices();

  var holidaylist = [].obs; // Observable list
  var isLoading = true.obs;

  @override
  void onInit() {
    isLoading = false.obs;
    Holiday();
    super.onInit();
  }


  void Holiday ()async{
    isLoading.value = true;
    http.Response responce;

    responce = await apiServices.HolidayList();
    if(responce.statusCode == 200){
      var extractdata = jsonDecode(responce.body);
      print("extractdata HolidayList ===>  $extractdata");

      if(extractdata["status"] == 'true' || extractdata["status"] == true){
        holidaylist.value = extractdata["data"];
        isLoading.value = false;
      }
    }else {
      print("Failed to Holiday.......}");
    }
  }
}