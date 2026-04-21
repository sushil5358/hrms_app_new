import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:employee_app/services/apis_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdvanceSalaryRequestController  extends GetxController{
  ApiServices apiServices = ApiServices();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String selectedPaymentMethod = "";

  final List<String> paymentMethods = [
    'Bank Transfer',
    'Cash',
    'Check',
    // 'Salary Deduction',
  ];

  var Rerureddate = Rx<DateTime?>(null);

  String get DateText {
    if (Rerureddate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(Rerureddate.value!);
  }

  void advanceSalaryrequest (BuildContext context) async{
    http.Response response;
    response = await apiServices.AdvanceSalaryrequest(
      user_id: "53",
      required_date: Rerureddate.toString(),
      advance_amount: amountController.text,
      payment_method: selectedPaymentMethod,
      reason: reasonController.text,
      current_salary: "",
    );

    if(response.statusCode == 200){
      var extractdata =   jsonDecode(response.body);
      print("extractdata advanceSalaryrequest ===> $extractdata");

      if(extractdata['status'] == true || extractdata['status'] ==  "true"){

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