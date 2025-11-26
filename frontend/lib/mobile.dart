import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Notifications plugin
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android notification settings
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(initSettings);

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
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  double height = 0;
  double width = 0;

  late Future<List<dynamic>> futureData;

  // Map to track last notification time per camera
  Map<int, DateTime> lastNotified = {};

  @override
  void initState() {
    super.initState();
    futureData = fetchData();

    // Auto-refresh every 10 seconds
    Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        futureData = fetchData();
      });
    });
  }

  /// Show notification for an offline camera
  Future<void> showOfflineNotification(String cameraName) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'camera_channel',
      'Camera Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      'Camera Offline!',
      '$cameraName is still offline.',
      details,
    );
  }

  /// Fetch data from API
  Future<List<dynamic>> fetchData() async {
    const String baseUrl = "http://127.0.0.1:5000";
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // PAGE 1 — all cameras
  Widget buildAllCameras() {
    return FutureBuilder<List<dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

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
                  final id = camera['id'];
                  final status = camera['status'];
                  final now = DateTime.now();

                  if (status == 'offline') {
                    // If never notified OR 2 minutes have passed → notify again
                    if (!lastNotified.containsKey(id) ||
                        now.difference(lastNotified[id]!).inMinutes >= 2) {
                      showOfflineNotification(camera['CameraName']);
                      lastNotified[id] = now;
                    }
                  } else {
                    // Camera is online → reset notification tracking
                    lastNotified.remove(id);
                  }

                  return Center(
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: status == 'offline'
                            ? Colors.red.shade100
                            : Colors.white,
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
                          Text(
                            "Status: $status",
                            style: TextStyle(
                                color: status == 'offline'
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
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

  // PAGE 2 — Only offline cameras
  Widget buildOfflineCameras() {
    return FutureBuilder<List<dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final List<dynamic> nvrs = snapshot.data!;

        return ListView(
          children: nvrs.map<Widget>((nvr) {
            final cameras = nvr['cameras'];
            final nvrName = nvr['NvrName'];

            final offlineCameras =
                cameras.where((c) => c['status'] == 'offline').toList();

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
                          Text(
                            "Status: Offline",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
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
            label: 'All Cameras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Offline Only',
          ),
        ],
      ),
    );
  }
}
