import 'package:flutter/material.dart';

class GetTheme {
  Color cardColorGrey(context) {
    return const Color(0xffF5F5F5);
  }

  Color errorColor(context) {
    return const Color(0xffEB6F6F);
  }

  Color greyOutline(context) {
    return const Color(0xffE3E3E3);
  }

  Color cardColorGreyDark(context) {
    return const Color(0xffE1E0E6);
  }

  Color fontColor(context) {
    return const Color(0xff4B4B4B);
  }

  Color primaryColor(context) {
    return Theme.of(context).primaryColor;
  }

  Color buttonColor(context) {
    return Theme.of(context).primaryColor;
  }

  Color cardColors(context) {
    return Theme.of(context).cardColor;
  }

  Color accentCardColors(context) {
    return Theme.of(context).colorScheme.background;
  }

  Color backgroundGrey(context) {
    return Theme.of(context).hoverColor;
  }

  Color unselectedWidget(context) {
    return Theme.of(context).unselectedWidgetColor;
  }

  // Color backgroundColorsLight = Color(0xff426E92);
  // Color secondColor = const Color(0xff426E92);
  // Color thirdColor = const Color(0xff369B92);
  // Color secondaryButtonColors = const Color(0xff42CCC9);
  // Color buttonColors = const Color(0xff42CCC9);

  MaterialColor themeColor = MaterialColor(
    Color.fromARGB(85, 0, 136, 255).value,
    const <int, Color>{
      50: Color.fromRGBO(0, 136, 255, 0.1),
      100: Color.fromRGBO(0, 136, 255, 0.2),
      200: Color.fromRGBO(0, 136, 255, 0.3),
      300: Color.fromRGBO(0, 136, 255, 0.4),
      400: Color.fromRGBO(0, 136, 255, 0.5),
      500: Color.fromRGBO(0, 136, 255, 0.6),
      600: Color.fromRGBO(0, 136, 255, 0.7),
      700: Color.fromRGBO(0, 136, 255, 0.8),
      800: Color.fromRGBO(0, 136, 255, 0.9),
      900: Color.fromRGBO(0, 136, 255, 1),
    },
  );
}
