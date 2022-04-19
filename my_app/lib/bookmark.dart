import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
      home: BookmarkList(),
    );
  }
}

class BookmarkList extends StatefulWidget {
  @override
  BookmarkListState createState() => BookmarkListState();
}

class BookmarkListState extends State<BookmarkList> {
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
    return CircleAvatar(
      child: CachedNetworkImage(
        imageUrl: iconURL+sym+".png",
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, e, error) => 
          CircleAvatar(
            backgroundColor: _colors[symbol.length%(_colors.length-1)],
            child: Text(symbol[0]),
          ),
      ),
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
          // print(index);
          final MaterialColor color = _colors[index % _colors.length];
          return _buildRow(_saved.elementAt(index), color);
        });
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    final bool favourited = _saved.contains(crypto);
    // print(_saved);

    void _fav() {
      setState(() {
        if (favourited) {
          _saved.remove(crypto);
        } else {
          if (!_saved.contains(crypto)) {
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
            (crypto['quote']['USD']['percent_change_7d'] >= 0 ? "↑ UPTREND" : "↓ DOWNTREND"),
        style: crypto['quote']['USD']['percent_change_7d'] >= 0
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
