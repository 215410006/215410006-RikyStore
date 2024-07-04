// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riky/controller/Rongkir_controller.dart';
import 'package:riky/controller/order_controller.dart';
import 'package:riky/models/firebase/order_model.dart';
import 'package:riky/models/firebase/payment_model.dart';
import 'package:riky/models/firebase/product_model.dart';
import 'package:riky/models/firebase/store_model.dart';
import 'package:riky/models/rajaongkir/check_model.dart';
import 'package:riky/models/rajaongkir/city_model.dart';
import 'package:riky/models/rajaongkir/province_model.dart';
import 'package:riky/services/number_helper.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/layout/navbar_widget.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/theme.dart';
import 'package:riky/ui/widgets/load_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen(
      {super.key, required this.coData, required this.productId});
  final List<ProductSelected> coData;
  final String productId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController reffNumber = TextEditingController();
  TextEditingController reffName = TextEditingController();
  TextEditingController reffBank = TextEditingController();
  TextEditingController address = TextEditingController();
  List<ProductVariantOrderModel> variantListData = [];

  String _selectedProvince = '';
  String _selectedCity = '';
  String _selectedCourierCode = ''; //code
  String _selectedCourierCost = ''; //service
  String _selectedCourierCostDesc = ''; //serviceDesc
  String _selectedCourier = 'jne';

  final List<Map<String, String>> _courier = [
    {'value': 'jne', 'display': 'Jne'},
    {'value': 'pos', 'display': 'Pos'},
    {'value': 'tiki', 'display': 'Tiki'},
  ];

  final _formKey = GlobalKey<FormState>();
  int amount = 0;
  int amountFinal = 0;
  int ongkir = 0;
  int weight = 0; //weight total
  int weightProduct = 0;
  int productPrice = 0;
  User? user;
  bool isLoad = true;
  String selectedPay = 'bca';
  getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      setState(() {
        user = _user;
      });
    });
  }

