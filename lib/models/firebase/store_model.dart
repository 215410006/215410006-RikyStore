class StoreInfoFireStoreModel {
  String storeCollection = 'store';
  StoreInfoLocationFireStoreModel location = StoreInfoLocationFireStoreModel();
  StoreInfoDetailFireStoreModel details = StoreInfoDetailFireStoreModel();
}

class StoreInfoLocationFireStoreModel {
  String locationDoc = 'location';
  String address = 'address';
  String cityIdRo = 'cityId_rajaOngkir';
}

class StoreInfoDetailFireStoreModel {
  String detailsDoc = 'details';
  String name = 'name';
}
