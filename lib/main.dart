import 'package:flutter/material.dart';
import 'custom_proxy.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

const enableProxy = true; //TODO: Convert

void main() {
  if (enableProxy) {
    // For Android devices you can also allowBadCertificates: true below, but you should ONLY do this when !kReleaseMode
    final proxy = CustomProxy(
        ipAddress: "10.0.2.2", port: 38888, allowBadCertificates: true);
    proxy.enable();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Google Books Searcher Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Invoke "debug painting" (press "p" in the console, choose the
        // "Toggle Debug Paint" action from the Flutter Inspector in Android
        // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
        // to see the wireframe for each widget.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
    // Await the http get response, then decode the json-formatted response.
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
