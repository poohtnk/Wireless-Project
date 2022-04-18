import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

import './models/chart_model.dart';

void main() {
  runApp(const Search());
}

class Search extends StatelessWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Search',
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _cryptoList = [];
  bool _loading = false;
  final _percentUP =
      new TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade400);
  final _percentDOWN =
      new TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade300);
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
      _cryptoList = cryptoDatas;
      _foundCrypto = _cryptoList;
      _loading = false;
    });
    return;
  }

  List<dynamic> _foundCrypto = [];
  @override
  initState() {
    super.initState();
    getCryptoPrices();
  }

  void _applyFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = _cryptoList;
    } else {
      results = _cryptoList
          .where((crypto) => crypto["name"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundCrypto = results;
    });
  }

  String cryptoPrice(Map crypto) {
    int decimals = 2;
    num fac = pow(10, decimals);
    double d = (crypto['quote']['USD']['price']);
    return "\$" + (d = (d * fac).round() / fac).toString();
  }

  CircleAvatar _getLeadingWidget(int index) {
    var sym = _foundCrypto[index]['symbol'].toLowerCase().toString();
    return new CircleAvatar(
      child: Image.network(iconURL + sym + ".png"),
    );
  }

  Container _crpytoGraph(int index) {
    double price = _foundCrypto[index]['quote']['USD']['price'];
    print("a $price");
    List<ChartData> data = [
      ChartData(_foundCrypto[index]['quote']['USD']['percent_change_30d'], 1440),
      ChartData(_foundCrypto[index]['quote']['USD']['percent_change_7d'], 720),
      ChartData(_foundCrypto[index]['quote']['USD']['percent_change_24h'],24),
      ChartData( _foundCrypto[index]['quote']['USD']['percent_change_1h'],1),
    ];
    return Container(
      height: 75,
      width: 130,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(isVisible: false),
        primaryYAxis: CategoryAxis(isVisible: false),
        legend: Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: false),
        series: <ChartSeries<ChartData, String>>[
          LineSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData sales, _) => sales.time.toString(),
            yValueMapper: (ChartData sales, _) => sales.value,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            TextField(
              onChanged: (searchKey) => _applyFilter(searchKey),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: _foundCrypto.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundCrypto.length,
                      itemBuilder: (context, index) => Card(
                        key: ValueKey(_foundCrypto[index]["id"]),
                        child: ListTile(
                          leading: _getLeadingWidget(index),
                          trailing: _crpytoGraph(index),
                          title: Text(_foundCrypto[index]['name']),
                          subtitle: Text(
                            cryptoPrice(_foundCrypto[index]) +
                                "\n" +
                                (_foundCrypto[index]['quote']['USD']
                                            ['percent_change_1h'] >=
                                        0
                                    ? "↑ "
                                    : "↓ ") +
                                (_foundCrypto[index]['quote']['USD']
                                        ['percent_change_1h'])
                                    .toStringAsFixed(2) +
                                " %",
                            style: _foundCrypto[index]['quote']['USD']
                                        ['percent_change_1h'] >=
                                    0
                                ? _percentUP
                                : _percentDOWN,
                          ),
                        ),
                      ),
                    )
                  : _loading
                      ? new Center(
                          child: new CircularProgressIndicator(),
                        )
                      : const Text(
                          'No results found',
                          style: TextStyle(fontSize: 24),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
