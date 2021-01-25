import 'package:flutter/material.dart';
import 'custom_proxy.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

const enableProxy = true; //TODO: Add to a config/env var/UI
const ipAddress =
    "10.0.2.2"; //10.0.2.2 is the loopback address for localhost in the Android emulator
const port = 38888; //Alkami proxy port
const allowBadCertificates = true;

void main() {
  if (enableProxy) {
    final proxy = CustomProxy(
        ipAddress: ipAddress,
        port: port,
        allowBadCertificates: allowBadCertificates);
    proxy.enable();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Books Searcher Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Google Books Searcher Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _bookCount = 0;
  String _searchPhrase = "";
  String _imageUrl = '';
  String _title = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5,
            decoration: const InputDecoration(
              hintText: 'Enter a search phrase',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a search phrase';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _searchPhrase = value;
              });
            },
          ),
          Text(
            '$_bookCount books matching "$_searchPhrase"',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Center(
            child: bookImage(),
            heightFactor: 1.2,
          ),
          Text(
            _title,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getBookData(_searchPhrase);
        },
        tooltip: 'Search',
        child: Icon(Icons.search),
      ),
    );
  }

  Widget bookImage() => (_imageUrl != '')
      ? Image.network(
          _imageUrl,
          scale: .75,
        )
      : null;

  Future getBookData(String searchPhrase) async {
    String url = 'https://www.googleapis.com/books/v1/volumes?q=$searchPhrase';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        _bookCount = jsonResponse['totalItems'];
        _imageUrl =
            jsonResponse['items'][0]['volumeInfo']['imageLinks']['thumbnail'];
        _title = jsonResponse['items'][0]['volumeInfo']['title'];
      });
      print(
          'Number of books matching search phrase "$_searchPhrase: $_bookCount."');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
