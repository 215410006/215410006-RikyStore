import 'package:flutter/material.dart';
import 'package:riky/models/user_model.dart';
import 'package:riky/services/auth_helper.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/auth/register_screen.dart';
import 'package:riky/ui/screens/seller/seller_screen.dart';
import 'package:riky/ui/screens/layout/navbar_widget.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.email, this.password});
  final String? email;
  final String? password;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureTextPassword = true;
  final _formKey = GlobalKey<FormState>();
  bool isLoad = false;
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  void setDataFromParam() {
    if (widget.email != null) {
      emailCtrl.text = widget.email ?? "";
    }
    if (widget.password != null) {
      passwordCtrl.text = widget.password ?? "";
    }
  }

  login() {
    if (!mounted) return;
    setState(() {
      isLoad = true;
    });
    AuthHelper()
        .login(email: emailCtrl.text, password: passwordCtrl.text)
        .then((value) {
      if (value!.error == null) {
        final data = value.data as UserModel;

        if (data.role == 'seller') {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeSellerScreen(),
              ),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const NavBar(),
              ),
              (route) => false);
        }
      } else {
        setState(() {
          isLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            value.message ?? "Terjadi kesalahan tak diketahui",
          ),
        ));
      }
    });
  }

  @override
  void initState() {
    setDataFromParam();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(ScreenSetting().paddingScreen),
              child: Flex(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  direction: isPotrait ? Axis.vertical : Axis.horizontal,
                  children: [
                    SizedBox(
                      height: isPotrait
                          ? MediaQuery.of(context).size.height * 0.55
                          : MediaQuery.of(context).size.height,
                      width: !isPotrait
                          ? MediaQuery.of(context).size.width * 0.55
                          : MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Halo, Selamat Datang Kembali",
                                style: fontStyleTitleH1DefaultColor(context),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Masukkan akunmu terlebih dahulu untuk masuk",
                                style: fontStyleParagraftDefaultColor(context),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email tidak boleh kosong';
                                    }
                                    final RegExp emailRegex = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Masukkan email yang valid';
                                    }
                                    return null;
                                  },
                                  decoration:
                                      const InputDecoration(hintText: "Email"),
                                ),
                                TextFormField(
                                  controller: passwordCtrl,
                                  obscureText: obscureTextPassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) => value!.length < 8
                                      ? "Password harus lebih dari 8 digit"
                                      : null,
                                  decoration: InputDecoration(
                                      hintText: "Password",
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obscureTextPassword =
                                                  !obscureTextPassword;
                                            });
                                          },
                                          icon: Icon(obscureTextPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility))),
                                )
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !isPotrait,
                      child: SizedBox(
                        width: ScreenSetting().paddingScreen,
                      ),
                    ),
                    Expanded(
                        child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: isPotrait
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceAround,
                        children: [
                          Visibility(
                            visible: !isPotrait,
                            child: Image.asset(
                              '${AssetsSetting().imagePath}auth.png',
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      login();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // <-- Radius
                                      ),
                                      elevation: 0,
                                      backgroundColor:
                                          GetTheme().primaryColor(context)),
                                  child: Text(
                                    "Login",
                                    style: fontStyleSubtitleSemiBoldWhiteColor(
                                        context),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      )),
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // <-- Radius
                                      ),
                                      elevation: 0,
                                      backgroundColor: GetTheme()
                                          .cardColorGreyDark(context)),
                                  child: Text(
                                    "Register",
                                    style:
                                        fontStyleSubtitleSemiBoldDefaultColor(
                                            context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                  ]),
            ),
    );
  }
}
