import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INITIALIZE NOTIFICATIONS
  AwesomeNotifications().initialize(
    null, // icon (null uses app icon)
    [
      NotificationChannel(
        channelKey: 'camera_alerts',
        channelName: 'Camera Alerts',
        channelDescription: 'Notifies when a camera goes offline',
        defaultColor: Colors.red,
        importance: NotificationImportance.Max,
        ledColor: Colors.white,
      )
    ],
  );

  // ASK PERMISSION
  bool allowed = await AwesomeNotifications().isNotificationAllowed();
  if (!allowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gold Zanzibar Camera Monitor',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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

    // Refresh every 5 minutes
    Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        futureData = fetchData();
      });
    });
  }

  // Fetch data from API and send notifications
  Future<List<dynamic>> fetchData() async {
    const String baseUrl = "http://10.0.2.2:5000";
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    // Always check & notify offline cameras (NO duplicate prevention)
    _checkForOfflineCameras(data);

    return data;
  }

  // 🔥 Always send notification for offline cameras
  void _checkForOfflineCameras(List<dynamic> nvrs) {
    for (var nvr in nvrs) {
      for (var camera in nvr['cameras']) {
        if (camera['status'] == 'offline') {
          _sendOfflineNotification(
            nvr['NvrName'],
            camera['CameraName'],
            camera['ip'],
          );
        }
      }
    }
  }

  // 🔔 Local notification
  void _sendOfflineNotification(String nvrName, String cameraName, String ip) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'camera_alerts',
        title: '⚠️ Camera Offline',
        body: '$cameraName ($ip) on $nvrName is OFFLINE',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // ------------------ UI Below ------------------

  Widget buildAllCameras() {
    return FutureBuilder<List<dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        final nvrs = snapshot.data!;

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
      },
    );
  }

  Widget buildOfflineCameras() {
    return FutureBuilder<List<dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        final nvrs = snapshot.data!;

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
      },
    );
  }

  List<Widget> get _pages => <Widget>[
        buildAllCameras(),
        buildOfflineCameras(),
      ];

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'All Cameras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.offline_bolt),
            label: 'Offline Cameras',
          ),
        ],
      ),
    );
  }
}
