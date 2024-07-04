import 'package:flutter/material.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/auth/login_screen.dart';
import 'package:riky/ui/screens/auth/register_screen.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';

class WidgetUnAuthenticated {
  Widget unAuthenticated(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Flex(
      direction: isPotrait ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        isPotrait
            ? Image.asset(
                "${AssetsSetting().imagePath}unauth.jpg",
                height: MediaQuery.of(context).size.height * 0.5,
              )
            : Image.asset(
                "${AssetsSetting().imagePath}unauth.jpg",
                width: MediaQuery.of(context).size.width * 0.5,
              ),
        Expanded(
          child: Column(
            mainAxisAlignment:
                isPotrait ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: [
              Text(
                "Mohon maaf anda perlu login untuk mengakses ini",
                style: fontStyleTitleH2DefaultColor(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        )),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                        elevation: 0,
                        backgroundColor: GetTheme().cardColorGreyDark(context)),
                    child: Text(
                      "Register",
                      style: fontStyleSubtitleSemiBoldDefaultColor(context),
                    ),
                  )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        )),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // <-- Radius
                        ),
                        elevation: 0,
                        backgroundColor: GetTheme().primaryColor(context)),
                    child: Text(
                      "Login",
                      style: fontStyleSubtitleSemiBoldWhiteColor(context),
                    ),
                  )),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
