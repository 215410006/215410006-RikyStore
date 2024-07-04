class ProvinceRajaOngkirList {
  List<ProvinceRajaOngkir>? results;

  ProvinceRajaOngkirList({this.results});

  ProvinceRajaOngkirList.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <ProvinceRajaOngkir>[];
      json['results'].forEach((v) {
        results!.add(ProvinceRajaOngkir.fromJson(v));
      });
    }
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   if (this.query != null) {
  //     data['query'] = this.query!.map((v) => v.toJson()).toList();
  //   }
  //   if (this.status != null) {
  //     data['status'] = this.status!.toJson();
  //   }
  //   if (this.results != null) {
  //     data['results'] = this.results!.map((v) => v.toJson()).toList();
  //   }
  //   return data;
  // }
}

class ProvinceRajaOngkir {
  String? provinceId;
  String? province;

  ProvinceRajaOngkir({this.provinceId, this.province});

  ProvinceRajaOngkir.fromJson(Map<String, dynamic> json) {
    provinceId = json['province_id'];
    province = json['province'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['province_id'] = this.provinceId;
  //   data['province'] = this.province;
  //   return data;
  // }
}
