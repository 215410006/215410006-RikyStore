// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riky/controller/order_controller.dart';
import 'package:riky/models/firebase/order_model.dart';
import 'package:riky/models/firebase/product_model.dart';
import 'package:riky/models/response_model.dart';
import 'package:riky/services/number_helper.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';
import 'package:riky/ui/widgets/load_widget.dart';

class OrderDetailScreen extends StatelessWidget {
  OrderDetailScreen({super.key, required this.orderId, required this.isSeler});
  final String orderId;
  final bool isSeler;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void accept(context, note, resi, status, bool isAcc) async {
    TextEditingController noteCtrl = TextEditingController(text: note);
    TextEditingController resiCtrl = TextEditingController(text: resi);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: IntrinsicHeight(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terima Pesanan',
                  style: fontStyleTitleAppbar(context),
                ),
                Divider(),
                Text(
                  "Catatan : ",
                  style: fontStyleSubtitleSemiBoldDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: noteCtrl,
                  style: fontStyleSubtitleDefaultColor(context),
                  decoration: InputDecoration(hintText: 'Tuliskan catatan'),
                ),
                Visibility(
                  visible: status != OrderOptionsFireStore().failedDoc && isAcc,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Resi : ",
                        style: fontStyleSubtitleSemiBoldDefaultColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextField(
                        controller: resiCtrl,
                        style: fontStyleSubtitleDefaultColor(context),
                        decoration: InputDecoration(hintText: 'Tuliskan Resi'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: fontStyleSubtitleSemiBoldDangerColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        if (status == OrderOptionsFireStore().processDoc) {
                          if (isAcc) {
                            var res = await OrderController().update(
                                orderId: orderId,
                                noteSeller: noteCtrl.text,
                                resi: resiCtrl.text,
                                statusUpdate: true);
                            if (res!.error == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  "Berhasil Menerima Order",
                                ),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  res.message ??
                                      "Terjadi kesalahan tak diketahui",
                                ),
                              ));
                            }
                          } else {
                            var res = await OrderController().reject(
                              orderId: orderId,
                              noteSeller: noteCtrl.text,
                            );
                            if (res!.error == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  "Berhasil mengupdate Order",
                                ),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  res.message ??
                                      "Terjadi kesalahan tak diketahui",
                                ),
                              ));
                            }
                          }
                        } else {
                          var res = await OrderController().update(
                              orderId: orderId,
                              noteSeller: noteCtrl.text,
                              resi: resiCtrl.text,
                              statusUpdate: false);
                          if (res!.error == null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                "Berhasil mengupdate Order",
                              ),
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                res.message ??
                                    "Terjadi kesalahan tak diketahui",
                              ),
                            ));
                          }
                        }
                      },
                      child: Text(
                        "Submit",
                        style: fontStyleSubtitleSemiBoldPrimaryColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order",
          style: fontStyleTitleAppbar(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: StreamBuilder(
          stream: firestore
              .collection(OrderOptionsFireStore().collection)
              .doc(orderId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData) {
              return Text('Order tidak ditemukan');
            }

            dynamic productData =
                snapshot.data!.get(OrderOptionsFireStore().product.initial);
            dynamic paymentData =
                snapshot.data!.get(OrderOptionsFireStore().payment.initial);
            dynamic addressData =
                snapshot.data!.get(OrderOptionsFireStore().address.initial);
            dynamic reffundData =
                snapshot.data!.get(OrderOptionsFireStore().reffund.initial);

            return StreamBuilder(
                stream: firestore
                    .collection(ProductFireStoreModel().productCollection)
                    .doc(productData[OrderOptionsFireStore().product.id])
                    .snapshots(),
                builder: (context, snapshotProduct) {
                  if (snapshotProduct.connectionState ==
                      ConnectionState.waiting) {
                    return Card();
                  }

                  if (snapshotProduct.hasError) {
                    return Text('Error: ${snapshotProduct.error}');
                  }

                  if (!snapshotProduct.hasData) {
                    return const Center(child: Text('Produk tidak ditemukan'));
                  }

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
                        child: Image.network(
                            snapshotProduct.data!
                                .get(ProductFireStoreModel().imageUrl),
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
                      ),
                      Expanded(
                          child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                EdgeInsets.all(ScreenSetting().paddingScreen),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshotProduct.data!
                                      .get(ProductFireStoreModel().name),
                                  style: fontStyleTitleH2DefaultColor(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  NumberHelper.convertToIdrWithSymbol(
                                      count: paymentData[OrderOptionsFireStore()
                                          .payment
                                          .amount],
                                      decimalDigit: 0),
                                  style: fontStyleSubtitleSemiBoldPrimaryColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Divider(),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: productData[OrderOptionsFireStore()
                                          .product
                                          .initialVariant]
                                      .length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return StreamBuilder(
                                        stream: firestore
                                            .collection(ProductFireStoreModel()
                                                .productCollection)
                                            .doc(productData[
                                                OrderOptionsFireStore()
                                                    .product
                                                    .id])
                                            .collection(ProductFireStoreModel()
                                                .variant
                                                .variantCollection)
                                            .doc(productData[
                                                    OrderOptionsFireStore()
                                                        .product
                                                        .initialVariant][index][
                                                OrderOptionsFireStore()
                                                    .product
                                                    .idvariant])
                                            .snapshots(),
                                        builder:
                                            (context, snapshotVariantProduct) {
                                          if (snapshotVariantProduct
                                                  .connectionState ==
                                              ConnectionState.waiting) {
                                            return Text("Load Variant");
                                          }

                                          if (snapshotVariantProduct.hasError) {
                                            return Text(
                                                'Error: ${snapshotVariantProduct.error}');
                                          }

                                          if (!snapshotVariantProduct.hasData) {
                                            return const Center(
                                                child: Text(
                                                    'Produk tidak ditemukan'));
                                          }

                                          return Text(
                                            "- ${snapshotVariantProduct.data!.get(ProductFireStoreModel().variant.variantName)} (${productData[OrderOptionsFireStore().product.initialVariant][index][OrderOptionsFireStore().product.quantity].toString()} item)",
                                            style:
                                                fontStyleSubtitleSemiBoldDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        });
                                  },
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    Text(
                                      "Status : ",
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        snapshot.data!.get(
                                            OrderOptionsFireStore().status),
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Resi : ",
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      snapshot.data!.get(OrderOptionsFireStore()
                                                  .resi) ==
                                              ""
                                          ? "Resi belum ditentukan oleh seller"
                                          : snapshot.data!.get(
                                              OrderOptionsFireStore().resi),
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Catatan Seller : ",
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        snapshot.data!.get(
                                            OrderOptionsFireStore().sellerNote),
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Text(
                                  "Pengiriman : ",
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Kurir : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${addressData[OrderOptionsFireStore().address.service]} - ${addressData[OrderOptionsFireStore().address.serviceDesc]}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Berat : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${addressData[OrderOptionsFireStore().address.weight]} gram',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Nama Penerima : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${addressData[OrderOptionsFireStore().address.name]}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Nomor Penerima : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${addressData[OrderOptionsFireStore().address.phone]}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Alamat : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${addressData[OrderOptionsFireStore().address.address]}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                // Row(
                                //   children: [
                                //     Text(
                                //       "Kab/Provinsi : ",
                                //       style: fontStyleSubtitleDefaultColor(
                                //           context),
                                //       maxLines: 1,
                                //       overflow: TextOverflow.ellipsis,
                                //     ),
                                //     Expanded(
                                //       child: Text(
                                //         '${addressData[OrderOptionsFireStore().address.cityId]}',
                                //         style: fontStyleSubtitleDefaultColor(
                                //             context),
                                //         maxLines: 1,
                                //         overflow: TextOverflow.ellipsis,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Row(
                                  children: [
                                    Text(
                                      "Ongkir : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${NumberHelper.convertToIdrWithSymbol(count: addressData[OrderOptionsFireStore().address.ongkir], decimalDigit: 0)}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Text(
                                  "Pembayaran : ",
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Total Pembelian : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${NumberHelper.convertToIdrWithSymbol(count: paymentData[OrderOptionsFireStore().payment.amount], decimalDigit: 0)}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Total Bayar : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${NumberHelper.convertToIdrWithSymbol(count: paymentData[OrderOptionsFireStore().payment.totalPay], decimalDigit: 0)}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bukti Bayar : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Image.network(
                                      paymentData[OrderOptionsFireStore()
                                          .payment
                                          .proofUrl],
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        "${AssetsSetting().imagePath}err.png",
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                    ),
                                  ],
                                ),
                                Divider(),
                                Text(
                                  "Data Reffund : ",
                                  style: fontStyleSubtitleSemiBoldDefaultColor(
                                      context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Nama Bank : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${reffundData[OrderOptionsFireStore().reffund.bank]}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Nomor Rek : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${reffundData[OrderOptionsFireStore().reffund.number]}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Nama Rek : ",
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${reffundData[OrderOptionsFireStore().reffund.name]}',
                                        style: fontStyleSubtitleDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: isSeler,
                                  child: snapshot.data!.get(
                                              OrderOptionsFireStore().status) !=
                                          OrderOptionsFireStore().processDoc
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => accept(
                                                    context,
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .sellerNote),
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .resi),
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .status),
                                                    true),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // <-- Radius
                                                    ),
                                                    elevation: 0,
                                                    backgroundColor: GetTheme()
                                                        .primaryColor(context)),
                                                child: Text(
                                                  "Update",
                                                  style:
                                                      fontStyleSubtitleSemiBoldWhiteColor(
                                                          context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => accept(
                                                    context,
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .sellerNote),
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .resi),
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .status),
                                                    false),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // <-- Radius
                                                    ),
                                                    elevation: 0,
                                                    backgroundColor: GetTheme()
                                                        .errorColor(context)),
                                                child: Text(
                                                  "Tolak",
                                                  style:
                                                      fontStyleSubtitleSemiBoldWhiteColor(
                                                          context),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => accept(
                                                    context,
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .sellerNote),
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .resi),
                                                    snapshot.data!.get(
                                                        OrderOptionsFireStore()
                                                            .status),
                                                    true),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // <-- Radius
                                                    ),
                                                    elevation: 0,
                                                    backgroundColor: GetTheme()
                                                        .primaryColor(context)),
                                                child: Text(
                                                  "Terima",
                                                  style:
                                                      fontStyleSubtitleSemiBoldWhiteColor(
                                                          context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ))
                    ],
                  );
                });
          }),
    );
  }
}
