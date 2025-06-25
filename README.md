# 🚀 Flutter AI

A powerful AI-enhanced Flutter application that brings together Google's ML Kit features, generative AI capabilities, and local model inference using TensorFlow Lite. This project contain real world applications of image processing, barcode scanning, face detection, entity extraction, and more—all in a seamless mobile experience.

## ✨ Features

* 🤖 **Generative AI Integration** using `google_generative_ai`
* 📦 **Barcode Scanning** with `google_mlkit_barcode_scanning`
* 🧠 **Entity Extraction** (like dates, addresses) via `google_mlkit_entity_extraction`
* 😊 **Face Detection** with ML Kit using `google_mlkit_face_detection`
* 🖼️ **Image Labeling** for recognizing objects in images using `google_mlkit_image_labeling`
* 🌍 **Language Identification** using `google_mlkit_language_id`
* 🔤 **Text Recognition** from images via `google_mlkit_text_recognition`
* 📷 **Image Picker** for choosing photos from gallery or camera
* 🖌️ **Image Processing** with the `image` package (e.g., cropping, resizing)
* 🧩 **TFLite Model Inference** using `tflite_flutter` for custom ML models

## 🛠️ Project Setup

### Prerequisites

* Flutter SDK (>= 3.8.0)
* Android Studio / VS Code with Flutter and Dart plugins

### Installation

1. Clone the repo:

   ```bash
   git clone https://github.com/your-username/flutter_ai.git
   cd flutter_ai
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

## 📂 Project Structure

```
flutter_ai/
├── assets/                 # Images, model files, etc.
├── lib/                    # Dart source files
├── pubspec.yaml            # Dependencies and configuration
```

## 📦 Dependencies

| Package                          | Purpose                                                      |
| -------------------------------- | ------------------------------------------------------------ |
| `google_generative_ai`           | Generates human-like text from prompts                       |
| `google_mlkit_barcode_scanning`  | Scans and extracts barcode data                              |
| `google_mlkit_entity_extraction` | Extracts entities (e.g., phone numbers, addresses) from text |
| `google_mlkit_face_detection`    | Detects faces in images                                      |
| `google_mlkit_image_labeling`    | Labels objects in photos                                     |
| `google_mlkit_language_id`       | Identifies the language of input text                        |
| `google_mlkit_text_recognition`  | Recognizes and extracts text from images                     |
| `image`                          | Used for low-level image processing                          |
| `image_picker`                   | Allows selecting/capturing images                            |
| `tflite_flutter`                 | Enables running TFLite models in Flutter                     |

## 🧪 Testing

To run tests:

```bash
flutter test
```

## 💡 Use Cases

* AI text generation with prompts (chatbots, summarizers)
* Scanning product barcodes
* Detecting and analyzing faces in photos
* Reading documents and extracting relevant information
* Multilingual support and language-aware features
* Image-based predictions using custom TFLite models

