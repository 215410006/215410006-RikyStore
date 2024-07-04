class CheckOngkirResponseList {
  List<CheckOngkirResponse>? results;

  CheckOngkirResponseList(
      {
      this.results});

  CheckOngkirResponseList.fromJson(Map<String, dynamic> json) {
  
    if (json['results'] != null) {
      results = <CheckOngkirResponse>[];
      json['results'].forEach((v) {
        results!.add( CheckOngkirResponse.fromJson(v));
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




class CheckOngkirResponse {
  String? code;
  String? name;
  List<CostsCheckOngkirResponse>? costs;

  CheckOngkirResponse({this.code, this.name, this.costs});

  CheckOngkirResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    if (json['costs'] != null) {
      costs = <CostsCheckOngkirResponse>[];
      json['costs'].forEach((v) {
        costs!.add( CostsCheckOngkirResponse.fromJson(v));
      });
    }
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['code'] = this.code;
  //   data['name'] = this.name;
  //   if (this.costs != null) {
  //     data['costs'] = this.costs!.map((v) => v.toJson()).toList();
  //   }
  //   return data;
  // }
}

class CostsCheckOngkirResponse {
  String? service;
  String? description;
  List<CostCheckOngkirResponse>? cost;

  CostsCheckOngkirResponse({this.service, this.description, this.cost});

  CostsCheckOngkirResponse.fromJson(Map<String, dynamic> json) {
    service = json['service'];
    description = json['description'];
    if (json['cost'] != null) {
      cost = <CostCheckOngkirResponse>[];
      json['cost'].forEach((v) {
        cost!.add( CostCheckOngkirResponse.fromJson(v));
      });
    }
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['service'] = this.service;
  //   data['description'] = this.description;
  //   if (this.cost != null) {
  //     data['cost'] = this.cost!.map((v) => v.toJson()).toList();
  //   }
  //   return data;
  // }
}

class CostCheckOngkirResponse {
  int? value;
  String? etd;
  String? note;

  CostCheckOngkirResponse({this.value, this.etd, this.note});

  CostCheckOngkirResponse.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    etd = json['etd'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['etd'] = this.etd;
    data['note'] = this.note;
    return data;
  }
}
