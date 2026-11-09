import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 14',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Lab14Screen(),
    );
  }
}

class Lab14Screen extends StatefulWidget {
  const Lab14Screen({super.key});

  @override
  State<Lab14Screen> createState() => _Lab14ScreenState();
}

class _Lab14ScreenState extends State<Lab14Screen> {

  static const platform = MethodChannel('com.example.lab14/channel');

  String _nativeMessage = 'Тут зʼявиться текст із нативного коду';
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  // Виклик нативного методу з обробкою веб-режиму
  Future<void> _getNativeMessage() async {
    String message;

    if (kIsWeb) {

      message = "Michael Jackson ";
    } else {
      try {
        final result = await platform.invokeMethod('getHiMom');
        message = result.toString();
      } on PlatformException catch (e) {
        message = "Помилка: '${e.message}'.";
      }
    }

    setState(() {
      _nativeMessage = message;
    });
  }

  // Вибір/зйомка фото
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторна робота №14')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Розділ MethodChannel
            Text(
              _nativeMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getNativeMessage,
              child: const Text('Отримати текст із Native (Kotlin)'),
            ),
            const Divider(height: 40),

            // Розділ Камери / Вибору зображення
            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 200)
                : const Text('Фото ще не зроблено'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _takePhoto,
              child: const Text('Зробити фото камерою'),
            ),
          ],
        ),
      ),
    );
  }
}