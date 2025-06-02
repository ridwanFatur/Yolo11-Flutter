import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_yolo/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /** Set Potrait Up */
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Yolo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
