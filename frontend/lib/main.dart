import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Monitor',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  double height = 0;
  double width = 0;
  // The pages you want to switch between
  List<Widget> get _pages => <Widget>[
    FutureBuilder<List<dynamic>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {          
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final List<dynamic> nvrs = snapshot.data!;

          return ListView(
            children: nvrs.map<Widget>((nvr) {
              final cameras = nvr['cameras'];
              final nvrName = nvr['NvrName'];

              return Column(
                children: [
                  SizedBox(height: 10),

                  // NVR title
                  Text(
                    'NVR: $nvrName',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  // Loop through cameras of this NVR
                  ...cameras.map<Widget>((camera) {
                    return Center(
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 0),
                              blurRadius: 3,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Camera Name: ${camera['CameraName']}"),
                            Text("IP: ${camera['ip']}"),
                            Text("Status: ${camera['status']}"),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );


        } else {
          return Center(child: Text('No data available'));
        }
      },
    ),
    FutureBuilder<List<dynamic>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {          
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          final cameras = data[0]['cameras'];
          final nvr = data[0]['NvrName'];

          return Column(
            children: [
              SizedBox(height: 10),
              ...cameras.map<Widget>((camera) {
                return Center(
                  child: Container(
                    height: height * 0.1,
                    width: width * 0.9,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 0),
                          blurRadius: 3,
                          color: Colors.black,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Camera Status: ${camera['status']}'),
                        Text('NVR: $nvr'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );

        } else {
          return Center(child: Text('No data available'));
        }
      },
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // create a function to fetch data from a given url
  Future<List<dynamic>> fetchData() async {
    const String baseUrl = "http://127.0.0.1:5000";
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Monitor'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
        ],
      ),
    );
  }
}