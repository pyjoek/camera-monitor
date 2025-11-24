import 'dart:async';
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

  late Future<List<dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();

    // 🔥 Refresh API every 1 minute
    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        futureData = fetchData();
      });
    });
  }

  // Fetch data from API
  Future<List<dynamic>> fetchData() async {
    const String baseUrl = "http://127.0.0.1:5000";
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // PAGE 1 — All cameras
  Widget buildAllCameras() {
    return FutureBuilder<List<dynamic>>(
      future: futureData,
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
                  Text(
                    'NVR: $nvrName',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...cameras.map<Widget>((camera) {
                    return Center(
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
    );
  }

  // PAGE 2 — Only offline cameras
  Widget buildOfflineCameras() {
    return FutureBuilder<List<dynamic>>(
      future: futureData,
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

              final offlineCameras = cameras
                  .where((camera) => camera['status'] == 'offline')
                  .toList();

              if (offlineCameras.isEmpty) return SizedBox.shrink();

              return Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    'NVR: $nvrName',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...offlineCameras.map<Widget>((camera) {
                    return Center(
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
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
                            Text("Status: ${camera['status']}",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
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
    );
  }

  // Navigation pages
  List<Widget> get _pages => <Widget>[
        buildAllCameras(),
        buildOfflineCameras(),
      ];

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
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Offline',
          ),
        ],
      ),
    );
  }
}
