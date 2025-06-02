import 'package:flutter/material.dart';
import 'package:mobile_yolo/utils/yolo_post_processor.dart';

class DetectionBoxWidget extends StatelessWidget {
  final List<DetectionBox> boxes;
  const DetectionBoxWidget({super.key, required this.boxes});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          boxes.expand((box) {
            return [
              Positioned(
                left: box.x,
                top: box.y - 16,
                child: Container(
                  color: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    "${box.label} ${(box.confidence * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
              Positioned(
                left: box.x,
                top: box.y,
                child: Container(
                  width: box.width,
                  height: box.height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                ),
              ),
            ];
          }).toList(),
    );
  }
}
