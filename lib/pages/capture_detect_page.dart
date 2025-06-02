import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile_yolo/constants.dart';
import 'package:mobile_yolo/utils/image_utils.dart';
import 'package:mobile_yolo/utils/utils.dart';
import 'package:mobile_yolo/utils/yolo_post_processor.dart';
import 'package:mobile_yolo/widgets/detection_box_widget.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CaptureDetectPage extends StatefulWidget {
  const CaptureDetectPage({super.key});

  @override
  State<CaptureDetectPage> createState() => _CaptureDetectPageState();
}

class _CaptureDetectPageState extends State<CaptureDetectPage> {
  /// Screen size
  final GlobalKey containerKey = GlobalKey();
  double imageWidth = 0;
  double imageHeight = 0;

  /// Inference thingy
  late Interpreter interpreter;
  List<DetectionBox> boxes = [];

  /// Camera
  CameraController? cameraController;
  img.Image? capturedImage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          containerKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      imageWidth = size.width;
      imageHeight = size.height;
      initializeCamera();
    });
  }

  Future<void> initializeCamera() async {
    /** Load Model */
    interpreter = await Interpreter.fromAsset(AssetConstants.modelPath);

    /** Camera */
    final cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await cameraController!.initialize();

    setState(() {});
  }

  Future<void> captureAndRunInference() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    try {
      final XFile imageFile = await cameraController!.takePicture();
      final image = await ImageUtils.convertXFileToImage(imageFile);

      /** For Front Camera */
      // final img.Image flippedImage = img.flipHorizontal(image);

      setState(() {
        capturedImage = image;
      });
      await runInference(image);
    } catch (e) {
      /** pass */
    }
  }

  Future<void> runInference(img.Image image) async {
    /** Input */
    final img.Image resizedImage = img.copyResize(
      image,
      width: ModelConstants.inputSize,
      height: ModelConstants.inputSize,
    );
    final input = ImageUtils.convertImageToArray(resizedImage);

    /** Output */
    List<dynamic> output = Utils.createOutputPlaceholder();
    interpreter.run(input, output);
    List<DetectionBox> newBoxes = YoloPostProcessor.getDetectionBoxes(
      output,
      imageWidth,
      imageHeight,
    );

    /** Update State */
    boxes = List.from(newBoxes);
    setState(() {});
  }

  @override
  void dispose() {
    /** Stop the image stream and dispose of the camera controller */
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
          key: containerKey,
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
        capturedImage == null
            ? SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(cameraController!),
            )
            : SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.memory(
                Uint8List.fromList(img.encodePng(capturedImage!)),
                fit: BoxFit.fill,
              ),
            ),
        DetectionBoxWidget(boxes: boxes),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                if (capturedImage == null) {
                  captureAndRunInference();
                } else {
                  setState(() {
                    boxes = [];
                    capturedImage = null;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text(
                capturedImage == null ? "Take Picture" : "Back",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
