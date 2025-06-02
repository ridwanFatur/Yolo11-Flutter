import 'package:flutter/material.dart';
import 'package:mobile_yolo/pages/capture_detect_page.dart';
import 'package:mobile_yolo/pages/live_detection_page.dart';
import 'package:mobile_yolo/pages/test_asset_page.dart';
import 'package:mobile_yolo/pages/test_camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveDetectionPage(),
                    ),
                  );
                },
                child: Text("Live Detection"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CaptureDetectPage(),
                    ),
                  );
                },
                child: Text("Capture and Detect"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TestAssetPage(),
                    ),
                  );
                },
                child: Text("Test Asset Image"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TestCameraPage(),
                    ),
                  );
                },
                child: Text("Test Camera Image"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
