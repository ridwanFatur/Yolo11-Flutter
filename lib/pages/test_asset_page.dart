import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_yolo/constants.dart';
import 'package:mobile_yolo/utils/image_utils.dart';
import 'package:mobile_yolo/utils/utils.dart';
import 'package:mobile_yolo/utils/yolo_post_processor.dart';
import 'package:mobile_yolo/widgets/detection_box_widget.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TestAssetPage extends StatefulWidget {
  const TestAssetPage({super.key});

  @override
  State<TestAssetPage> createState() => _TestAssetPageState();
}

class _TestAssetPageState extends State<TestAssetPage> {
  /// Screen size
  final GlobalKey containerKey = GlobalKey();
  double imageWidth = 0;
  double imageHeight = 400;

  /// Inference thingy
  late Interpreter interpreter;
  List<DetectionBox> boxes = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          containerKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      imageWidth = size.width;
      runInference();
    });
  }

  void runInference() async {
    /** Load Model */
    interpreter = await Interpreter.fromAsset(AssetConstants.modelPath);

    /** Input */
    final byteData = await rootBundle.load(AssetConstants.exampleImagePath);
    final Uint8List imageBytes = byteData.buffer.asUint8List();
    final img.Image? originImage = img.decodeImage(imageBytes);
    if (originImage == null) throw Exception("Failed to decode image");
    final img.Image resizedImage = img.copyResize(
      originImage,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Asset Page")),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Colors.amber,
                width: double.infinity,
                height: imageHeight,
                key: containerKey,
                child: Stack(
                  children: [
                    Image.asset(
                      AssetConstants.exampleImagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.fill,
                    ),
                    DetectionBoxWidget(boxes: boxes),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
