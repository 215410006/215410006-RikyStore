import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riky/models/firebase/product_model.dart';
import 'package:riky/services/number_helper.dart';
import 'package:riky/settings.dart';
import 'package:riky/ui/screens/product/product_screen.dart';
import 'package:riky/ui/screens/style/font_style.dart';
import 'package:riky/ui/widgets/load_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  TextEditingController searchCtrl = TextEditingController();
//Firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

//Auth

  User? user;
  bool isLoad = true;
  getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? _user) {
      setState(() {
        user = _user;
      });
    });
  }

//Greeting
  int hoursnow = 0;
  String greeting = "Hai";
  String datenow = "0000-00-00";

  getCurrentDate() {
    var date = DateTime.now();
    var dateParse = DateTime.parse(date.toString());
    var formattedhours = "${dateParse.hour}";

    setState(() {
      hoursnow = int.parse(formattedhours);
      datenow = dateParse.toString();
    });
  }

  void setGreeting() {
    if (user != null) {
      // greeting +=
      // " ${user!.displayName!.substring(0, user!.displayName!.length < 7 ? user!.displayName!.length : 7)}";
    }
    greeting += ", ";

    if (hoursnow >= 5 && hoursnow < 11) {
      setState(() {
        greeting += "Selamat Pagi";
      });
    } else if (hoursnow >= 11 && hoursnow < 15) {
      setState(() {
        greeting += "Selamat Siang";
      });
    } else if (hoursnow >= 15 && hoursnow < 18) {
      setState(() {
        greeting += "Selamat Sore";
      });
    } else if (hoursnow >= 18 && hoursnow <= 24) {
      setState(() {
        greeting += "Selamat Malam";
      });
    } else if (hoursnow >= 0 && hoursnow < 5) {
      setState(() {
        greeting += "Selamat Malam";
      });
    }
  }

//Product

  void startScreen() async {
    await getCurrentDate();
    await getUser();
    setGreeting();
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
      appBar: AppBar(
        title: Text(
          greeting,
          style: fontStyleTitleAppbar(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: firestore
                  .collection(ProductFireStoreModel().productCollection)
                  .where('active', isEqualTo: true)
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

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Produk tidak ditemukan, atau kosong'));
                }

                snapshot.data!.docs.shuffle();

                List<DocumentSnapshot> randomProducts =
                    snapshot.data!.docs.take(3).toList();
                return CarouselSlider(
                  options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(milliseconds: 2000)),
                  items: randomProducts.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailProductScreen(productId: i.id),
                              )),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                  horizontal: ScreenSetting().paddingScreen),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      i.get("imageUrl"),
                                    ),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(
                                          0.5), // Sesuaikan dengan opacity yang diinginkan
                                      BlendMode.darken, // Pilihan efek gelap
                                    ),
                                  )),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      i.get("name"),
                                      style:
                                          fontStyleSubtitleSemiBoldWhiteColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      NumberHelper.convertToIdrWithSymbol(
                                          count: i.get("price"),
                                          decimalDigit: 0),
                                      style:
                                          fontStyleSubtitleSemiBoldPrimaryColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(ScreenSetting().paddingScreen),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "Produk Kami : ",
                      style: fontStyleTitleH3DefaultColor(context),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // Warna bayangan
                          spreadRadius: 2, // Radius penyebaran bayangan
                          blurRadius: 7, // Radius blur bayangan
                          offset: const Offset(
                              0, 8), // Perpindahan bayangan, arah bawah 3 pixel
                        ),
                      ],
                    ),
                    child: TextField(
                      onSubmitted: (value) => setState(() {
                        _searchQuery = searchCtrl.text;
                      }),
                      onEditingComplete: () => setState(() {
                        _searchQuery = searchCtrl.text;
                      }),
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search Produk',
                        suffixIcon: InkWell(
                            onTap: () => setState(() {
                                  _searchQuery = searchCtrl.text;
                                }),
                            child: const Icon(Icons.search)),
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(25.7),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(25.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder(
                    stream: firestore
                        .collection(ProductFireStoreModel().productCollection)
                        .where('active', isEqualTo: true)
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

                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('Produk tidak ditemukan, atau kosong'));
                      }

                      List<DocumentSnapshot> filteredDocs =
                          snapshot.data!.docs.where((doc) {
                        String itemName = doc[ProductFireStoreModel().name]
                            .toString()
                            .toLowerCase();
                        return itemName.contains(_searchQuery);
                      }).toList();
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isPotrait ? 2 : 4),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailProductScreen(
                                      productId: filteredDocs[index].id),
                                )),
                            child: Card(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      filteredDocs[index].get(
                                          ProductFireStoreModel().imageUrl),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        "${AssetsSetting().imagePath}err.png",
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      filteredDocs[index]
                                          .get(ProductFireStoreModel().name),
                                      style:
                                          fontStyleSubtitleSemiBoldDefaultColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      NumberHelper.convertToIdrWithSymbol(
                                          count: filteredDocs[index].get(
                                              ProductFireStoreModel().price),
                                          decimalDigit: 0),
                                      style:
                                          fontStyleSubtitleSemiBoldPrimaryColor(
                                              context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
