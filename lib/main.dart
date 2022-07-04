import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'custom_snackbar.dart';
import 'face_detection_model.dart';
import 'face_detection_utility.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Face Detection using AWS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _imagePath = '';
  FaceDetectionModel? faceDetectionModel;

  void _selectImageSource(ImageSource imageSource) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
        source: imageSource,
        maxHeight: 480,
        maxWidth: 640);
    if (image == null) return;
    try {
      File imageFile = File(image.path);
      faceDetectionModel = await FacialDetection.detectFace(imageFile);
      if (faceDetectionModel?.numberOfFaces == 1) {
        if (faceDetectionModel?.hasPassedMinimumFaceDetection == true) {
          setState(() {
            _imagePath = image.path;
          });
        } else {
          errorSnackBar(
              context: context, text: faceDetectionModel?.description);
        }
      } else if (faceDetectionModel?.numberOfFaces == 0) {
        errorSnackBar(context: context, text: faceDetectionModel?.description);
      } else if (faceDetectionModel!.numberOfFaces! > 1) {
        errorSnackBar(context: context, text: faceDetectionModel?.description);
      }
    } catch (e) {
      errorSnackBar(context: context, text: 'Error uploading image');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) async {
    // Pick an image
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _selectImageSource(ImageSource.camera);
              },
              child: const Text('Camera'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _selectImageSource(ImageSource.gallery);
              },
              child: const Text('Gallery'),
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue.shade100),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue.shade100),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _imagePath.isEmpty
          ? GestureDetector(
              onTap: () {
                _showImageSourceActionSheet(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text(
                            'Click to change',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : GestureDetector(
              onTap: () {
                _showImageSourceActionSheet(context);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      // borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          File(_imagePath),
                        ),
                      ),
                    ),
                    height: 250,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
    );
  }
}
