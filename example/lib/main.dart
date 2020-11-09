import 'package:example/math_graph_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'egg_timer_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geometry | SuperDeclarative!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _Page _page = _Page.mathGraph;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Geometry',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    switch (_page) {
      case _Page.mathGraph:
        return MathGraphPage();
      case _Page.eggTimer:
        return EggTimerPage();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DrawerHeader(
                    child: SizedBox.expand(
                      child: Column(
                        children: [
                          Spacer(),
                          Image.asset(
                            'assets/logo_mascot_icon.png',
                            height: 75,
                          ),
                          Spacer(flex: 2),
                          Text(
                            'DEMOS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                    ),
                  ),
                  ListTile(
                    title: Text('Math Graph'),
                    selected: _page == _Page.mathGraph,
                    onTap: () {
                      setState(() {
                        _page = _Page.mathGraph;
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                  ListTile(
                    title: Text('Egg Timer'),
                    selected: _page == _Page.eggTimer,
                    onTap: () {
                      setState(() {
                        _page = _Page.eggTimer;
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Want to support this project?',
                ),
                FlatButton(
                  onPressed: () {
                    launch('https://donate.superdeclarative.com');
                  },
                  child: Text('Donate to SuperDeclarative!'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _Page {
  eggTimer,
  mathGraph,
}
