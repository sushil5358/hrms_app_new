import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/apis_services.dart';
import 'package:http/http.dart' as http;

class Expense_Reimbursement extends GetxController{

  ApiServices apiServices = ApiServices();
  TextEditingController expenseTitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  var date = Rx<DateTime?>(null);
  String userId = "";

  String get DateText {
    if (date.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(date.value!);
  }

RxList expenseCategories = [].obs;
String? Selectedcategory;
  File? selectedFile;


    //fetct expense category
void fetctExpenseCategory ()async{
  http.Response response;
 response = await apiServices.expenseCategory();

 if(response.statusCode == 200){
   var extractdata = jsonDecode(response.body);

   print("extractdata czategory $extractdata");

   if(extractdata["status"]== true || extractdata["status"] == true){
     expenseCategories.value = extractdata["data"];
     print("expenseCategories $expenseCategories");
   }else{
     print("error in expense category");
   }
 }
}


    // Expense Reimbursement
void expense_reimbursement (BuildContext context) async{
  http.Response response;
  response = await apiServices.ExpenseReimbursement(
      expencestitle : expenseTitleController.text,
      category : Selectedcategory.toString() ,
      amount : amountController.text,
      expencesdate : date.toString(),
      uploadbillphoto : selectedFile.toString(),
      description : descriptionController.text,
      user_id : userId
  );

  if(response.statusCode == 200 ){

    var extractdata = jsonDecode(response.body);
    print("extractdata expense reimbursement ====> $extractdata");

    if(extractdata ["status"] == true|| extractdata["status"] == true){
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
