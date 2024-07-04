import 'package:flutter/material.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: GetTheme().primaryColor(context),
          child: Center(
            child: Text(
              "Riky",
              style: fontStyleTitleH3WhiteColor(context),
            ),
          ),
        ),
      ),
    );
  }
}
