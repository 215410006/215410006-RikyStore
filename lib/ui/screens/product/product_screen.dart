// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riky/models/firebase/product_model.dart';
import 'package:riky/services/number_helper.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/product/checkout_screen.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';
import 'package:riky/ui/widgets/load_widget.dart';

class DetailProductScreen extends StatefulWidget {
  const DetailProductScreen({super.key, required this.productId});
  final String productId;
  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  User? user;
  bool isLoad = true;
  getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      if (!mounted) return;
      setState(() {
        user = _user;
      });
    });
  }

  List<ProductSelected> productSelected = [];
  int getProductQuantity(String idVariant) {
    int index =
        productSelected.indexWhere((product) => product.idVariant == idVariant);
    if (index != -1) {
      return productSelected[index].quantity;
    } else {
      return 0;
    }
  }

  void checkout() async {
    productSelected.removeWhere((product) => product.quantity <= 0);
    if (productSelected.isNotEmpty) {
      bool isEligble = true;
      for (var element in productSelected) {
        DocumentSnapshot doc = await firestore
            .collection(ProductFireStoreModel().productCollection)
            .doc(widget.productId)
            .collection(ProductFireStoreModel().variant.variantCollection)
            .doc(element.idVariant)
            .get();
        if (!doc.exists) {
          isEligble = false;
        } else {
          if (doc.get(ProductFireStoreModel().variant.stock) <= 0) {
            isEligble = false;
          }
        }
      }
      if (isEligble) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                  coData: productSelected, productId: widget.productId),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Pastikan jumlah produk yang anda pilih sesuai dengan stok",
          ),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Mohon pilih jumlah produk pada salah satu varian",
        ),
      ));
    }
  }

  void start() async {
    await getUser();
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  //Firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: firestore
              .collection(ProductFireStoreModel().productCollection)
              .doc(widget.productId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData) {
              return const Text('Data tidak ditemukan');
            }

            if (snapshot.data == null) {
              return const Center(
                  child: Text('Produk tidak ditemukan, atau kosong'));
            }

            var data = snapshot.data;
            return Flex(
              direction: isPotrait ? Axis.vertical : Axis.horizontal,
              children: [
                SizedBox(
                  width: isPotrait
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 0.5,
                  height: isPotrait
                      ? MediaQuery.of(context).size.height * 0.4
                      : MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      Image.network(data!.get(ProductFireStoreModel().imageUrl),
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                "${AssetsSetting().imagePath}err.png",
                              ),
                          fit: isPotrait ? BoxFit.fitHeight : BoxFit.fitWidth,
                          width: isPotrait
                              ? MediaQuery.of(context).size.width
                              : MediaQuery.of(context).size.width * 0.5,
                          height: isPotrait
                              ? MediaQuery.of(context).size.height * 0.4
                              : MediaQuery.of(context).size.height),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: GetTheme().primaryColor(context),
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  width: isPotrait
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 0.5,
                  height: isPotrait
                      ? MediaQuery.of(context).size.height * 0.55
                      : MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: EdgeInsets.all(ScreenSetting().paddingScreen),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.get(ProductFireStoreModel().name),
                                  style: fontStyleTitleH2DefaultColor(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  NumberHelper.convertToIdrWithSymbol(
                                      count: data
                                          .get(ProductFireStoreModel().price),
                                      decimalDigit: 0),
                                  style: fontStyleSubtitleSemiBoldPrimaryColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Pilih Variasi dan Jumlah",
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                ),
                                StreamBuilder(
                                    stream: firestore
                                        .collection(ProductFireStoreModel()
                                            .productCollection)
                                        .doc(widget.productId)
                                        .collection(ProductFireStoreModel()
                                            .variant
                                            .variantCollection)
                                        .where('active', isEqualTo: true)
                                        .snapshots(),
                                    builder: (context, snapshotVariant) {
                                      if (snapshotVariant.connectionState ==
                                          ConnectionState.waiting) {
                                        return loadIndicator();
                                      }

                                      if (snapshotVariant.hasError) {
                                        return Text(
                                            'Error: ${snapshotVariant.error}');
                                      }

                                      if (!snapshotVariant.hasData) {
                                        return const Text(
                                            'Data tidak ditemukan');
                                      }

                                      if (snapshotVariant.data == null) {
                                        return const Center(
                                            child: Text(
                                                'Produk tidak ditemukan, atau kosong'));
                                      }

                                      return ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            snapshotVariant.data!.docs.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(
                                          height: 5,
                                        ),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var dataVariant =
                                              snapshotVariant.data!.docs[index];
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${dataVariant.get(ProductFireStoreModel().variant.variantName)} (${dataVariant.get(ProductFireStoreModel().variant.stock)})",
                                                    style:
                                                        fontStyleSubtitleSemiBoldDefaultColor(
                                                            context),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    "${NumberHelper.convertToIdrWithSymbol(count: data.get(ProductFireStoreModel().price) + dataVariant.get(ProductFireStoreModel().variant.additionalPrice), decimalDigit: 0)}/item (+ ${NumberHelper.convertToIdrWithSymbol(count: dataVariant.get(ProductFireStoreModel().variant.additionalPrice), decimalDigit: 0)})",
                                                    style:
                                                        fontStyleParagraftDefaultColor(
                                                            context),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      int index = productSelected
                                                          .indexWhere((product) =>
                                                              product
                                                                  .idVariant ==
                                                              dataVariant.id);

                                                      //validasi jika ada
                                                      if (index != -1) {
                                                        if (productSelected[
                                                                    index]
                                                                .quantity <=
                                                            0) {
                                                          productSelected
                                                              .removeWhere(
                                                                  (product) =>
                                                                      product
                                                                          .idVariant ==
                                                                      dataVariant
                                                                          .id);
                                                        } else {
                                                          if (dataVariant.get(
                                                                  ProductFireStoreModel()
                                                                      .variant
                                                                      .stock) <
                                                              productSelected[
                                                                      index]
                                                                  .quantity) {
                                                            productSelected[
                                                                        index]
                                                                    .quantity =
                                                                dataVariant.get(
                                                                    ProductFireStoreModel()
                                                                        .variant
                                                                        .stock);
                                                          } else {
                                                            productSelected[
                                                                        index]
                                                                    .quantity =
                                                                productSelected[
                                                                            index]
                                                                        .quantity -
                                                                    1;
                                                          }
                                                        }
                                                      }
                                                      setState(() {});
                                                    },
                                                    child: Icon(Icons.remove),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    getProductQuantity(
                                                            dataVariant.id)
                                                        .toString(),
                                                    style:
                                                        fontStyleSubtitleSemiBoldDefaultColor(
                                                            context),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      int index = productSelected
                                                          .indexWhere((product) =>
                                                              product
                                                                  .idVariant ==
                                                              dataVariant.id);

                                                      //validasi jika ada
                                                      if (index != -1) {
                                                        //jika selected dibawah stock maka ditambah 1
                                                        if (productSelected[
                                                                    index]
                                                                .quantity <
                                                            dataVariant.get(
                                                                ProductFireStoreModel()
                                                                    .variant
                                                                    .stock)) {
                                                          productSelected[index]
                                                                  .quantity =
                                                              productSelected[
                                                                          index]
                                                                      .quantity +
                                                                  1;
                                                        } else {
                                                          //jika tidak maka dicek apakah dibawah =1 atau tidak,jika tidak 0 maka akan selected disamakan dengan stok
                                                          if (dataVariant.get(
                                                                  ProductFireStoreModel()
                                                                      .variant
                                                                      .stock) >=
                                                              1) {
                                                            productSelected[
                                                                        index]
                                                                    .quantity =
                                                                dataVariant.get(
                                                                    ProductFireStoreModel()
                                                                        .variant
                                                                        .stock);
                                                          } else {
                                                            productSelected.removeWhere(
                                                                (product) =>
                                                                    product
                                                                        .idVariant ==
                                                                    dataVariant
                                                                        .id);
                                                          }
                                                        }
                                                      } else {
                                                        if (dataVariant.get(
                                                                ProductFireStoreModel()
                                                                    .variant
                                                                    .stock) >=
                                                            1) {
                                                          ProductSelected
                                                              newProduct =
                                                              ProductSelected(
                                                                  idVariant:
                                                                      dataVariant
                                                                          .id,
                                                                  additionalPrice:
                                                                      dataVariant.get(ProductFireStoreModel()
                                                                          .variant
                                                                          .additionalPrice),
                                                                  quantity: 1);
                                                          productSelected
                                                              .add(newProduct);
                                                        }
                                                      }
                                                      setState(() {});
                                                    },
                                                    child: Icon(Icons.add),
                                                  )
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Detail",
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  data.get("description"),
                                  style:
                                      fontStyleParagraftDefaultColor(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isPotrait
                              ? MediaQuery.of(context).size.width
                              : MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: user != null ? checkout : null,
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // <-- Radius
                                ),
                                elevation: 0,
                                backgroundColor:
                                    GetTheme().primaryColor(context)),
                            child: Text(
                              user != null ? "CheckOut" : "Login to CheckOut",
                              style:
                                  fontStyleSubtitleSemiBoldWhiteColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
