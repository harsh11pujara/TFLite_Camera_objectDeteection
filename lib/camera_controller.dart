import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

class CameraGetxController extends GetxController{
  final isInitialise = false.obs;
late CameraController cameraController;
late List<CameraDescription> _cameras;
late CameraImage cameraImage;
final imageList = [].obs;

  @override
  onInit(){
    initCamera();
    print("in getx init");
    super.onInit();
  }

 Future<void> initCamera() async{
    _cameras = await availableCameras();
   cameraController = CameraController(_cameras[0], ResolutionPreset.max);
   try {
     await cameraController.initialize().then((value) {
       isInitialise.value = true;
       update();
       cameraController.startImageStream((image) => cameraImage = image);
     });
   } on Exception catch (e) {
     throw Exception("Error Occurred $e");
   }
  }

  capture() async{
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage);
    } else {
      throw Exception('Undefined image type.');
    }
    // print("image planes  "+cameraImage.planes[0].bytes.toString());
    // print(cameraImage.format.group);
    // img.Image image = img.Image.fromBytes(width: cameraImage.width, height: cameraImage.height, bytes: cameraImage.planes[0].bytes.buffer,order: img.ChannelOrder.bgra);
    // Uint8List jpeg = Uint8List.fromList(img.encodeJpg(image));
    // imageList.add(jpeg);
    // update();

  }

  /// Converts a [CameraImage] in BGRA888 format to [image_lib.Image] in RGB format
  ///
   convertBGRA8888ToImage(CameraImage cameraImage) {
    img.Image image =  img.Image.fromBytes(
      width: cameraImage.planes[0].width!,
      height: cameraImage.planes[0].height!,
      bytes: cameraImage.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
    Uint8List jpeg = Uint8List.fromList(img.encodeJpg(image));
    imageList.add(jpeg);
    update();
  }

  ///
  /// Converts a [CameraImage] in YUV420 format to [image_lib.Image] in RGB format
  ///
  convertYUV420ToImage(CameraImage cameraImage) {
    final imageWidth = cameraImage.width;
    final imageHeight = cameraImage.height;

    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final int yRowStride = cameraImage.planes[0].bytesPerRow;
    final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width: imageWidth, height: imageHeight);

    for (int h = 0; h < imageHeight; h++) {
      int uvh = (h / 2).floor();

      for (int w = 0; w < imageWidth; w++) {
        int uvw = (w / 2).floor();

        final yIndex = (h * yRowStride) + (w * yPixelStride);

        // Y plane should have positive values belonging to [0...255]
        final int y = yBuffer[yIndex];

        // U/V Values are subsampled i.e. each pixel in U/V chanel in a
        // YUV_420 image act as chroma value for 4 neighbouring pixels
        final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

        // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
        // [0, 255] range they are scaled up and centered to 128.
        // Operation below brings U/V values to [-128, 127].
        final int u = uBuffer[uvIndex];
        final int v = vBuffer[uvIndex];

        // Compute RGB values per formula above.
        int r = (y + v * 1436 / 1024 - 179).round();
        int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
        int b = (y + u * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        image.setPixelRgb(w, h, r, g, b);
      }
    }

    img.Image imageFromYUv =  image;
    img.Image orientedImg = img.copyRotate(imageFromYUv,angle: 90);
    Uint8List jpeg = Uint8List.fromList(img.encodeJpg(orientedImg));
    imageList.add(jpeg);
    update();

  }
}
