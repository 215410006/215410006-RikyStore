import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:riky/models/rajaongkir/check_model.dart';
import 'package:riky/models/rajaongkir/city_model.dart';
import 'package:riky/models/rajaongkir/initial_model.dart';
import 'package:riky/models/rajaongkir/province_model.dart';
import 'package:riky/models/response_model.dart';
import 'package:riky/settings.dart';

class RajaOngkirController {
  String domainRajaOngkir = 'https://api.rajaongkir.com/starter';
  String apiKey = 'ef165bcc8d5ad0a263d07141004fa5c5';

  Future<Response> getProvince() async {
    Response apiresponse = Response();
    try {
      final response = await http.get(Uri.parse("$domainRajaOngkir/province"),
          headers: {
            'Accept': 'application/json',
            'key': apiKey
          }).timeout(Duration(seconds: ReqHttpSettings().timeOutDuration));

      switch (response.statusCode) {
        case 200:
          apiresponse.data = ProvinceRajaOngkirList.fromJson(
              jsonDecode(response.body)[RajaOngkir().payload]);
          break;
        case 401:
          apiresponse.error = jsonDecode(response.body)[RajaOngkir().payload]
              [RajaOngkir().status][RajaOngkir().messageStatus];
          break;
        case 400:
          apiresponse.error = jsonDecode(response.body)[RajaOngkir().payload]
              [RajaOngkir().status][RajaOngkir().messageStatus];
          break;
        default:
          apiresponse.error = somethingWentWrong;
          break;
      }
    } catch (err) {
      if (err is TimeoutException) {
        apiresponse.error = timeoutException;
      } else if (err is SocketException) {
        apiresponse.error = socketException;
      } else {
        apiresponse.error = serverError;
      }
    }

    return apiresponse;
  }

  Future<Response> getCity({required String provinceId}) async {
    Response apiresponse = Response();
    try {
      final response = await http.get(
          Uri.parse("$domainRajaOngkir/city?province=$provinceId"),
          headers: {
            'Accept': 'application/json',
            'key': apiKey
          }).timeout(Duration(seconds: ReqHttpSettings().timeOutDuration));

      switch (response.statusCode) {
        case 200:
          apiresponse.data = CityRajaOngkirList.fromJson(
              jsonDecode(response.body)[RajaOngkir().payload]);
          break;
        case 401:
          apiresponse.error = jsonDecode(response.body)[RajaOngkir().payload]
              [RajaOngkir().status][RajaOngkir().messageStatus];
          break;
        case 400:
          apiresponse.error = jsonDecode(response.body)[RajaOngkir().payload]
              [RajaOngkir().status][RajaOngkir().messageStatus];
          break;
        default:
          apiresponse.error = somethingWentWrong;
          break;
      }
    } catch (err) {
      if (err is TimeoutException) {
        apiresponse.error = timeoutException;
      } else if (err is SocketException) {
        apiresponse.error = socketException;
      } else {
        apiresponse.error = serverError;
      }
    }

    return apiresponse;
  }

Future<Response> checkOngkir(
      {required String cityOriginId,
      required String cityDestinationId,
      required int weight,
      required String courier}) async {
    Response apiresponse = Response();
    try {
      final response =
          await http.post(Uri.parse("$domainRajaOngkir/cost"), headers: {
        'Accept': 'application/json',
        'key': apiKey
      }, body: {
        'origin': cityOriginId,
        'destination': cityDestinationId,
        'weight': '$weight',
        'courier': courier,
      }).timeout(Duration(seconds: ReqHttpSettings().timeOutDuration));

      switch (response.statusCode) {
        case 200:
          apiresponse.data = CheckOngkirResponseList.fromJson(
              jsonDecode(response.body)[RajaOngkir().payload]);
          break;
        case 401:
          apiresponse.error = jsonDecode(response.body)[RajaOngkir().payload]
              [RajaOngkir().status][RajaOngkir().messageStatus];
          break;
        case 400:
          apiresponse.error = jsonDecode(response.body)[RajaOngkir().payload]
              [RajaOngkir().status][RajaOngkir().messageStatus];
          break;
        default:
          apiresponse.error = somethingWentWrong;
          break;
      }
    } catch (err) {
      if (err is TimeoutException) {
        apiresponse.error = timeoutException;
      } else if (err is SocketException) {
        apiresponse.error = socketException;
      } else {
        apiresponse.error = serverError;
      }
    }

    return apiresponse;
  }
}
