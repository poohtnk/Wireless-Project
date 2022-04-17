import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

void main() => runApp(BookMark());

class BookMark extends StatelessWidget {
  const BookMark({Key? key}) : super(key: key);

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
  bool _loading = false;
  final List<MaterialColor> _colors = [
    Colors.blue,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.cyan
  ];

  Future<void> getCryptoPrices() async {
    List cryptoDatas = [];

    print('getting crypto prices');
    String _apiURL =
        "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=1,2";
    setState(() {
      this._loading = true;
    });
    http.Response response = await http.get(Uri.parse(_apiURL),
        headers: {"X-CMC_PRO_API_KEY": "cad1f66d-15f1-4a2e-8604-e7e4a62a5a1a"});

    Map<String, dynamic> responseJSON = json.decode(response.body);
    if (responseJSON["status"]["error_code"] == 0) {
      for (int i = 1; i <= responseJSON["data"].length; i++) {
        cryptoDatas.add(responseJSON["data"][i.toString()]);
      }
    }
    print(cryptoDatas);

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

  CircleAvatar _getLeadingWidget(String name, MaterialColor color) {
    return new CircleAvatar(
      backgroundColor: color,
      child: new Text(name[0]),
    );
  }

  _getMainBody() {
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Widget(
        body: _buildCryptoList(),
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
          title: Text('Bookmark'),
        ),
        body: _getMainBody());
  }

  Widget _buildCryptoList() {
    return ListView.builder(
        itemCount: _saved.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          final index = i;
          print(index);
          final MaterialColor color = _colors[index % _colors.length];
          return _buildRow(_saved.elementAt(index), color);
        });
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    final bool favourited = _saved.contains(crypto);
    print(_saved);

    void _fav() {
      setState(() {
        if (favourited) {
          _saved.remove(crypto);
        } else {
          _saved.add(crypto);
        }
      });
    }

    return ListTile(
      leading: _getLeadingWidget(crypto['name'], color),
      title: Text(crypto['name']),
      subtitle: Text(
        cryptoPrice(crypto),
        style: _boldStyle,
      ),
      trailing: new IconButton(
        icon: Icon(favourited ? Icons.favorite : Icons.favorite_border),
        color: favourited ? Colors.red : null,
        onPressed: _fav,
      ),
    );
  }
}
