import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riky/models/firebase/order_model.dart';
import 'package:riky/models/firebase/product_model.dart';
import 'package:riky/models/response_model.dart';

class OrderController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

  Future<Response?> order({
    required OrderModel order,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = order.toMap();
    try {
      await FirebaseFirestore.instance
          .collection(OrderOptionsFireStore().collection)
          .doc()
          .set(newData);

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> update({
    required String orderId,
    required String resi,
    required String noteSeller,
    required bool statusUpdate,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {};
    if (statusUpdate) {
      var dataOrder = await FirebaseFirestore.instance
          .collection(OrderOptionsFireStore().collection)
          .doc(orderId)
          .get();

      for (var element in dataOrder[OrderOptionsFireStore().product.initial]
          [OrderOptionsFireStore().product.initialVariant]) {
        var product = await FirebaseFirestore.instance
            .collection(ProductFireStoreModel().productCollection)
            .doc(dataOrder[OrderOptionsFireStore().product.initial]
                [OrderOptionsFireStore().product.id])
            .collection(ProductFireStoreModel().variant.variantCollection)
            .doc(element[OrderOptionsFireStore().product.idvariant]);

        var productSnapshot = await product.get();

        product.update({
          ProductFireStoreModel().variant.stock:
              productSnapshot.get(ProductFireStoreModel().variant.stock) -
                  element[OrderOptionsFireStore().product.quantity]
        });
      }

      newData = {
        OrderOptionsFireStore().status: OrderOptionsFireStore().successDoc,
        OrderOptionsFireStore().resi: resi,
        OrderOptionsFireStore().sellerNote: noteSeller
      };
    } else {
      newData = {
        OrderOptionsFireStore().resi: resi,
        OrderOptionsFireStore().sellerNote: noteSeller
      };
    }

    try {
      await FirebaseFirestore.instance
          .collection(OrderOptionsFireStore().collection)
          .doc(orderId)
          .update(newData);

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> reject({
    required String orderId,
    required String noteSeller,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {};
    newData = {
      OrderOptionsFireStore().status: OrderOptionsFireStore().failedDoc,
      OrderOptionsFireStore().sellerNote: noteSeller
    };

    try {
      await FirebaseFirestore.instance
          .collection(OrderOptionsFireStore().collection)
          .doc(orderId)
          .update(newData);

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
