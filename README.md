# Flutter YOLO11 TFLite Demo

A mobile Flutter project using [YOLO11](https://github.com/ultralytics/ultralytics) model with TFLite, specifically `yolo11n_float32.tflite`.  
This project demonstrates image detection capabilities through 4 different pages.

## 📦 Model
- Model used: `yolo11n_float32.tflite`
- Source: Converted from YOLO11 by [Ultralytics](https://github.com/ultralytics/ultralytics)

## 📱 Pages Overview

### 1. Test Asset Image
- Purpose: To validate the model by comparing inference results on a predefined image (`image1`) against expected results from Jupyter Notebook.
- Reference: [Jupyter Notebook YOLO11 repo](https://github.com/ridwanFatur/Yolo11-Jupyter-Notebook)

### 2. Test Camera Stream
- Purpose: To test camera orientation, rotation, and flip.
- It helps ensure the camera stream is correctly aligned before running inference.

### 3. Capture and Detect (Single Inference)
- Take a picture → Run model inference on that image.
- Not real-time.
- Useful for debugging and verifying detection works outside of streaming.

### 4. Live Detection (Real-time)
- Performs real-time object detection with the camera.
- Detection runs every **5 seconds** to avoid blocking the UI thread.
- Currently doesn't use `Isolate`, so it's throttled to maintain app responsiveness.

## 🛠 Dependencies
- `tflite_flutter`
- `camera`
- `image`
- Other standard Flutter packages

## ⚠️ Notes
- Live detection can be optimized using `Isolate` or background processing in future versions.
- For best performance, use a lightweight model (`yolo11n`) as currently implemented.

## 🚀 Getting Started
1. Clone this repo.
2. Run `flutter pub get`.
3. Launch the app on a physical device (camera is required).
