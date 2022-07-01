import 'dart:io';
import 'dart:typed_data';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart';
import 'face_detection_model.dart';

String _awsAccessId = '_AWS_ACCESS_ID';
String _awsRegion = '_AWS_REGION';
String _awsSecretAccessKey = '_AWS_SECRET_ACCESS_KEY';

class FacialDetection {

  static bool isEyesOpen = false,
      isHumanFaceDetected = false,
      isImageBright = false,
      isImageSharp = false,
      hasPassedMinimumFaceDetection = false;

  static Future<FaceDetectionModel?> detectFace(File file) async {
    var faceDetectionModel = FaceDetectionModel();
    // FaceDetectionModel? faceDetectionModel;

    //convert image file to Uint8List in order to use the image in bytes
    Uint8List uint8ListImage = await file.readAsBytes();
    final service = Rekognition(
        region: _awsRegion,
        credentials: AwsClientCredentials(
            accessKey: _awsAccessId, secretKey: _awsSecretAccessKey));
    var faceResult = await service.detectFaces(
        image: Image(bytes: uint8ListImage), attributes: [Attribute.all]);

    if (faceResult.faceDetails?.length == 1) {
      isImageBright = faceResult.faceDetails![0].quality!.brightness! >= 35.0;

      isImageSharp = faceResult.faceDetails![0].quality!.sharpness! >= 35.0;

      isEyesOpen = faceResult.faceDetails![0].eyesOpen!.value! &&
          faceResult.faceDetails![0].eyesOpen!.confidence! >= 50;

      isHumanFaceDetected = faceResult.faceDetails![0].confidence! >= 70;

      hasPassedMinimumFaceDetection =
          isImageBright && isImageSharp && isEyesOpen && isHumanFaceDetected;

      if (hasPassedMinimumFaceDetection) {
        faceDetectionModel.numberOfFaces = faceResult.faceDetails?.length;
        faceDetectionModel.hasPassedMinimumFaceDetection = true;
        return faceDetectionModel;
      } else {
        faceDetectionModel.description = 'Unable to detect face';
        faceDetectionModel.numberOfFaces = faceResult.faceDetails?.length;
        faceDetectionModel.hasPassedMinimumFaceDetection = false;
        return faceDetectionModel;
      }
    } else if (faceResult.faceDetails!.isEmpty) {
      faceDetectionModel.description = 'No face found';
      faceDetectionModel.numberOfFaces = faceResult.faceDetails?.length;
      return faceDetectionModel;
    }

    //more than one face detected
    else if (faceResult.faceDetails!.length > 1) {
      faceDetectionModel.description =
      '${faceResult.faceDetails!.length} faces found';
      faceDetectionModel.numberOfFaces = faceResult.faceDetails?.length;
      return faceDetectionModel;
    }
    // return faceDetectionModel;
  }
}