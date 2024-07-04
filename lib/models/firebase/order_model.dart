class OrderOptionsFireStore {
  String collection = 'order';
  String processDoc = 'process';
  String failedDoc = 'failed';
  String successDoc = 'success';
  String dataCol = 'data';

  String uid = 'uid';
  String status = 'status';
  String sellerNote = 'sellerNote';
  String resi = 'resi';
  OrderReffundOptionsFireStore reffund = OrderReffundOptionsFireStore();
  OrderPaymentOptionsFireStore payment = OrderPaymentOptionsFireStore();
  OrderAddressOptionsFireStore address = OrderAddressOptionsFireStore();
  OrderProductOptionsFireStore product = OrderProductOptionsFireStore();
}

class OrderReffundOptionsFireStore {
  String initial = 'reffund';

  String proofReffundUrl = 'proofReffundUrl';
  String bank = 'bank';
  String name = 'name';
  String number = 'number';
}

class OrderPaymentOptionsFireStore {
  String initial = 'payment';


  String proofUrl = 'proofUrl';
  String amount = 'total_amount';
  String totalPay = 'total_pay';
}

class OrderAddressOptionsFireStore {
  String initial = 'address';

  String cityId = 'city_id';
  String code = 'code';
  //Mungkin formatnya nanti service-serviceDesc
  String service = 'service';
  String serviceDesc = 'serviceDesc';
  String ongkir = 'cost';
  String address = 'detail'; //alamat lengkap
  String name = 'name'; //nama permbeli
  String phone = 'phone'; //telepon permbeli
  String weight = 'weight'; //berat total barang
}

class OrderProductOptionsFireStore {
  String initial = 'Product';

  String id = 'id';
  String initialVariant = 'variant';
  String idvariant = 'id_variant';
  String quantity = 'quantity';
}

//MODEL

class OrderModel {
  String? uid;
  String? status;
  String? resi;
  String? sellerNote;
  ProductOrderModel? product;
  AddressOrderModel? address;
  PaymentOrderModel? payment;
  ReffundOrderModel? reffund;

  OrderModel(
      {required this.uid,
      required this.status,
      required this.resi,
      required this.sellerNote,
      required this.product,
      required this.address,
      required this.payment,
      required this.reffund});

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().uid: uid,
      OrderOptionsFireStore().status: status,
      OrderOptionsFireStore().sellerNote: sellerNote,
      OrderOptionsFireStore().resi: resi,
      OrderOptionsFireStore().product.initial: product!.toMap(),
      OrderOptionsFireStore().address.initial: address!.toMap(),
      OrderOptionsFireStore().payment.initial: payment!.toMap(),
      OrderOptionsFireStore().reffund.initial: reffund!.toMap(),
    };
  }
}

//PRODUCT
class ProductOrderModel {
  String? id;
  List<ProductVariantOrderModel>? variant;

  ProductOrderModel({required this.id, required this.variant});

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().product.id: id,
      OrderOptionsFireStore().product.initialVariant:
          variant!.map((v) => v.toMap()).toList()
    };
  }
}

class ProductVariantOrderModel {
  String? id;
  int? quantity;

  ProductVariantOrderModel({required this.id, required this.quantity});

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().product.idvariant: id,
      OrderOptionsFireStore().product.quantity: quantity,
    };
  }
}

class PaymentOrderModel {
  String? proofUrl;
  int? amount;
  int? pay;

  PaymentOrderModel({
    required this.amount,
    required this.pay,
    required this.proofUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().payment.amount: amount,
      OrderOptionsFireStore().payment.proofUrl: proofUrl,
      OrderOptionsFireStore().payment.totalPay: pay,
    };
  }
}

class ReffundOrderModel {
  String? bank;
  String? name;
  String? number;
  String? proofReffundUrl;

  ReffundOrderModel({
    required this.bank,
    required this.name,
    required this.number,
    required this.proofReffundUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().reffund.name: name,
      OrderOptionsFireStore().reffund.bank: bank,
      OrderOptionsFireStore().reffund.number: number,
      OrderOptionsFireStore().reffund.proofReffundUrl: proofReffundUrl,
    };
  }
}

class AddressOrderModel {
  String? cityId;
  String? code;
  int? cost;
  String? detail;
  String? name;
  String? phone;
  String? service;
  String? serviceDesc;
  int? weight;

  AddressOrderModel(
      {required this.cityId,
      required this.code,
      required this.cost,
      required this.detail,
      required this.name,
      required this.phone,
      required this.service,
      required this.serviceDesc,
      required this.weight});

  Map<String, dynamic> toMap() {
    return {
      OrderOptionsFireStore().address.cityId: cityId,
      OrderOptionsFireStore().address.code: code,
      OrderOptionsFireStore().address.ongkir: cost,
      OrderOptionsFireStore().address.address: detail,
      OrderOptionsFireStore().address.name: name,
      OrderOptionsFireStore().address.phone: phone,
      OrderOptionsFireStore().address.service: service,
      OrderOptionsFireStore().address.serviceDesc: serviceDesc,
      OrderOptionsFireStore().address.weight: weight,
    };
  }
}
