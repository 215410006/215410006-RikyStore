import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:riky/models/firebase/user_model.dart';
import 'package:riky/ui/screens/auth/login_screen.dart';
import 'package:riky/ui/screens/seller/seller_screen.dart';

import 'package:riky/ui/screens/layout/navbar_widget.dart';
import 'package:riky/ui/screens/splash_screen.dart';
import 'package:riky/ui/theme.dart';
import 'package:riky/ui/widgets/load_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoad = true;
  String role = UserFireStoreModel().roleUser;
  User? user;
  void checkRole() async {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) async {
      setState(() {
        user = _user;
      });
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        final userFireStore = await firestore
            .collection(UserFireStoreModel().collection)
            .doc(user!.uid)
            .get();
        setState(() {
          role = userFireStore.get(UserFireStoreModel().role);
          isLoad = false;
        });
      } else {
        setState(() {
          isLoad = false;
        });
        role = UserFireStoreModel().roleUser;
      }
    });
  }

  @override
  void initState() {
    checkRole();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riky',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 0, 136, 255),
          primarySwatch: GetTheme().themeColor),
      home: isLoad
          ? SplashScreen()
          : role == UserFireStoreModel().roleSeller
              ? HomeSellerScreen()
              : NavBar(),
    );
  }
}
