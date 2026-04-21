import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../View/Screens/Home_page.dart';
import '../View/Screens/Login_page.dart';
import '../services/apis_services.dart';

class LoginController extends GetxController {
  ApiServices apiServices = ApiServices();
  TextEditingController email = TextEditingController();
  String userId = "";
  String comapnyId = "";

  // Add loading state
  var isLoading = false.obs;

  void login(BuildContext context) async {
    // Validate email first
    if (email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Please enter your email")
          )
      );
      return;
    }
    // Show loading indicator
    isLoading.value = true;
    try {
      http.Response response = await apiServices.login(email: email.text.trim());
      if (response.statusCode == 200) {
        var extractedData = jsonDecode(response.body);
        print("extractdata login ===> $extractedData");

        if (extractedData["status"] == "true" || extractedData["status"] == true) {

          userId = extractedData["user"]['user_id'].toString();
          comapnyId = extractedData["user"]['company_id'].toString();
          String email = extractedData["user"]['email'].toString();
          print("============> user id :- $userId");
          print("============> user email :- $email");

          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setString("user_id", userId);
          sp.setString('company_id', comapnyId);
          await sp.setBool("isLoggedIn", true);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.green,
                  content: Text(extractedData["message"] ?? "Login Successful"))
          );

          // Navigate to home
          Get.offAll(() => const HomePage());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text(extractedData["message"] ?? "Login Failed")
              )
          );
        }
      } else {
        print("Error in status code = ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text("Server error: ${response.statusCode}")
            )
        );
      }
    } catch (e) {
      print("Network error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Network error. Please check your connection.")
          )
      );
    } finally {
      isLoading.value = false;
    }
  }


  // --- LOGOUT METHOD ---
  void logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear(); // Clears everything (isLoggedIn, user_id, etc.)
    Get.offAll(() => const LoginPage());
  }
}