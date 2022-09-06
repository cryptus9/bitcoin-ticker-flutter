import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_key.dart';

class NetworkHelper {
  // https://rest.coinapi.io/v1/exchangerate/BTC?filter_asset_id=USD,EUR
  // https://rest.coinapi.io/v1/exchangerate/BTC/USD

  static const String authority = 'rest.coinapi.io';
  static const String unencoded_path = 'v1/exchangerate/';

  Future<ExchangeRate> getExchangereateByCurrencyId(String baseID, quoteId) {
    Uri uri = Uri.https(authority,
        unencoded_path + baseID + '/' + quoteId + '/', {"apikey": API_KEY});
    print(uri);
    return http.get(uri).then((response) {
      if (response.statusCode == 200) {
        return _mapResponse(response);
      } else {
        throw new HttpException(response.statusCode.toString());
      }
    });
  }

  ExchangeRate _mapResponse(http.Response response) {
    var data = jsonDecode(response.body);
    return ExchangeRate(
        assetIdBase: data['asset_id_base'],
        assetIdQuote: data['asset_id_quote'],
        rate: data['rate'],
        timestamp: data['time']);
  }
}

// "time": "2017-08-09T14:31:18.3150000Z",
// "asset_id_base": "BTC",
// "asset_id_quote": "USD",
// "rate": 3260.3514321215056208129867667

class ExchangeRate {
  final String timestamp;
  final String assetIdBase;
  final String assetIdQuote;
  final double rate;

  ExchangeRate({
    @required this.timestamp,
    @required this.assetIdBase,
    @required this.assetIdQuote,
    @required this.rate,
  });
}
