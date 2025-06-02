import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class ImageUtils {
  static Future<img.Image> convertXFileToImage(XFile xFile) async {
    final bytes = await xFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Error();
    }

    return image;
  }

  static img.Image convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final img.Image rgbImage = img.Image(width: width, height: height);

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    /** Precompute strides for Y, U, and V planes */
    final int yRowStride = image.planes[0].bytesPerRow;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        /** Calculate indices for Y, U, and V planes */
        final int yIndex = y * yRowStride + x;
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int Y = yPlane[yIndex] & 0xFF;
        final int U = (uPlane[uvIndex] & 0xFF) - 128;
        final int V = (vPlane[uvIndex] & 0xFF) - 128;

        /** YUV to RGB conversion (ITU-R BT.601 standard) */
        final double r = Y + 1.402 * V;
        final double g = Y - 0.344136 * U - 0.714136 * V;
        final double b = Y + 1.772 * U;

        /** Clamp values to [0, 255] and convert to integers */
        final int rInt = r.clamp(0, 255).toInt();
        final int gInt = g.clamp(0, 255).toInt();
        final int bInt = b.clamp(0, 255).toInt();

        /** Set pixel in RGB image (fully opaque) */
        rgbImage.setPixelRgba(x, y, rInt, gInt, bInt, 255);
      }
    }
    return rgbImage;
  }

  static List<dynamic> convertImageToArray(img.Image image) {
    List<dynamic> input = List.generate(
      1,
      (_) => List.generate(
        image.height,
        (_) => List.generate(image.width, (_) => List.generate(3, (_) => 0.0)),
      ),
    );

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    return input;
  }
}
