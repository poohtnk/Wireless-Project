import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import './models/chart_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ExtractArgumentsScreen.routeName: (context) =>
            const ExtractArgumentsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == PassArgumentsScreen.routeName) {
          final args = settings.arguments as ScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return PassArgumentsScreen(
                crypto: args.crypto,
                index: args.index,
              );
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      title: 'Cryto Reminder',
    );
  }
}

// A Widget that extracts the necessary arguments from
// the ModalRoute.
class ExtractArgumentsScreen extends StatelessWidget {
  const ExtractArgumentsScreen({Key? key}) : super(key: key);

  static const routeName = '/extractArguments';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.crypto[args.index]['name'].toUpperCase()),
      ),
      body: Center(
        child: Text(args.crypto[args.index]['name']),
      ),
    );
  }
}

class PassArgumentsScreen extends StatelessWidget {
  static const routeName = '/passArguments';

  final List<dynamic> crypto;
  final int index;

  const PassArgumentsScreen({
    Key? key,
    required this.crypto,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final msg = crypto[index];
    Random random = Random();
    // did random value since the api did provide real time data, will find api that provides it (possible improvement)
    int next(int min, int max) => random.nextInt(max - min);
    var iconURL =
        "https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/128/color/";
    DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        .parse(msg['quote']['USD']['last_updated']);
    var mdgDate = DateTime.parse(parseDate.toString());
    var dateFormat = DateFormat('MM/dd/yyyy hh:mm a');
    var finalDate = dateFormat.format(mdgDate);
    var chart = [
      ChartData(next(100, 130), 1),
      ChartData(next(7, 41), 2),
      ChartData(next(30, 90), 3),
      ChartData(msg['quote']['USD']['percent_change_24h'], 4),
      ChartData(msg['quote']['USD']['percent_change_1h'], 5),
      ChartData(next(10, 40), 6),
      ChartData(next(90, 120), 7),
      ChartData(next(10, 20), 8),
      ChartData(msg['quote']['USD']['percent_change_24h'], 9),
      ChartData(msg['quote']['USD']['percent_change_1h'], 10),
      ChartData(next(10, 40), 12),
      ChartData(next(90, 130), 13),
      ChartData(msg['quote']['USD']['percent_change_24h'], 14),
      ChartData(next(90, 140), 15),
      ChartData(next(10, 20), 16),
      ChartData(msg['quote']['USD']['percent_change_24h'], 17),
      ChartData(msg['quote']['USD']['percent_change_1h'], 18),
      ChartData(next(110, 140), 19),
      ChartData(next(20, 41), 20),
      ChartData(next(240, 300), 21),
      ChartData(msg['quote']['USD']['percent_change_1h'], 22),
      ChartData(next(120, 140), 23),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(crypto[index]['name'].toUpperCase()),
      ),
      body: Container(
        height: 700,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: CategoryAxis(isVisible: false),
                legend: Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: false),
                series: <ChartSeries<ChartData, String>>[
                  LineSeries<ChartData, String>(
                    dataSource: chart,
                    xValueMapper: (ChartData sales, _) => sales.time.toString(),
                    yValueMapper: (ChartData sales, _) => sales.value,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 400.0,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Circulating Supply: ",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        msg['circulating_supply'].toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Max Supply: ",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        msg['max_supply'].toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Market pairs: ",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        msg['num_market_pairs'].toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Market Cap: ",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        msg['quote']['USD']['market_cap'].toStringAsFixed(2),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenArguments {
  final List<dynamic> crypto;
  final int index;

  ScreenArguments(this.crypto, this.index);
}
