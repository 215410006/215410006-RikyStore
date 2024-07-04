import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riky/models/firebase/user_model.dart';
import 'package:riky/models/response_model.dart';
import 'package:riky/models/user_model.dart';

class AuthHelper {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  get user => auth.currentUser;

  Future<Response?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    Response res = Response();
    try {
      final user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Map<String, dynamic> newData = {
        UserFireStoreModel().role: UserFireStoreModel().roleUser
      };

      await firestore
          .collection(UserFireStoreModel().collection)
          .doc(user.user!.uid)
          .set(newData);

      //update username menjadi nama user
      await user.user!.updateDisplayName(name);

      await logOut();

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> login({
    required String email,
    required String password,
  }) async {
    Response res = Response();
    try {
      final user = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userFireStore = await firestore
          .collection(UserFireStoreModel().collection)
          .doc(user.user!.uid)
          .get();

      UserModel userData = UserModel();
      userData.role = userFireStore.get(UserFireStoreModel().role);

      res.data = userData;

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  //Logout
  Future logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<Response?> logOutRes() async {
    Response res = Response();
    try {
      await FirebaseAuth.instance.signOut();
      res.message = "Berhasil Keluar";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> updateUsername(String name) async {
    Response res = Response();
    try {
      await auth.currentUser!.updateDisplayName(name);
      res.message = "Berhasil mengupdate nama";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future<Response?> updateImage(File? img) async {
    Response res = Response();
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

      UploadTask uploadTask = storageReference.putFile(img!);
      await uploadTask.whenComplete(() => print('File Uploaded'));

      String imageUrl = await storageReference.getDownloadURL();

      await auth.currentUser!.updatePhotoURL(imageUrl);
      res.message = "Berhasil mengupdate foto";

      return res;
    } on FirebaseAuthException catch (e) {
      res.message = e.message ?? "Terjadi kesalahan tidak diketahui";
      res.error = e.code;
      return res;
    }
  }

  Future sendverify() async {
    await user?.sendEmailVerification();
  }
}
