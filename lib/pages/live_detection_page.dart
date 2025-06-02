import 'package:flutter/material.dart';
import 'package:mobile_yolo/constants.dart';
import 'package:camera/camera.dart';
import 'package:mobile_yolo/utils/image_utils.dart';
import 'package:mobile_yolo/utils/utils.dart';
import 'package:mobile_yolo/utils/yolo_post_processor.dart';
import 'package:mobile_yolo/widgets/detection_box_widget.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class LiveDetectionPage extends StatefulWidget {
  const LiveDetectionPage({super.key});

  @override
  State<LiveDetectionPage> createState() => _LiveDetectionPageState();
}

class _LiveDetectionPageState extends State<LiveDetectionPage> {
  /// Screen size
  final GlobalKey containerKey = GlobalKey();
  double imageWidth = 0;
  double imageHeight = 0;

  /// Inference thingy
  late Interpreter interpreter;
  bool isDetecting = false;
  DateTime? lastInference;
  List<DetectionBox> boxes = [];

  /// Camera
  CameraController? cameraController;

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

    cameraController!.startImageStream((CameraImage image) async {
      if (!isDetecting &&
          (lastInference == null ||
              DateTime.now().difference(lastInference!).inSeconds >= 5)) {
        isDetecting = true;
        lastInference = DateTime.now();
        runInference(image);
      }
    });

    setState(() {});
  }

  Future<void> runInference(CameraImage image) async {
    /** Input */
    final convertedImage = ImageUtils.convertYUV420ToImage(image);
    img.Image rotatedImage = img.copyRotate(convertedImage, angle: 90);

    /** For Front Camera */
    // img.Image rotatedImage = img.copyRotate(convertedImage, angle: 270);
    // final img.Image flippedImage = img.flipHorizontal(rotatedImage);

    final img.Image resizedImage = img.copyResize(
      rotatedImage,
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
    isDetecting = false;
    boxes = List.from(newBoxes);
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
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(cameraController!),
        ),
        DetectionBoxWidget(boxes: boxes),
      ],
    );
  }
}
