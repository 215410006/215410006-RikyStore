class ProductFireStoreModel {
  String productCollection = "product";
  String description = "description";
  String imageUrl = "imageUrl";
  String active = "active";
  String name = "name";
  String price = "price";
  String weight = "weight";
  VariantProductFireStoreModel variant = VariantProductFireStoreModel();
}

class VariantProductFireStoreModel {
  String active = "active";
  String variantCollection = "variant";
  String additionalPrice = "additional_price";
  String stock = "stock";
  String variantName = "variant";
}

class ProductSelected {
  final String idVariant;
  int quantity;
  int additionalPrice;

  ProductSelected({
    required this.idVariant,
    required this.quantity,
    required this.additionalPrice,
  });
}

class ProductModel {
  bool? active;
  String? desc;
  String? imageURL;
  String? name;
  int? price;
  int? weight;
  List<VariantProductModel>? variant;

  ProductModel({
    required this.active,
    required this.desc,
    required this.imageURL,
    required this.name,
    required this.weight,
    required this.price,
    required this.variant,
  });

  Map<String, dynamic> toMap() {
    return {
      ProductFireStoreModel().active: active,
      ProductFireStoreModel().description: desc,
      ProductFireStoreModel().name: name,
      ProductFireStoreModel().imageUrl: imageURL,
      ProductFireStoreModel().name: name,
      ProductFireStoreModel().price: price,
      ProductFireStoreModel().weight: weight,
    };
  }
}

class VariantProductModel {
  String? id;
  String? variant;
  bool? active;
  int? addPrice;
  int? stock;

  VariantProductModel(
      {required this.addPrice,
      required this.stock,
      required this.variant,
      required this.active,
      this.id});
  Map<String, dynamic> toMap() {
    return {
      ProductFireStoreModel().variant.variantName: variant,
      ProductFireStoreModel().variant.stock: stock,
      ProductFireStoreModel().variant.active: active,
      ProductFireStoreModel().variant.additionalPrice: addPrice,
    };
  }
}
