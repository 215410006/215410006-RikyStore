import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riky/services/auth_helper.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/auth/login_screen.dart';
import 'package:riky/ui/screens/auth/unauthenticated_screen.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';
import 'package:riky/ui/widgets/load_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isLoad = true;

  TextEditingController nameCtrl = TextEditingController();

  getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
        if (user != null) {
          nameCtrl.text = user!.displayName ?? "";
        }
      });
    });
  }

  void start() async {
    await getUser();
    setState(() {
      isLoad = false;
    });
  }

  void updateUname() async {
    setState(() {
      isLoad = true;
    });
    if (nameCtrl.text == "") {
      setState(() {
        isLoad = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "nama tidak boleh kosong",
      )));
    } else {
      setState(() {
        isLoad = false;
      });
      final res = await AuthHelper().updateUsername(nameCtrl.text);
      if (res!.error == null) {
        await getUser();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          res.message ?? "-",
        )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          res.message ?? "-",
        )));
      }
    }
  }

  void logout() async {
    if (!mounted) return;
    setState(() {
      isLoad = true;
    });
    final res = await AuthHelper().logOutRes();
    if (res!.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        res.message ?? "",
      )));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        res.message ?? "Terjadi kesalahan tidak diketahui",
      )));
    }
  }

  //imagepicker
  File? _imageFile;

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  _pickImageFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        updateimage();
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        updateimage();
      });
    }
  }

  void updateimage() async {
    setState(() {
      isLoad = true;
    });
    final res = await AuthHelper().updateImage(_imageFile);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      res!.message ?? "-",
    )));
    await getUser();
    setState(() {
      isLoad = false;
    });
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: isLoad
          ? loadIndicator()
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                child: user != null
                    ? Column(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: InkWell(
                                      onTap: () {
                                        _showPicker(context);
                                      },
                                      child: Image.network(
                                        user!.photoURL ?? '',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          "${AssetsSetting().imagePath}err.png",
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          controller: nameCtrl,
                                          style:
                                              fontStyleSubtitleSemiBoldPrimaryColor(
                                                  context),
                                          decoration:
                                              InputDecoration(hintText: 'nama'),
                                        ),
                                        Text(
                                          user!.email ?? '-',
                                          style: fontStyleSubtitleDefaultColor(
                                              context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: updateUname,
                                      icon: Icon(Icons.check))
                                ],
                              ),
                            ],
                          )),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: user != null ? logout : null,
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                  elevation: 0,
                                  backgroundColor:
                                      GetTheme().errorColor(context)),
                              child: Text(
                                "Logout",
                                style: fontStyleSubtitleSemiBoldWhiteColor(
                                    context),
                              ),
                            ),
                          ),
                        ],
                      )
                    : WidgetUnAuthenticated().unAuthenticated(context),
              ),
            ),
    );
  }
}
