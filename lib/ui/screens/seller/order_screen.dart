import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riky/models/firebase/order_model.dart';
import 'package:riky/models/firebase/product_model.dart';
import 'package:riky/services/number_helper.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/auth/unauthenticated_screen.dart';
import 'package:riky/ui/screens/order/detail_screen.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/widgets/load_widget.dart';

class SellerOrderScreen extends StatefulWidget {
  const SellerOrderScreen({super.key});

  @override
  State<SellerOrderScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderScreen> {
  //Firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _selectedStatus = OrderOptionsFireStore().processDoc;

  final List<Map<String, String>> _status = [
    {'value': OrderOptionsFireStore().processDoc, 'display': 'Proses'},
    {'value': OrderOptionsFireStore().successDoc, 'display': 'Sukses'},
    {'value': OrderOptionsFireStore().failedDoc, 'display': 'Gagal'},
  ];

  User? user;
  bool isLoad = true;
  getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      setState(() {
        user = _user;
      });
    });
  }

  void startScreen() async {
    await getUser();
    setState(() {
      isLoad = false;
    });
  }

  @override
  void initState() {
    startScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      body: isLoad
          ? loadIndicator()
          : user == null
              ? Padding(
                  padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                  child: WidgetUnAuthenticated().unAuthenticated(context),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            onChanged: (String? newValue) async {
                              setState(() {
                                _selectedStatus = newValue!;
                              });
                            },
                            isExpanded: true,
                            items: _status.map<DropdownMenuItem<String>>(
                                (Map<String, String> value) {
                              return DropdownMenuItem<String>(
                                value: value['value'],
                                child: Text(
                                  value['display']!,
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        StreamBuilder(
                            stream: firestore
                                .collection(OrderOptionsFireStore().collection)
                                .where('status', isEqualTo: _selectedStatus)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return loadIndicator();
                              }

                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                    child: Text('Order masih kosong'));
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  dynamic productData = snapshot
                                      .data!.docs[index]
                                      .get(OrderOptionsFireStore()
                                          .product
                                          .initial);
                                  dynamic paymentData = snapshot
                                      .data!.docs[index]
                                      .get(OrderOptionsFireStore()
                                          .payment
                                          .initial);
                                  return StreamBuilder(
                                      stream: firestore
                                          .collection(ProductFireStoreModel()
                                              .productCollection)
                                          .doc(productData[
                                              OrderOptionsFireStore()
                                                  .product
                                                  .id])
                                          .snapshots(),
                                      builder: (context, snapshotProduct) {
                                        if (snapshotProduct.connectionState ==
                                            ConnectionState.waiting) {
                                          return Card();
                                        }

                                        if (snapshotProduct.hasError) {
                                          return Text(
                                              'Error: ${snapshotProduct.error}');
                                        }

                                        if (!snapshotProduct.hasData) {
                                          return const Center(
                                              child: Text(
                                                  'Produk tidak ditemukan'));
                                        }

                                        return Card(
                                          child: ListTile(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetailScreen(
                                                          orderId: snapshot
                                                              .data!
                                                              .docs[index]
                                                              .id,
                                                          isSeler: true),
                                                )),
                                            leading: Image.network(
                                              snapshotProduct.data!.get(
                                                  ProductFireStoreModel()
                                                      .imageUrl),
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                "${AssetsSetting().imagePath}err.png",
                                              ),
                                            ),
                                            title: Text(
                                              snapshotProduct.data!.get(
                                                  ProductFireStoreModel().name),
                                              style:
                                                  fontStyleSubtitleSemiBoldDefaultColor(
                                                      context),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  NumberHelper
                                                      .convertToIdrWithSymbol(
                                                          count: paymentData[
                                                              OrderOptionsFireStore()
                                                                  .payment
                                                                  .amount],
                                                          decimalDigit: 0),
                                                  style:
                                                      fontStyleSubtitleSemiBoldPrimaryColor(
                                                          context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                ListView.separated(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: productData[
                                                          OrderOptionsFireStore()
                                                              .product
                                                              .initialVariant]
                                                      .length,
                                                  separatorBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return SizedBox(
                                                      height: 5,
                                                    );
                                                  },
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return StreamBuilder(
                                                        stream: firestore
                                                            .collection(
                                                                ProductFireStoreModel()
                                                                    .productCollection)
                                                            .doc(productData[
                                                                OrderOptionsFireStore()
                                                                    .product
                                                                    .id])
                                                            .collection(
                                                                ProductFireStoreModel()
                                                                    .variant
                                                                    .variantCollection)
                                                            .doc(productData[
                                                                    OrderOptionsFireStore()
                                                                        .product
                                                                        .initialVariant][index]
                                                                [
                                                                OrderOptionsFireStore()
                                                                    .product
                                                                    .idvariant])
                                                            .snapshots(),
                                                        builder: (context,
                                                            snapsotVariant) {
                                                          if (snapsotVariant
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Text(
                                                                "Load Variant");
                                                          }

                                                          if (snapsotVariant
                                                              .hasError) {
                                                            return Text(
                                                                'Error: ${snapsotVariant.error}');
                                                          }

                                                          if (!snapsotVariant
                                                              .hasData) {
                                                            return const Center(
                                                                child: Text(
                                                                    'Produk tidak ditemukan'));
                                                          }
                                                          return Text(
                                                            '- ${snapsotVariant.data!.get(ProductFireStoreModel().variant.variantName)} (${productData[OrderOptionsFireStore().product.initialVariant][index][OrderOptionsFireStore().product.quantity].toString()} item)',
                                                            style:
                                                                fontStyleSubtitleDefaultColor(
                                                                    context),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          );
                                                        });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                              );
                            }),
                      ],
                    ),
                  ),
                ),
    );
  }
}
