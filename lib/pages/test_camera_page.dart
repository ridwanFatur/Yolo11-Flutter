import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_yolo/utils/image_utils.dart';
import 'package:image/image.dart' as img;

class TestCameraPage extends StatefulWidget {
  const TestCameraPage({super.key});

  @override
  State<TestCameraPage> createState() => _TestCameraPageState();
}

class _TestCameraPageState extends State<TestCameraPage> {
  /// Camera
  CameraController? cameraController;
  img.Image? capturedImage;
  DateTime? lastStream;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeCamera();
    });
  }

  Future<void> initializeCamera() async {
    /** Camera */
    final cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await cameraController!.initialize();

    cameraController!.startImageStream((CameraImage image) async {
      if (lastStream == null ||
          DateTime.now().difference(lastStream!).inSeconds >= 5) {
        lastStream = DateTime.now();
        final convertedImage = ImageUtils.convertYUV420ToImage(image);
        img.Image rotatedImage = img.copyRotate(convertedImage, angle: 90);
        setState(() {
          capturedImage = rotatedImage;
        });
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    /** Stop the image stream and dispose of the camera controller */
    cameraController?.stopImageStream();
    cameraController?.dispose();
    cameraController = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera Page")),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blue,
          child: body(),
        ),
      ),
    );
  }

  Widget body() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    }

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(cameraController!),
        ),
        if (capturedImage != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.memory(
                Uint8List.fromList(img.encodePng(capturedImage!)),
                fit: BoxFit.fill,
              ),
            ),
          ),
      ],
    );
  }
}
