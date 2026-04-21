import 'dart:convert';
import 'package:employee_app/services/apis_services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EmployeeprofileData extends GetxController{

  ApiServices apiServices = ApiServices();

  RxList employeeprofiledata = [].obs;

  RxString userId = "".obs;
  RxString username = "".obs;
  RxString employee_code = "".obs;
  RxString mobile = "".obs;
  RxString email = "".obs;
  RxString department = "".obs;
  RxString designation = "".obs;
  RxString employment_type = "".obs;
  RxString status = "".obs;
  RxString created_at = "".obs;
  RxString basic_salary = "".obs;
  RxString hra = "".obs;
  RxString da = "".obs;
  RxString ta = "".obs;
  RxString medical_allowance = "".obs;
  RxString special_allowance = "".obs;
  RxString pf_percentage = "".obs;
  RxString professional_tax = "".obs;
  RxString total_gross_salary = "".obs;
  RxString net_salary = "".obs;
  RxString salary_updated_at = "".obs;
  RxString salary_status = "".obs;
  RxString state = "".obs;
  RxString district = "".obs;
  RxString city = "".obs;
  RxString accommodation = "".obs;
  RxString aadhar = "".obs;
  RxString pan = "".obs;
  RxString driving_license = "".obs;
  RxString bank_name = "".obs;
  RxString account_no = "".obs;
  RxString ifsc = "".obs;

  var isLoading = true.obs; // Add this line

  // Employee Profile Data
 fetchEmployeeProfileData()async{
  isLoading.value = true;
  http.Response response;
  response = await apiServices.EmployeeProfileData(
      userId.value
  );

  if(response.statusCode == 200){
    var extractdata = jsonDecode(response.body);
    print("extractdata EmployeeProfileData======> $extractdata");

    if(extractdata["status"] == "true" || extractdata["status"] == true)
    {
      // employeeprofiledata.value = extractdata["data"];
      username.value =  extractdata["data"]['name'];
      designation.value =  extractdata["data"]['designation'];
      employee_code.value =  extractdata["data"]['employee_code'];
      department.value =  extractdata["data"]['department'];
      pan.value =  extractdata["data"]['pan'];
      aadhar.value =  extractdata["data"]['aadhar'];
      email.value =  extractdata["data"]['email'];
      mobile.value =  extractdata["data"]['mobile'];
      bank_name.value =  extractdata["data"]['bank_name'];
      account_no.value =  extractdata["data"]['account_no'];
      ifsc.value =  extractdata["data"]['ifsc'];
      employment_type.value =  extractdata["data"]['employment_type'];
      total_gross_salary.value =  extractdata["data"]['total_gross_salary'];
      net_salary.value =  extractdata["data"]['net_salary'];
      basic_salary.value =  extractdata["data"]['basic_salary'].toString();
      username.value =  extractdata["data"]['name'];
      username.value =  extractdata["data"]['name'];
      username.value =  extractdata["data"]['name'];

      // print("employeeprofiledata======> $employeeprofiledata");
      isLoading.value = false;

    }
  }else {
    print("Error in EmployeeProfileData");
  }
}

}