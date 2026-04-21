library flutter_images.colors;

import 'package:flutter/material.dart';

const black = Colors.black;
const white = Colors.white;

// Color primary_color = HexColor("#28377f");


Color primary_color = HexColor("#0073B6");
Color button_color=HexColor("#f39220");
// Color button_color=HexColor("#4d4c4c");
Color submit_button_color = HexColor("#FF5733");
Color snackbar_fail = HexColor("#B52506");
Color snackbar_success = HexColor("#308d08");
Color hint_color = HexColor("#757575");

Color blue = HexColor("#0f4e8d");
Color red = HexColor("#B52506");
Color orange = HexColor("#F39220");
Color gray = HexColor("#757575");
Color text_color = HexColor("#848484");

Color background_color = HexColor("#dadada");
Color light_gray = HexColor("#dadada");
Color labelcolor=HexColor("#666666");


Color navy = HexColor("#000080");
Color yellow = HexColor("#FFA500");
Color dark_yellow = HexColor("#FFCE59");
Color pista = HexColor("#58D38F");
Color green = HexColor("#308d08");
Color purple = HexColor("#35297e");
Color dark_green = HexColor("#256903");
Color dark_gray = HexColor("#52595D");


Color background = HexColor("#E8EAE9");
Color mediaselectbuttonbackgroundcolor = HexColor("#E8E8E8");
Color primery_color = HexColor("#3196b0");
Color primery_color_dark = HexColor("#000000");

Color resend = HexColor("#5302dd");
Color plan_gray = HexColor("#dfe6ed");

Color lightblue = HexColor("#FF40C4FF");
Color darkblue = HexColor("#FF0D47A1");
Color transparent = HexColor("#00000000");
Color primaryFontColor = HexColor("#0073B6");

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

TextStyle labelStyle = TextStyle(fontSize: 15);






