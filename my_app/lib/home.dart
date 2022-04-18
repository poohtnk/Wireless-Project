import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

void main() => runApp(MyList());

class MyList extends StatelessWidget {
  const MyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price List',
      theme: new ThemeData(primaryColor: Colors.white),
      home: CryptoList(),
    );
  }
}

class CryptoList extends StatefulWidget {
  @override
  CryptoListState createState() => CryptoListState();
}

class CryptoListState extends State<CryptoList> {
  List _cryptoList = [];
  final _saved = savedList.savedGlobal;
  final _boldStyle = new TextStyle(fontWeight: FontWeight.bold);
  final _percentUP =
      new TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade400);
  final _percentDOWN =
      new TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade300);
  bool _loading = false;
  final List<MaterialColor> _colors = [
    Colors.blue,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.cyan
  ];
  final String iconURL =
      "https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/";

  Future<void> getCryptoPrices() async {
    List cryptoDatas = [];

    print('getting crypto prices');
    String _apiURL =
        "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=8";
    setState(() {
      this._loading = true;
    });
    http.Response response = await http.get(Uri.parse(_apiURL),
        headers: {"X-CMC_PRO_API_KEY": "cad1f66d-15f1-4a2e-8604-e7e4a62a5a1a"});

    Map<String, dynamic> responseJSON = json.decode(response.body);
    if (responseJSON["status"]["error_code"] == 0) {
      for (int i = 0; i < responseJSON["data"].length; i++) {
        cryptoDatas.add(responseJSON["data"][i]);
      }
    }
    // print(cryptoDatas);

    setState(() {
      this._cryptoList = cryptoDatas;
      this._loading = false;
    });
    return;
  }

  String cryptoPrice(Map crypto) {
    int decimals = 2;
    num fac = pow(10, decimals);
    double d = (crypto['quote']['USD']['price']);
    return "\$" + (d = (d * fac).round() / fac).toString();
  }

  CircleAvatar _getLeadingWidget(String symbol) {
    var sym = symbol.toLowerCase().toString();
    return new CircleAvatar(
      child: Image.network(iconURL + sym + ".png"),
    );
  }

  _getMainBody() {
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new RefreshIndicator(
        child: _buildCryptoList(),
        onRefresh: getCryptoPrices,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCryptoPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('CryptoList'),
        ),
        body: _getMainBody());
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (crypto) {
              return new ListTile(
                leading: _getLeadingWidget(crypto['symbol']),
                title: Text(crypto['name']),
                subtitle: Text(
                  cryptoPrice(crypto),
                  style: _boldStyle,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Saved Cryptos'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildCryptoList() {
    return ListView.builder(
        itemCount: _cryptoList.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          final index = i;
          print(index);
          final MaterialColor color = _colors[index % _colors.length];
          return _buildRow(_cryptoList[index], color);
        });
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    var favourited = false;
    _saved.forEach((element) {
      if (element['id'] == crypto['id']) {
        favourited = true;
      }
    });

    void _fav() {
      setState(() {
        Map<dynamic, dynamic> temp = {};
        if (favourited) {
          _saved.forEach((element) {
            if (element['id'] == crypto['id']) {
              favourited = false;
              temp = element;
            }
          });
          if (!favourited) {
            _saved.remove(temp);
          }
        } else {
          var dup = false;
          _saved.forEach((element) {
            if (element['id'] == crypto['id']) {
              dup = true;
            }
          });
          if (!dup) {
            _saved.add(crypto);
          }
        }
      });
    }

    return ListTile(
      leading: _getLeadingWidget(crypto['symbol']),
      title: Text(crypto['name']),
      subtitle: Text(
        cryptoPrice(crypto) +
            "\n" +
            (crypto['quote']['USD']['percent_change_1h'] >= 0 ? "↑ " : "↓ ") +
            (crypto['quote']['USD']['percent_change_1h']).toStringAsFixed(2) +
            " %",
        style: crypto['quote']['USD']['percent_change_1h'] >= 0
            ? _percentUP
            : _percentDOWN,
      ),
      trailing: new IconButton(
        icon: Icon(favourited ? Icons.favorite : Icons.favorite_border),
        color: favourited ? Colors.red : null,
        onPressed: _fav,
      ),
    );
  }
}
