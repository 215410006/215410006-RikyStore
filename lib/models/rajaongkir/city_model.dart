class CityRajaOngkirList {
  List<CityRajaOngkir>? results;

  CityRajaOngkirList({this.results});

  CityRajaOngkirList.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <CityRajaOngkir>[];
      json['results'].forEach((v) {
        results!.add(CityRajaOngkir.fromJson(v));
      });
    }
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();

  //   if (this.results != null) {
  //     data['results'] = this.results!.map((v) => v.toJson()).toList();
  //   }
  //   return data;
  // }
}


class CityRajaOngkir {
  String? cityId;
  String? provinceId;
  String? province;
  String? type;
  String? cityName;
  String? postalCode;

  CityRajaOngkir(
      {this.cityId,
      this.provinceId,
      this.province,
      this.type,
      this.cityName,
      this.postalCode});

  CityRajaOngkir.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id'];
    provinceId = json['province_id'];
    province = json['province'];
    type = json['type'];
    cityName = json['city_name'];
    postalCode = json['postal_code'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['city_id'] = this.cityId;
  //   data['province_id'] = this.provinceId;
  //   data['province'] = this.province;
  //   data['type'] = this.type;
  //   data['city_name'] = this.cityName;
  //   data['postal_code'] = this.postalCode;
  //   return data;
  // }
}
