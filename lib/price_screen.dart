import 'package:bitcoin_ticker/coin_data.dart';
import 'package:bitcoin_ticker/network/network_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String _selectedValue = currenciesList.first;
  Map<String, String> exchangeRates = {'BTC': '?', 'ETH': '?', 'LTC': '?'};

  NotificationListener<ScrollNotification> iOSPicker() {
    List<Text> menuItems = [];
    currenciesList.forEach((element) {
      menuItems.add(
        Text(element),
      );
    });

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          this._getExchangeRate();
          return true;
        } else {
          return false;
        }
      },
      child: CupertinoPicker(
        itemExtent: 30.0,
        children: menuItems,
        onSelectedItemChanged: (index) {
          setState(() {
            this._selectedValue = currenciesList[index];
          });
        },
      ),
    );
  }

  DropdownButton<String> androidPicker() {
    List<DropdownMenuItem<String>> menuItems = [];
    currenciesList.forEach((element) {
      menuItems.add(DropdownMenuItem(
        child: Text(element),
        value: element,
      ));
    });

    return DropdownButton<String>(
        value: _selectedValue,
        items: menuItems,
        onChanged: (value) {
          setState(() {
            this._selectedValue = value;
            this._getExchangeRate();
          });
        });
  }

  List<Widget> createPriceBoxes() {
    List<Widget> boxes = [];
    this.exchangeRates.keys.forEach((element) {
      boxes.add(
        Padding(
          padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
          child: Card(
            color: Colors.lightBlueAccent,
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
              child: Text(
                '1 $element = ${exchangeRates[element]} $_selectedValue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    });
    return boxes;
  }

  @override
  void initState() {
    _getExchangeRate();
  }

  void _getExchangeRate() {
    exchangeRates.keys.forEach((element) {
      NetworkHelper()
          .getExchangereateByCurrencyId(element, this._selectedValue)
          .then((exchangeRate) {
        setState(() {
          this
              .exchangeRates
              .update(element, (value) => exchangeRate.rate.toStringAsFixed(2));
        });
      })
      .catchError((e) {
        print(e);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: this.createPriceBoxes(),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidPicker(),
          ),
        ],
      ),
    );
  }
}
