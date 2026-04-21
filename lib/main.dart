import 'package:employee_app/View/Screens/Home_page.dart';
import 'package:employee_app/utils/colers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'View/Screens/Splashscreen.dart';

void main()async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primary_color,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent
  ));

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    getPages: [
      GetPage(name: "/", page: ()=> Splashscreen()),
     // GetPage(name: "/", page: ()=> HomePage()),
    ],
  ));
}