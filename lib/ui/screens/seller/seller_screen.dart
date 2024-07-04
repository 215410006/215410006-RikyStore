import 'package:flutter/material.dart';
import 'package:riky/services/auth_helper.dart';
import 'package:riky/ui/screens/auth/login_screen.dart';
import 'package:riky/ui/screens/auth/profile_screen.dart';
import 'package:riky/ui/screens/home/home_screen.dart';
import 'package:riky/ui/screens/seller/order_screen.dart';
import 'package:riky/ui/screens/order/order_screen.dart';
import 'package:riky/ui/screens/seller/product/product_screen.dart';
import 'package:riky/ui/widgets/load_widget.dart';

class HomeSellerScreen extends StatefulWidget {
  const HomeSellerScreen({Key? key}) : super(key: key);

  @override
  _HomeSellerScreenState createState() => _HomeSellerScreenState();
}

class _HomeSellerScreenState extends State<HomeSellerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Widget> tabs = [
    SellerOrderScreen(),
    SellerProductScreen(),
    // SellerStoreScreen(),
  ];
  bool isLoad = false;

  void logout() async {
    setState(() {
      isLoad = true;
    });
    final res = await AuthHelper().logOutRes();
    if (res!.error == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        res.message ?? "",
      )));
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: logout, icon: Icon(Icons.logout))],
      ),
      body: isLoad
          ? loadIndicator()
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Order'),
                    Tab(text: 'Product'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: tabs,
                  ),
                ),
              ],
            ),
    );
  }
}
