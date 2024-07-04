import 'package:flutter/material.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';
import 'package:riky/ui/screens/auth/profile_screen.dart';
import 'package:riky/ui/screens/home/home_screen.dart';
import 'package:riky/ui/screens/order/order_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int screenindex = 0;
  final screen = [
    const HomeScreen(),
    const OrderScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[screenindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: GetTheme().backgroundGrey(context),
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: "Beranda",
              backgroundColor: GetTheme().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: "Order",
              backgroundColor: GetTheme().backgroundGrey(context)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: "Profile",
              backgroundColor: GetTheme().backgroundGrey(context)),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: GetTheme().fontColor(context),
        elevation: 0,
        showUnselectedLabels: true,
        unselectedLabelStyle: fontStyleParagraftBoldDefaultColor(context),
        selectedLabelStyle: fontStyleParagraftBoldDefaultColor(context),
        currentIndex: screenindex,
        onTap: (value) {
          setState(() {
            screenindex = value;
          });
        },
      ),
    );
  }
}
