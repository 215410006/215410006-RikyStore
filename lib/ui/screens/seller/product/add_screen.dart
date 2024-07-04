// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riky/controller/product_controller.dart';
import 'package:riky/models/firebase/product_model.dart';
import 'package:riky/services/number_helper.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';
import 'package:riky/ui/widgets/load_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key, this.productID});
  final String? productID;

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController detail = TextEditingController();
  TextEditingController weight = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> deletedVarianId = [];

  DocumentSnapshot<Map<String, dynamic>>? currentProduct;
//Firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  getCurrentProduct() async {
    setState(() {
      isLoad = true;
    });
    var snapshot = await firestore
        .collection(ProductFireStoreModel().productCollection)
        .doc(widget.productID)
        .get();
    var variantSnapshot = await firestore
        .collection(ProductFireStoreModel().productCollection)
        .doc(widget.productID)
        .collection(ProductFireStoreModel().variant.variantCollection)
        .where('active', isEqualTo: true)
        .get();

    currentProduct = snapshot;

    if (currentProduct != null) {
      name.text = '${currentProduct!.get(ProductFireStoreModel().name)}';
      price.text = '${currentProduct!.get(ProductFireStoreModel().price)}';
      weight.text = '${currentProduct!.get(ProductFireStoreModel().weight)}';
      detail.text =
          '${currentProduct!.get(ProductFireStoreModel().description)}';
      if (variantSnapshot.docs.length > 0) {
        variantList.clear();
        for (var element in variantSnapshot.docs) {
          variantList.add(VariantProductModel(
              active: true,
              id: element.id,
              addPrice:
                  element.get(ProductFireStoreModel().variant.additionalPrice),
              stock: element.get(ProductFireStoreModel().variant.stock),
              variant:
                  element.get(ProductFireStoreModel().variant.variantName)));
        }
      }
    }
    if (!mounted) return;
    setState(() {
      isLoad = false;
    });
  }

  bool isLoad = false;

  List<VariantProductModel> variantList = [
    VariantProductModel(
      addPrice: 0,
      stock: 0,
      variant: 'default',
      active: true,
    )
  ];

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return int.tryParse(str) != null;
  }

  void addVariant(VariantProductModel? initialVariant) {
    TextEditingController variantName = TextEditingController();
    TextEditingController variantPrice = TextEditingController();
    TextEditingController variantStock = TextEditingController();

    if (initialVariant != null) {
      variantName.text = initialVariant.variant ?? "";
      variantPrice.text = '${initialVariant.addPrice ?? 0}';
      variantStock.text = '${initialVariant.stock ?? 0}';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: IntrinsicHeight(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Varian : ",
                  style: fontStyleSubtitleSemiBoldDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: variantName,
                  style: fontStyleParagraftDefaultColor(context),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Harga tambahan : ",
                  style: fontStyleSubtitleSemiBoldDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: variantPrice,
                  keyboardType: TextInputType.number,
                  style: fontStyleParagraftDefaultColor(context),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Stok : ",
                  style: fontStyleSubtitleSemiBoldDefaultColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextField(
                  controller: variantStock,
                  keyboardType: TextInputType.number,
                  style: fontStyleParagraftDefaultColor(context),
                ),
                SizedBox(
                  height: 13,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
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
                      onTap: () {
                        if (isNumeric(variantPrice.text) &&
                            isNumeric(variantStock.text)) {
                          if (initialVariant != null) {
                            variantList.removeWhere((element) =>
                                element.variant == initialVariant.variant &&
                                element.stock == initialVariant.stock &&
                                element.addPrice == initialVariant.addPrice &&
                                element.id == initialVariant.id);
                            variantList.add(VariantProductModel(
                                active: true,
                                id: initialVariant.id,
                                addPrice: int.parse(variantPrice.text),
                                stock: int.parse(variantStock.text),
                                variant: variantName.text));
                          } else {
                            variantList.add(VariantProductModel(
                                active: true,
                                addPrice: int.parse(variantPrice.text),
                                stock: int.parse(variantStock.text),
                                variant: variantName.text));
                          }
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Stock atau harga tambahan harus angka",
                            ),
                          ));
                        }
                      },
                      child: Text(
                        "Submit",
                        style: fontStyleSubtitleSemiBoldPrimaryColor(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //IMAGE
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
                onTap: () async {
                  setState(() {
                    isLoad = true;
                  });
                  await _pickImageFromGallery();
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  setState(() {
                    isLoad = false;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  setState(() {
                    isLoad = true;
                  });
                  await _pickImageFromCamera();
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  setState(() {
                    isLoad = false;
                  });
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
      if (!mounted) return;
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile != null ||
          currentProduct!.get(ProductFireStoreModel().imageUrl) != '') {
        if (variantList.isNotEmpty) {
          setState(() {
            isLoad = true;
          });
          String imageUrl = '';
          if (_imageFile != null) {
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

            UploadTask uploadTask = storageReference.putFile(_imageFile!);
            await uploadTask.whenComplete(() => print('File Uploaded'));
            imageUrl = await storageReference.getDownloadURL();
          } else {
            imageUrl = currentProduct!.get(ProductFireStoreModel().imageUrl);
          }

          if (imageUrl != '') {
            var res = await ProductController().addProduct(
                productId: widget.productID,
                deletedVarianId: deletedVarianId,
                product: ProductModel(
                    active: true,
                    desc: detail.text,
                    imageURL: imageUrl,
                    name: name.text,
                    weight: int.parse(weight.text),
                    price: int.parse(price.text),
                    variant: variantList));

            if (res!.error == null) {
              setState(() {
                isLoad = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  res.error ?? 'Berhasil mengupload produk',
                ),
              ));
            } else {
              setState(() {
                isLoad = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  res.error ?? 'Gagal mengupload produk',
                ),
              ));
            }
          } else {
            setState(() {
              isLoad = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Gagal mengupload image",
              ),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "isi variant minimal 1",
            ),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "pilih gambar",
          ),
        ));
      }
    }
  }

  @override
  void initState() {
    if (widget.productID != null) {
      getCurrentProduct();
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Tambah Produk",
          style: fontStyleTitleAppbar(context),
        ),
        actions: [
          Visibility(
            visible: !isLoad,
            child: IconButton(
                onPressed: submit,
                icon: Icon(
                  Icons.check,
                  color: GetTheme().primaryColor(context),
                )),
          )
        ],
      ),
      body: isLoad
          ? loadIndicator()
          : SingleChildScrollView(
              child: Padding(
              padding: EdgeInsets.all(ScreenSetting().paddingScreen),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _showPicker(context),
                          child: _imageFile != null
                              ? Image.file(
                                  _imageFile!,
                                  width: isPotrait
                                      ? MediaQuery.of(context).size.width * 0.3
                                      : MediaQuery.of(context).size.height *
                                          0.3,
                                  height: isPotrait
                                      ? MediaQuery.of(context).size.width * 0.3
                                      : MediaQuery.of(context).size.height *
                                          0.3,
                                )
                              : currentProduct != null
                                  ? Image.network(
                                      currentProduct!.get(
                                          ProductFireStoreModel().imageUrl),
                                      width: isPotrait
                                          ? MediaQuery.of(context).size.width *
                                              0.3
                                          : MediaQuery.of(context).size.height *
                                              0.3,
                                      height: isPotrait
                                          ? MediaQuery.of(context).size.width *
                                              0.3
                                          : MediaQuery.of(context).size.height *
                                              0.3,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        "${AssetsSetting().imagePath}err.png",
                                        width: isPotrait
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                        height: isPotrait
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                      ),
                                    )
                                  : Container(
                                      width: isPotrait
                                          ? MediaQuery.of(context).size.width *
                                              0.3
                                          : MediaQuery.of(context).size.height *
                                              0.3,
                                      height: isPotrait
                                          ? MediaQuery.of(context).size.width *
                                              0.3
                                          : MediaQuery.of(context).size.height *
                                              0.3,
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey[400]!,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Ketuk untuk upload gambar",
                                          textAlign: TextAlign.center,
                                          style: fontStyleParagraftDefaultColor(
                                              context),
                                        ),
                                      ), // Ganti dengan widget anak yang sesuai
                                    ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: name,
                                validator: (value) =>
                                    value!.isEmpty ? "isi nama produk" : null,
                                style: fontStyleParagraftDefaultColor(context),
                                decoration:
                                    InputDecoration(hintText: 'nama Produk'),
                              ),
                              TextFormField(
                                controller: price,
                                keyboardType: TextInputType.number,
                                validator: (value) => !isNumeric(value ?? "")
                                    ? "harga produk hanya angka"
                                    : null,
                                style: fontStyleParagraftDefaultColor(context),
                                decoration:
                                    InputDecoration(hintText: 'harga Produk'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: weight,
                      keyboardType: TextInputType.number,
                      validator: (value) => !isNumeric(value ?? "")
                          ? "berat produk hanya angka"
                          : null,
                      style: fontStyleParagraftDefaultColor(context),
                      decoration:
                          InputDecoration(hintText: 'berat produk/gram'),
                    ),
                    TextFormField(
                      controller: detail,
                      style: fontStyleParagraftDefaultColor(context),
                      maxLines: 5,
                      decoration: InputDecoration(hintText: 'detail produk'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Varian : ",
                          style: fontStyleSubtitleSemiBoldDefaultColor(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        IconButton(
                            onPressed: () => addVariant(null),
                            icon: Icon(Icons.add))
                      ],
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: variantList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'hapus') {
                                setState(() {
                                  if (variantList[index].id != null) {
                                    deletedVarianId
                                        .add(variantList[index].id ?? "");
                                  }
                                  variantList.removeAt(index);
                                });
                              } else {
                                addVariant(variantList[index]);
                              }
                            },
                            itemBuilder: (context) => (<PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text(
                                    "edit",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                  )),
                              PopupMenuItem<String>(
                                  value: 'hapus',
                                  child: Text(
                                    "Hapus",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                  )),
                            ]),
                          ),
                          title: Text(
                            variantList[index].variant ?? "",
                            style:
                                fontStyleSubtitleSemiBoldPrimaryColor(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Stok : ",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Expanded(
                                    child: Text(
                                      variantList[index].stock.toString(),
                                      style: fontStyleParagraftDefaultColor(
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
                                    "Harga Tambahan : ",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Expanded(
                                    child: Text(
                                      NumberHelper.convertToIdrWithSymbol(
                                          count: variantList[index].addPrice,
                                          decimalDigit: 0),
                                      style: fontStyleParagraftDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Visibility(
                      visible: currentProduct != null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "*jika anda mengubah harga/berat/harga tambahan, maka data order yg masuk sebelum anda edit akan mengikuti data sebelumnya",
                            style: fontStyleParagraftDefaultColor(context),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () async {
                                var res = await ProductController()
                                    .deleteProduct(
                                        productId: widget.productID ?? "");
                                if (res!.error == null) {
                                  Navigator.pop(context);
                                }
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    res.message ?? "-",
                                  ),
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10), // <-- Radius
                                  ),
                                  elevation: 0,
                                  backgroundColor:
                                      GetTheme().errorColor(context)),
                              child: Text(
                                "Hapus Produk",
                                style: fontStyleSubtitleSemiBoldWhiteColor(
                                    context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
    );
  }
}
