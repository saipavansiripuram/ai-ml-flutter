import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ai/classifier.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class MlScreen extends StatefulWidget {
  const MlScreen({super.key});

  @override
  State<MlScreen> createState() => _MlScreenState();
}

class _MlScreenState extends State<MlScreen> {
  String _result = '';
  final textRecognizer = TextRecognizer();
  final barCodeScanner = BarcodeScanner();
  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final classifier = Classifier();
  File? _image;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ML Kit Features Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _image == null
                ? const SizedBox(height: 200)
                : Image.file(_image!, height: 200, width: 200),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _getImage(ImageSource.camera);
                  },
                  child: const Text("Take a photo"),
                ),

                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _getImage(ImageSource.gallery);
                  },
                  child: const Text("Choose from gallery"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _image != null
                      ? _recognizedText(_image!)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No Image Selected")),
                        ),
                  child: const Text('Recognized Text'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _image != null
                      ? _scanBarcodes(_image!)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No Image  Selected")),
                        ),
                  child: const Text('Scan Barcode'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _result.isNotEmpty
                      ? _detectLanguage(_result)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No Text Detected")),
                        ),
                  child: const Text('Detect Languages'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _result.isNotEmpty
                      ? _extractEntitiesFromText(_result)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No Text Detected")),
                        ),
                  child: const Text('Detect Entities'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _image != null
                      ? _getImageLabels(_image!)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No Image Detected")),
                        ),
                  child: const Text('Label Image'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _image != null
                      ? _detectFaces(_image!)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No Face Detected")),
                        ),
                  child: const Text('Detect Face'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _result.isNotEmpty
                      ? _classifyText(_result)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No Text Detected")),
                        ),
                  child: const Text('Classify Text'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Text(
                'Recognized Text :\n $_result',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final file = await picker.pickImage(source: source);
    try {
      if (file != null) {
        setState(() {
          _image = File(file.path);
        });
      }
    } on Exception catch (e) {
      print(e);
      return;
    }
  }

  Future<void> _recognizedText(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        _result = recognizedText.text;
      });
    } on Exception catch (e) {
      setState(() {
        _result = 'Error recognizing the text : $e';
      });
    }
  }

  Future<void> _scanBarcodes(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final List<Barcode> barcodes = await barCodeScanner.processImage(
        inputImage,
      );
      String barcodeString = '';
      for (final barcode in barcodes) {
        barcodeString += 'Type ${barcode.type}\nValue: ${barcode.rawValue}';
      }
      setState(() {
        _result = barcodeString;
      });
    } on Exception catch (e) {
      setState(() {
        _result = 'Error scanning barcode : $e';
      });
    }
  }

  Future<void> _detectLanguage(String text) async {
    try {
      final List<IdentifiedLanguage> languages = await languageIdentifier
          .identifyPossibleLanguages(text);
      String identifiedLanguages = '';
      for (IdentifiedLanguage language in languages) {
        identifiedLanguages +=
            'Language: ${language.languageTag} - Probability: ${language.confidence * 100}%';
      }
      setState(() {
        _result = identifiedLanguages;
      });
    } on Exception catch (e) {
      setState(() {
        _result = 'Error scanning Image : $e';
      });
    }
  }

  Future<void> _extractEntitiesFromText(String text) async {
    final entityExtractor = EntityExtractor(
      language: EntityExtractorLanguage.english,
    );
    final annotations = await entityExtractor.annotateText(text);
    String entityResult = '';
    for (final annotaion in annotations) {
      entityResult += 'Entity text : ${annotaion.text}\n';
      for (final entity in annotaion.entities) {
        entityResult += 'Entity type: ${entity.type} \n';
      }
    }
    setState(() {
      _result = entityResult;
    });
  }

  Future<void> _getImageLabels(File image) async {
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
    try {
      final inputImage = InputImage.fromFile(image);
      final List<ImageLabel> labels = await imageLabeler.processImage(
        inputImage,
      );
      String labelResult = '';
      for (ImageLabel label in labels) {
        labelResult +=
            'Label: ${label.label} - Confidence: ${label.confidence}\n';
      }
      setState(() {
        _result = labelResult;
      });
    } on Exception catch (e) {
      setState(() {
        _result = 'Error Labeling Image : $e';
      });
    }
    imageLabeler.close();
  }

  Future<void> _detectFaces(File image) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableClassification: true),
    );
    try {
      final inputImage = InputImage.fromFile(image);
      final List<Face> faces = await faceDetector.processImage(inputImage);
      String detectorResult = 'Faces detected: ${faces.length}\n';
      for (Face face in faces) {
        String leftEyeStatus = face.leftEyeOpenProbability != null
            ? (face.leftEyeOpenProbability! < 0.5 ? 'Closed' : 'Open')
            : 'Unknown';

        detectorResult +=
            'Bounding box: ${face.boundingBox}\n Left eye open: ${leftEyeStatus} \n Right eye open: ${face.rightEyeOpenProbability}';
      }
      setState(() {
        _result = detectorResult;
      });
    } on Exception catch (e) {
      setState(() {
        _result = 'Error Detecting Image : $e';
      });
    }
    faceDetector.close();
  }

  Future<void> _classifyText(String text) async {
    final List<double> indexes = classifier.classify(text);
    double negative = indexes[0];
    double positive = indexes[1];
    if (positive > negative) {
      _result = 'The sentiment of the text is positive';
    } else {
      _result = 'The sentiment of the text is negative';
    }
    setState(() {});
  }
}
