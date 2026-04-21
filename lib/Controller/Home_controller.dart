import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeController extends GetxController{
  PageController pageController = PageController();

  RxInt menuindex = 0.obs;

  void setmenuindex(int index){
    menuindex.value = index;
    pageController.jumpToPage(index);

  }
}