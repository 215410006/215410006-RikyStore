import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riky/models/firebase/order_model.dart';
import 'package:riky/models/firebase/product_model.dart';
import 'package:riky/models/response_model.dart';

class ProductController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

  Future<Response?> deleteProduct({
    required String productId,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = {ProductFireStoreModel().active: false};
    try {
      var ref = FirebaseFirestore.instance
          .collection(ProductFireStoreModel().productCollection)
          .doc(productId)
          .update(newData);

      res.message = "Berhasil menghapus produk";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> addProduct({
    String? productId,
    List<String>? deletedVarianId,
    required ProductModel product,
  }) async {
    Response res = Response();
    Map<String, dynamic> newData = product.toMap();
    try {
      if (productId != null) {
        var ref = FirebaseFirestore.instance
            .collection(ProductFireStoreModel().productCollection)
            .doc(productId);

        await ref.update(newData);

        for (var element in deletedVarianId!) {
          if (element != '') {
            await FirebaseFirestore.instance
                .collection(ProductFireStoreModel().productCollection)
                .doc(ref.id)
                .collection(ProductFireStoreModel().variant.variantCollection)
                .doc(element)
                .update({
                  ProductFireStoreModel().variant.active: false 
                });
          }
        }

        for (var element in product.variant!) {
          if (element.id == null) {
            await FirebaseFirestore.instance
                .collection(ProductFireStoreModel().productCollection)
                .doc(ref.id)
                .collection(ProductFireStoreModel().variant.variantCollection)
                .doc()
                .set(element.toMap());
          } else {
            await FirebaseFirestore.instance
                .collection(ProductFireStoreModel().productCollection)
                .doc(ref.id)
                .collection(ProductFireStoreModel().variant.variantCollection)
                .doc(element.id)
                .set(element.toMap());
          }
        }
      } else {
        var ref = FirebaseFirestore.instance
            .collection(ProductFireStoreModel().productCollection)
            .doc();

        await ref.set(newData);

        for (var element in product.variant!) {
          if (element.id == null) {
            await FirebaseFirestore.instance
                .collection(ProductFireStoreModel().productCollection)
                .doc(ref.id)
                .collection(ProductFireStoreModel().variant.variantCollection)
                .doc()
                .set(element.toMap());
          } else {
            await FirebaseFirestore.instance
                .collection(ProductFireStoreModel().productCollection)
                .doc(ref.id)
                .collection(ProductFireStoreModel().variant.variantCollection)
                .doc(element.id)
                .set(element.toMap());
          }
        }
      }
      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }
}
