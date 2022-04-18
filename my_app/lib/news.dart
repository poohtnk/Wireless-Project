import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() => runApp(News());

class News extends StatelessWidget {
  const News({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News List',
      theme: new ThemeData(primaryColor: Colors.white),
      home: NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  bool _loading = false;
  List<dynamic> _newsItems = [];

  Future<void> getNews() async {
    print('getting news');
    String newApi =
        "https://newsdata.io/api/1/news?apikey=pub_661967e1d5b736fe5ac367f1ad63e5cb77ad&q=crypto&country=us&category=business,technology,top";
    setState(() {
      this._loading = true;
    });
    http.Response response = await http.get(Uri.parse(newApi));

    String jsonResponse = response.body;
    Map<String, dynamic> news = jsonDecode(jsonResponse);
    // print(news);

    setState(() {
      this._newsItems = news['results'];
      this._loading = false;
    });
    return;
  }

  @override
  initState() {
    super.initState();
    getNews();
  }

  @override
  Widget build(BuildContext context) {
    var len = _newsItems.length;
    return Scaffold(
        appBar: AppBar(
          title: Text('News'),
        ),
        body: _loading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: 10,
                padding: const EdgeInsets.all(10.0),
                itemBuilder: (context, i) => Card(
                  key: ValueKey(_newsItems[i]),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: _newsItems[i]['link']));
                    },
                    child: Card(
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              opacity: 0.5,
                              image: NetworkImage(_newsItems[i]['image_url'] == null ? "https://newsdata.io/images/global/newsdata-social.png" : _newsItems[i]['image_url'] ),
                            )),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(_newsItems[i]['title'], style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      ),
                      margin:
                          EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0),
                    ),
                  ),
                ),
              ));
  }
}
