import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/saves_screen/saves_screen.dart';
import 'screens/resource_screen/resource_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'screens/saves_screen/shared_url_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // final IOSInitializationSettings initializationSettingsIOS =
  //     IOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize SharedUrlHandler only once
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     SharedUrlHandler.listenForSharedUrls(context);
  //   });
  // }

  // @override
  // void dispose() {
  //   SharedUrlHandler.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saves App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SavesScreen(
            firestore: firestore,
            notificationsPlugin: flutterLocalNotificationsPlugin),
        '/resource_screen': (context) => ResourceScreen(
            docId: ModalRoute.of(context)?.settings.arguments as String),
      },
    );
  }
}
