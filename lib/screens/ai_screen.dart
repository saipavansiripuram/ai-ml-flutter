import 'dart:io';
// import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../assets/examples.dart';
import '../secrets.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  File? _image;
  String _format = 'JSON';
  String _result = '';
  final picker = ImagePicker();
  late GenerativeModel _model;
  String _prompt = '';

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected.')));
      }
    });
  }

  // Future<void> _analyzeReceipt() async {
  //   setState(() {
  //     _result = 'Processing...';
  //   });
  //   if (_image == null) {
  //     setState(() {
  //       _result = 'No image selected';
  //       return;
  //     });
  //   }
  //   final imageBytes = await _image!.readAsBytes();
  //   final content = Content.multi([
  //     DataPart('image/jpeg', imageBytes),
  //     TextPart(_prompt),
  //   ]);
  //   final response = await _model.generateContent([content]);
  //   if (response.text == null) {
  //     setState(() {
  //       _result = 'There was an error with the response';
  //     });
  //   } else {
  //     setState(() {
  //       _result = response.text!;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    _prompt = '''
You are an expert receipt data extraction bot. 
Analyze the following receipt and extract the purchase date, list of items, 
price of each item, and the total.

Output the extracted data in JSON format, following this structure:
{
  "date": "YYYY-MM-DD",
  "items": [
    {
      "name": "item_name_1",
      "price": number
    },
    {
      "name": "item_name_2",
      "price": number
    }
   ...
  ],
  "total": number
}
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini AI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_image != null) Image.file(_image!, height: 200, width: 200),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('JSON'),
                Switch(
                  value: _format == 'XML',
                  onChanged: (bool value) {
                    setState(() {
                      _format = value ? 'XML' : 'JSON';
                    });
                  },
                ),
                const Text('XML'),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => getImage(ImageSource.camera),
                  child: const Text('Take a photo'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => getImage(ImageSource.gallery),
                  child: const Text('Choose from gallery'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _analyzeReceipt2(),
                  child: const Text('Analyze receipt'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Text('Result:\n$_result', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeReceipt2() async {
    final outputExample = _format == 'JSON' ? jsonExample : xmlExample;
    // final outputExample = '';
    String prompt = _prompt
        .replaceAll('{{output_format}}', _format)
        .replaceAll('{{output_example}}', outputExample);
    setState(() {
      _result = 'Processing...';
    });
    if (_image == null) {
      setState(() {
        _result = 'No image selected';
      });
    }
    try {
      final resizedBytes = await _resizeImage(_image!);
      if (resizedBytes == null) {
        setState(() {
          _result = 'Could not recognize image';
          return;
        });
      }
      final content = Content.multi([
        DataPart('image/jpeg', resizedBytes!),
        TextPart(prompt),
      ]);
      final response = await _model.generateContent([content]);
      if (response.text == null) {
        setState(() {
          _result = 'There was an error with the response';
        });
      } else {
        setState(() {
          _result = response.text!;
        });
      }
    } on Exception catch (e) {
      setState(() {
        _result = 'Error $e';
      });
    }
  }

  Future<Uint8List?> _resizeImage(File imageFile, {int maxWidth = 768}) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return null;
      }
      final resizedImage = img.copyResize(image, width: maxWidth);
      final resizedBytes = img.encodeJpg(resizedImage, quality: 85);
      return Uint8List.fromList(resizedBytes);
    } on Exception catch (e) {
      print('Error resizing image $e');
    }
  }
}
