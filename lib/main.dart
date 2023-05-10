import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:object_detection_tflite/camera_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final CameraGetxController cameraGetxController = Get.put(CameraGetxController());

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.blue[900], title: const Text("Camera TFlite")),
      body: GetX<CameraGetxController>(
        builder: (controller) {
          if (!controller.isInitialise.value) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Stack(
              children: [
                Center(child: CameraPreview(controller.cameraController)),
                Positioned(
                    bottom: 30,
                    child: SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Center(
                          child: GestureDetector(
                            onTap: () {
                              controller.capture();
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            ),
                          )),
                    )),
                Positioned(
                    top: 15,
                    child: SizedBox(
                      height: 220,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.imageList.length, shrinkWrap: true, itemBuilder: (context, index) {
                        return Container(margin: EdgeInsets.symmetric(horizontal: 6),height: 150, width: 110, decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                            boxShadow: [BoxShadow(offset: Offset(4, 4))],
                            image: DecorationImage(image: MemoryImage(controller.imageList[index]),fit: BoxFit.cover)),);
                      },),
                    ))
              ],
            );
          }
        },
      ),
    );
  }
}
