import 'dart:math';

import 'package:mobile_yolo/constants.dart';

class DetectionBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String label;
  final double confidence;

  DetectionBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
    required this.confidence,
  });
}

class YoloPostProcessor {
  static List<int> customNms(
    List<List<double>> boxes,
    List<double> scores,
    double confThreshold,
    double iouThreshold,
  ) {
    /** Filter by confidence threshold */
    List<int> validIndices = [];
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] >= confThreshold) {
        validIndices.add(i);
      }
    }

    if (validIndices.isEmpty) {
      return [];
    }

    /** Sort by scores in descending order */
    List<int> indices = List.from(validIndices)
      ..sort((a, b) => scores[b].compareTo(scores[a]));
    List<List<double>> filteredBoxes = [for (int i in indices) boxes[i]];

    List<int> keepIndices = [];

    while (indices.isNotEmpty) {
      /** Pick the box with the highest score */
      int currentIdx = indices[0];
      keepIndices.add(currentIdx);

      if (indices.length == 1) {
        break;
      }

      /** Compute IoU between the current box and all others */
      List<double> currentBox = filteredBoxes[0];
      List<List<double>> otherBoxes = filteredBoxes.sublist(1);
      List<int> otherIndices = indices.sublist(1);

      /** Calculate IoU */
      List<double> ious = [];
      for (var otherBox in otherBoxes) {
        /** Intersection coordinates */
        double x1 = max(currentBox[0], otherBox[0]);
        double y1 = max(currentBox[1], otherBox[1]);
        double x2 = min(currentBox[2], otherBox[2]);
        double y2 = min(currentBox[3], otherBox[3]);

        /** Intersection area */
        double w = max(0, x2 - x1);
        double h = max(0, y2 - y1);
        double intersection = w * h;

        /** Union area */
        double currentArea =
            (currentBox[2] - currentBox[0]) * (currentBox[3] - currentBox[1]);
        double otherArea =
            (otherBox[2] - otherBox[0]) * (otherBox[3] - otherBox[1]);
        double union = currentArea + otherArea - intersection;

        /** Compute IoU */
        double iou = union > 0 ? intersection / union : 0;
        ious.add(iou);
      }

      /** Keep boxes with IoU below threshold */
      List<int> newIndices = [];
      List<List<double>> newBoxes = [];
      for (int i = 0; i < ious.length; i++) {
        if (ious[i] <= iouThreshold) {
          newIndices.add(otherIndices[i]);
          newBoxes.add(otherBoxes[i]);
        }
      }

      indices = newIndices;
      filteredBoxes = newBoxes;
    }

    return keepIndices;
  }

  static (List<List<double>>, List<double>, List<int>) postprocessOutput(
    List<dynamic> output,
  ) {
    double confThreshold = 0.25;
    double iouThreshold = 0.45;
    int numClasses = 80;

    /** Transpose output from [1, 84, 8400] to [1, 8400, 84] */
    List<List<List<double>>> transposed = List.generate(
      1,
      (_) => List.generate(
        output[0][0].length,
        (i) =>
            List.generate(output[0].length, (j) => output[0][j][i] as double),
      ),
    );

    List<List<double>> boxes = [];
    List<double> scores = [];
    List<int> classes = [];

    /** Process each detection */
    for (var detection in transposed[0]) {
      /** Extract class probabilities and find max */
      List<double> classProbs = detection.sublist(4, 4 + numClasses);
      int classId = 0;
      double maxProb = classProbs[0];
      for (int i = 1; i < classProbs.length; i++) {
        if (classProbs[i] > maxProb) {
          maxProb = classProbs[i];
          classId = i;
        }
      }
      double confidence = maxProb;

      if (confidence > confThreshold) {
        /** Bounding box: center_x, center_y, width, height */
        double centerX = detection[0];
        double centerY = detection[1];
        double width = detection[2];
        double height = detection[3];

        /** Convert to pixel coordinates (x_min, y_min, x_max, y_max) */
        double xMin = (centerX - width / 2) * 640;
        double yMin = (centerY - height / 2) * 640;
        double xMax = (centerX + width / 2) * 640;
        double yMax = (centerY + height / 2) * 640;

        boxes.add([xMin, yMin, xMax, yMax]);
        scores.add(confidence);
        classes.add(classId);
      }
    }

    /** Apply Non-Maximum Suppression */
    List<int> indices = customNms(boxes, scores, confThreshold, iouThreshold);

    /** Filter results */
    List<List<double>> finalBoxes = [for (int i in indices) boxes[i]];
    List<double> finalScores = [for (int i in indices) scores[i]];
    List<int> finalClasses = [for (int i in indices) classes[i]];

    return (finalBoxes, finalScores, finalClasses);
  }

  static List<DetectionBox> getDetectionBoxes(
    List<dynamic> output,
    double imageWidth,
    double imageHeight,
  ) {
    List<DetectionBox> boxes = [];
    List<List<double>>? detectedBoxes;
    List<double>? detectedScores;
    List<int>? detectedClasses;
    (detectedBoxes, detectedScores, detectedClasses) = postprocessOutput(
      output,
    );

    for (int i = 0; i < detectedBoxes.length; i++) {
      final detectedBox = detectedBoxes[i];
      final detectedScore = detectedScores[i];
      final detectedClass = detectedClasses[i];

      final scaleX = imageWidth / ModelConstants.inputSize;
      final scaleY = imageHeight / ModelConstants.inputSize;

      final xMin = detectedBox[0] * scaleX;
      final yMin = detectedBox[1] * scaleY;
      final xMax = detectedBox[2] * scaleX;
      final yMax = detectedBox[3] * scaleY;

      final double x = xMin;
      final double y = yMin;
      final double width = xMax - xMin;
      final double height = yMax - yMin;

      final box = DetectionBox(
        x: x,
        y: y,
        width: width,
        height: height,
        label: CocoClassNames.values[detectedClass],
        confidence: detectedScore,
      );

      boxes.add(box);
    }
    return boxes;
  }
}