//RAJA ONGKIR
  ProvinceRajaOngkirList provinceData = ProvinceRajaOngkirList(results: []);
  CityRajaOngkirList cityData = CityRajaOngkirList(results: []);
  CheckOngkirResponseList ongkirData = CheckOngkirResponseList(results: []);

  getProvince() async {
    var res = await RajaOngkirController().getProvince();
    if (res.error == null) {
      provinceData = res.data as ProvinceRajaOngkirList;
      _selectedProvince = provinceData.results![0].provinceId ?? '';
      await getCity();
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error.toString(),
        ),
      ));
    }
  }

  selectProvince() async {
    setState(() {
      isLoad = true;
    });
    await getCity();
    isLoad = false;
  }

  getCity() async {
    var res =
        await RajaOngkirController().getCity(provinceId: _selectedProvince);
    if (res.error == null) {
      setState(() {
        cityData = CityRajaOngkirList(results: []);
        cityData = res.data as CityRajaOngkirList;
        _selectedCity = cityData.results![0].cityId ?? '';
      });
      await cekOngkir();
      // setState(() {
      //   isLoad = false;
      // });
    } else {
      setState(() {
        _selectedCity = '';
        cityData = CityRajaOngkirList(results: []);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          res.error.toString(),
        ),
      ));
    }
  }

  void selectCity(CityRajaOngkir city) async {
    setState(() {
      isLoad = true;
    });
    await cekOngkir();
    setState(() {
      address.text =
          'Kab. ${city.cityName}, ${city.province} - ${city.postalCode}';
      isLoad = false;
    });
  }

  cekOngkir() async {
    setState(() {
      isLoad = true;
    });

    DocumentSnapshot doc = await firestore
        .collection(StoreInfoFireStoreModel().storeCollection)
        .doc(StoreInfoFireStoreModel().location.locationDoc)
        .get();
    if (!doc.exists) {
      Navigator.pop(context);
    }

    var result = await RajaOngkirController().checkOngkir(
        cityOriginId: doc.get(StoreInfoFireStoreModel().location.cityIdRo),
        cityDestinationId: _selectedCity,
        weight: weight,
        courier: _selectedCourier);

    if (result.error == null) {
      setState(() {
        ongkirData = result.data as CheckOngkirResponseList;
      });
    } else {
      setState(() {
        isLoad = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result.error.toString(),
        ),
      ));
    }
  }

  void start() async {
    DocumentSnapshot doc = await firestore
        .collection(ProductFireStoreModel().productCollection)
        .doc(widget.productId)
        .get();
    if (!doc.exists) {
      Navigator.pop(context);
    } else {
      setState(() {
        weightProduct = doc.get(ProductFireStoreModel().weight);
        productPrice = doc.get(ProductFireStoreModel().price);
      });
    }

    for (var element in widget.coData) {
      variantListData.add(ProductVariantOrderModel(
          id: element.idVariant, quantity: element.quantity));
      int total = (productPrice + element.additionalPrice) * element.quantity;
      setState(() {
        weight = weight + (weightProduct * element.quantity);
        amount = amount + total;
        amountFinal = amount;
      });
    }
    await getUser();
    await getProvince();
    setState(() {
      isLoad = false;
    });
  }

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
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void order() async {
    setState(() {
      isLoad = true;
    });
    if (_imageFile == null) {
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Upload bukti pembayaran",
        ),
      ));
      return;
    }

    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

      UploadTask uploadTask = storageReference.putFile(_imageFile!);
      await uploadTask.whenComplete(() => print('File Uploaded'));

      String imageUrl = await storageReference.getDownloadURL();

      if (imageUrl != '') {
        var res = await OrderController().order(
          order: OrderModel(
            product: ProductOrderModel(
                id: widget.productId, variant: variantListData),
            status: OrderOptionsFireStore().processDoc,
            resi: '',
            sellerNote: '-',
            address: AddressOrderModel(
                cityId: _selectedCity,
                code: _selectedCourierCode,
                cost: ongkir,
                detail: address.text,
                name: name.text,
                phone: phone.text,
                service: _selectedCourierCost,
                serviceDesc: _selectedCourierCostDesc,
                weight: weight),
            payment: PaymentOrderModel(
                amount: amount, pay: amountFinal, proofUrl: imageUrl),
            reffund: ReffundOrderModel(
                proofReffundUrl: '',
                bank: reffBank.text,
                name: reffName.text,
                number: reffNumber.text),
            uid: user!.uid,
          ),
        );

        if (res!.error == null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NavBar(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Berhasil membuat order",
            ),
          ));
        } else {
          setState(() {
            isLoad = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              res.error.toString(),
            ),
          ));
        }
      } else {
        setState(() {
          isLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Gagal mengupload bukti pembayaran",
          ),
        ));
      }
    } catch (e) {
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.toString(),
        ),
      ));
    }
  }

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPotrait = MediaQuery.of(context).orientation == Orientation.landscape
        ? false
        : true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CheckOut",
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: isLoad
          ? loadIndicator()
          : Flex(
              direction: isPotrait ? Axis.vertical : Axis.horizontal,
              children: [
                SizedBox(
                  width: isPotrait
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 0.5,
                  height: isPotrait
                      ? MediaQuery.of(context).size.height * 0.35
                      : MediaQuery.of(context).size.height,
                  child: StreamBuilder(
                      stream: firestore
                          .collection(ProductFireStoreModel().productCollection)
                          .doc(widget.productId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                              child:
                                  Text('Produk tidak ditemukan, atau kosong'));
                        }

                        var data = snapshot.data;
                        return SingleChildScrollView(
                          child: Padding(
                            padding:
                                EdgeInsets.all(ScreenSetting().paddingScreen),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Invoice Pembelian",
                                  style: fontStyleTitleH2DefaultColor(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(),
                                Text(
                                  data!.get(ProductFireStoreModel().name),
                                  style: fontStyleTitleH3DefaultColor(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Varian Produk",
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Total",
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: widget.coData.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Column(
                                      children: [
                                        Divider(),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    );
                                  },
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return StreamBuilder(
                                        stream: firestore
                                            .collection(ProductFireStoreModel()
                                                .productCollection)
                                            .doc(widget.productId)
                                            .collection(ProductFireStoreModel()
                                                .variant
                                                .variantCollection)
                                            .doc(widget.coData[index].idVariant)
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

                                          var dataVariant =
                                              snapshotVariant.data;
                                          int total = (productPrice +
                                                  widget.coData[index]
                                                      .additionalPrice) *
                                              widget.coData[index].quantity;

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${dataVariant!.get(ProductFireStoreModel().variant.variantName)} x ${widget.coData[index].quantity}",
                                                    style:
                                                        fontStyleSubtitleDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "(${NumberHelper.convertToIdrWithSymbol(count: productPrice, decimalDigit: 0)} + ${NumberHelper.convertToIdrWithSymbol(count: widget.coData[index].additionalPrice, decimalDigit: 0)}) x ${widget.coData[index].quantity}",
                                                    style:
                                                        fontStyleSubtitleDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${NumberHelper.convertToIdrWithSymbol(count: total, decimalDigit: 0)}',
                                                style:
                                                    fontStyleSubtitleDefaultColor(
                                                        context),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total keseluruhan",
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${NumberHelper.convertToIdrWithSymbol(count: amount, decimalDigit: 0)}',
                                      style: fontStyleSubtitleDefaultColor(
                                          context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                Expanded(
                    child: SizedBox(
                  width: isPotrait
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  EdgeInsets.all(ScreenSetting().paddingScreen),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pilih Alamat",
                                    style:
                                        fontStyleTitleH3DefaultColor(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Berat total : ",
                                        style:
                                            fontStyleParagraftBoldDefaultColor(
                                                context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "$weight gram (${weightProduct}g/product)",
                                        style: fontStyleParagraftDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    validator: (value) => value!.isEmpty
                                        ? 'isi nama penerima paket'
                                        : null,
                                    controller: name,
                                    decoration: const InputDecoration(
                                        hintText: "Nama Penerima"),
                                  ),
                                  TextFormField(
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) => value!.isEmpty
                                        ? 'isi nomor penerima paket'
                                        : null,
                                    controller: phone,
                                    decoration: const InputDecoration(
                                        hintText: "Nomor Penerima"),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: DropdownButton<String>(
                                      value: _selectedProvince,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedProvince = newValue!;
                                          selectProvince();
                                        });
                                      },
                                      hint: Text(
                                        "Tidak Ditemukan Provinsi",
                                        style: fontStyleParagraftDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      isExpanded: true,
                                      items: provinceData.results!
                                          .map<DropdownMenuItem<String>>(
                                              (ProvinceRajaOngkir value) {
                                        return DropdownMenuItem<String>(
                                          value: value.provinceId,
                                          child: Text(
                                            value.province!,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: DropdownButton<String>(
                                      value: _selectedCity,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedCity = newValue!;
                                          selectCity(cityData.results!
                                              .singleWhere((element) =>
                                                  element.cityId ==
                                                  _selectedCity));
                                        });
                                      },
                                      hint: Text(
                                        "Tidak Ditemukan Kota",
                                        style: fontStyleParagraftDefaultColor(
                                            context),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      isExpanded: true,
                                      items: cityData.results!
                                          .map<DropdownMenuItem<String>>(
                                              (CityRajaOngkir value) {
                                        return DropdownMenuItem<String>(
                                          value: value.cityId,
                                          child: Text(
                                            "${value.cityName} - ${value.postalCode}",
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Text(
                                    "Alamat Lengkap",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  TextFormField(
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    maxLines: 2,
                                    validator: (value) => value!.isEmpty
                                        ? 'isi detail alamat lengkap'
                                        : null,
                                    controller: address,
                                    decoration: const InputDecoration(
                                        hintText: "Detail alamat"),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: DropdownButton<String>(
                                      value: _selectedCourier,
                                      onChanged: (String? newValue) async {
                                        setState(() {
                                          _selectedCourier = newValue!;
                                        });
                                        await cekOngkir();
                                        setState(() {
                                          isLoad = false;
                                        });
                                      },
                                      isExpanded: true,
                                      items: _courier
                                          .map<DropdownMenuItem<String>>(
                                              (Map<String, String> value) {
                                        return DropdownMenuItem<String>(
                                          value: value['value'],
                                          child: Text(
                                            value['display']!,
                                            style:
                                                fontStyleParagraftDefaultColor(
                                                    context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Text(
                                    "Pilih paket jasa kirim",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: ongkirData.results!.length,
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider();
                                    },
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ExpansionTile(
                                        title: Text(
                                          ongkirData.results![index].name ?? "",
                                          style:
                                              fontStyleParagraftBoldDefaultColor(
                                                  context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: ongkirData
                                                .results![index].costs!.length,
                                            itemBuilder: (BuildContext context,
                                                int iChild) {
                                              return Row(
                                                children: [
                                                  Checkbox(
                                                    value: _selectedCourierCode ==
                                                            ongkirData
                                                                .results![index]
                                                                .code &&
                                                        _selectedCourierCost ==
                                                            ongkirData
                                                                .results![index]
                                                                .costs![iChild]
                                                                .service,
                                                    onChanged:
                                                        (bool? newValue) {
                                                      setState(() {
                                                        _selectedCourierCode =
                                                            ongkirData
                                                                    .results![
                                                                        index]
                                                                    .code ??
                                                                "";
                                                        _selectedCourierCost =
                                                            ongkirData
                                                                    .results![
                                                                        index]
                                                                    .costs![
                                                                        iChild]
                                                                    .service ??
                                                                "";
                                                        _selectedCourierCostDesc =
                                                            ongkirData
                                                                    .results![
                                                                        index]
                                                                    .costs![
                                                                        iChild]
                                                                    .description ??
                                                                "";
                                                        setState(() {
                                                          ongkir = ongkirData
                                                              .results![index]
                                                              .costs![iChild]
                                                              .cost![0]
                                                              .value!
                                                              .toInt();
                                                        });
                                                        amountFinal =
                                                            amount + ongkir;
                                                      });
                                                    },
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${ongkirData.results![index].costs![iChild].service} - ${ongkirData.results![index].costs![iChild].description}',
                                                        style:
                                                            fontStyleParagraftBoldDefaultColor(
                                                                context),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        '${NumberHelper.convertToIdrWithSymbol(count: ongkirData.results![index].costs![iChild].cost![0].value, decimalDigit: 0)} | ${ongkirData.results![index].costs![iChild].cost![0].etd} hari',
                                                        style:
                                                            fontStyleParagraftBoldDefaultColor(
                                                                context),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  Divider(),
                                  Text(
                                    "Pembayaran",
                                    style:
                                        fontStyleTitleH3DefaultColor(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  StreamBuilder(
                                      stream: firestore
                                          .collection(PaymentFireStoreModel()
                                              .paymentCollection)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return loadIndicator();
                                        }

                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }

                                        if (!snapshot.hasData) {
                                          return const Text(
                                              'Data tidak ditemukan');
                                        }

                                        if (snapshot.data == null) {
                                          return const Center(
                                              child: Text(
                                                  'Produk tidak ditemukan, atau kosong'));
                                        }

                                        List<String> items = snapshot.data!.docs
                                            .map((doc) => doc.id)
                                            .toList();
                                        return DropdownSearch<String>(
                                          items: items,
                                          dropdownDecoratorProps:
                                              const DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                                InputDecoration(
                                              labelText: "Metode Pembayaran",
                                            ),
                                          ),
                                          onChanged: (value) => setState(() {
                                            // resetAmount();
                                            selectedPay = value ?? 'bca';
                                          }),
                                          selectedItem: selectedPay,
                                        );
                                      }),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Visibility(
                                    visible: selectedPay != "",
                                    child: StreamBuilder(
                                        stream: firestore
                                            .collection(PaymentFireStoreModel()
                                                .paymentCollection)
                                            .doc(selectedPay)
                                            .snapshots(),
                                        builder: (context, snapshotPayment) {
                                          if (snapshotPayment.connectionState ==
                                              ConnectionState.waiting) {
                                            return loadIndicator();
                                          }

                                          if (snapshotPayment.hasError) {
                                            return Text(
                                                'Error: ${snapshotPayment.error}');
                                          }

                                          if (!snapshotPayment.hasData) {
                                            return const Text(
                                                'Data tidak ditemukan');
                                          }

                                          if (snapshotPayment.data == null) {
                                            return const Center(
                                                child: Text(
                                                    'Produk tidak ditemukan, atau kosong'));
                                          }

                                          var dataPayment =
                                              snapshotPayment.data;
                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Jumlah Dibayarkan : ",
                                                    style:
                                                        fontStyleParagraftBoldDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    NumberHelper
                                                        .convertToIdrWithSymbol(
                                                            count: amountFinal,
                                                            decimalDigit: 0),
                                                    style:
                                                        fontStyleParagraftDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Pembayaran : ",
                                                    style:
                                                        fontStyleParagraftBoldDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    dataPayment!.id,
                                                    style:
                                                        fontStyleParagraftDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Nomor Rekening : ",
                                                    style:
                                                        fontStyleParagraftBoldDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    dataPayment.get(
                                                        PaymentFireStoreModel()
                                                            .number),
                                                    style:
                                                        fontStyleParagraftDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Nama Rekening : ",
                                                    style:
                                                        fontStyleParagraftBoldDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    dataPayment.get(
                                                        PaymentFireStoreModel()
                                                            .name),
                                                    style:
                                                        fontStyleParagraftDefaultColor(
                                                            context),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                  Divider(),
                                  Text(
                                    "Upload Bukti Pembayaran",
                                    style:
                                        fontStyleTitleH3DefaultColor(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _showPicker(context);
                                    },
                                    child: _imageFile != null
                                        ? Image.file(
                                            _imageFile!,
                                            height: 200,
                                          )
                                        : Container(
                                            padding: EdgeInsets.all(20),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.grey[400]!,
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                  "Ketuk untuk upload gambar"),
                                            ), // Ganti dengan widget anak yang sesuai
                                          ),
                                  ),
                                  Divider(),
                                  Text(
                                    "Rekening Anda",
                                    style:
                                        fontStyleTitleH3DefaultColor(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Dibutuhkan untuk proses reffund jika terjadi kendala/kehabisan stok",
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Nomor Rek Anda",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  TextFormField(
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    validator: (value) => value!.isEmpty
                                        ? 'isi Nomor rekening anda'
                                        : null,
                                    controller: reffNumber,
                                    decoration: const InputDecoration(
                                        hintText: "Nomor Rekening Anda"),
                                  ),
                                  Text(
                                    "Nama Rek Anda",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  TextFormField(
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    validator: (value) => value!.isEmpty
                                        ? 'isi Nama rekening anda'
                                        : null,
                                    controller: reffName,
                                    decoration: const InputDecoration(
                                        hintText: "Nama Rekening Anda"),
                                  ),
                                  Text(
                                    "Nama Bank",
                                    style: fontStyleParagraftBoldDefaultColor(
                                        context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  TextFormField(
                                    style:
                                        fontStyleParagraftDefaultColor(context),
                                    validator: (value) => value!.isEmpty
                                        ? 'isi Nama Bank Rekening anda'
                                        : null,
                                    controller: reffBank,
                                    decoration: const InputDecoration(
                                        hintText: "Nama Bank"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: ScreenSetting().paddingScreen,
                            right: ScreenSetting().paddingScreen,
                            bottom: ScreenSetting().paddingScreen),
                        child: SizedBox(
                          width: isPotrait
                              ? MediaQuery.of(context).size.width
                              : MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            onPressed: user != null
                                ? _selectedCity == ""
                                    ? null
                                    : _selectedCourierCode == ""
                                        ? null
                                        : _selectedCourierCost == ""
                                            ? null
                                            : _imageFile == null
                                                ? null
                                                : widget.coData.length <= 0
                                                    ? null
                                                    : () {
                                                        if (_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          order();
                                                        }
                                                      }
                                : null,
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // <-- Radius
                                ),
                                elevation: 0,
                                backgroundColor:
                                    GetTheme().primaryColor(context)),
                            child: Text(
                              user != null ? "Submit" : "Login to Submit",
                              style:
                                  fontStyleSubtitleSemiBoldWhiteColor(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            ),
    );
  }
}
