import 'dart:io';

import 'package:ethf_access_control_app/cameras.dart';
import 'package:ethf_access_control_app/person_info.dart';
import 'package:ethf_access_control_app/scanner_sdk_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

bool cameraInitialized = false;

class Mobile extends StatefulWidget {
  const Mobile({
    super.key,
    required this.onPersonRead,
    required this.onError,
    required this.cameraController,
    required this.barcodeReader,
    required this.cameras,
    required this.onCameraSelected,
    required this.selectedCameraIndex,
  });

  final Future<void> Function(PersonInfo person) onPersonRead;
  final void Function(Exception error) onError;
  final CameraController cameraController;
  final FlutterBarcodeSdk barcodeReader;
  final List<CameraDescription> cameras;
  final void Function(int index) onCameraSelected;
  final int selectedCameraIndex;

  @override
  MobileState createState() => MobileState();
}

class MobileState extends State<Mobile> {
  bool imageStreamStarted = false;

  int allowNextScanMS = 0;

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows) {
      startWindowsTimer();
    } else {
      startVideo();
    }
  }

  Timer? timer;

  void startWindowsTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 400), (timer) async {
      if (DateTime.now().millisecondsSinceEpoch > allowNextScanMS) {
        if (this.timer == null) return;
        pictureScan();
      }
    });
  }

  void pictureScan() async {
    final image = await widget.cameraController.takePicture();
    List<BarcodeResult> results = await widget.barcodeReader.decodeFile(image.path);
    onResults(results);
  }

  Future<void> onResults(List<BarcodeResult> results) async {
    final text = results.firstOrNull?.text;
    if (text == null) return;

    PersonInfo? personInfo;

    try {
      personInfo = PersonInfo.parse(text);
      if (kDebugMode) {
        print(personInfo);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo leer el documento"),
        ),
      );
    }

    if (personInfo != null) {
      try {
        allowNextScanMS = 0x7FFFFFFFFFFFFFFF;
        await widget.onPersonRead(personInfo);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      } finally {
        if (!Platform.isWindows) {
          await startVideo();
        }
        allowNextScanMS = DateTime.now().millisecondsSinceEpoch + 200;
      }
    } else {
      widget.onError(Exception("No se pudo leer el documento"));
    }
  }

  int _imageFormat(CameraImage image) {
    switch (image.format.group) {
      case ImageFormatGroup.yuv420:
        return ImagePixelFormat.IPF_NV21.index;
      case ImageFormatGroup.bgra8888:
        return ImagePixelFormat.IPF_ARGB_8888.index;
      default:
        return ImagePixelFormat.IPF_RGB_888.index;
    }
  }

  Future<void> startVideo() async {
    if (imageStreamStarted) return;
    setState(() {
      imageStreamStarted = true;
    });
    await widget.cameraController.startImageStream((CameraImage availableImage) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > allowNextScanMS && imageStreamStarted) {
        allowNextScanMS = now + 200;
        onAvailableImage(availableImage);
      }
    });
  }

  void onAvailableImage(CameraImage availableImage) async {
    final format = _imageFormat(availableImage);

    try {
      final results = await widget.barcodeReader.decodeImageBuffer(
        availableImage.planes[0].bytes,
        availableImage.width,
        availableImage.height,
        availableImage.planes[0].bytesPerRow,
        format,
      );

      onResults(results);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  Widget getCameraWidget() {
    return LayoutBuilder(builder: (context, constrains) {
      if (!widget.cameraController.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      } else {
        // https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched
        final size = Size(constrains.maxWidth, constrains.maxHeight);
        var scale = size.aspectRatio * widget.cameraController.value.aspectRatio;

        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

        if (isLandscape) {
          scale = size.aspectRatio * (1 / widget.cameraController.value.aspectRatio);
        }

        if (scale < 1) scale = 1 / scale;

        return Transform.scale(
          scale: scale,
          child: Center(
            child: CameraPreview(widget.cameraController),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        getCameraWidget(),
        const Overlay(),
        if (Platform.isWindows)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  pictureScan();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: Text("Escanear"),
                ),
              ),
            ),
          )
      ],
    );
  }
}

class Scanner extends StatefulWidget {
  const Scanner({
    super.key,
    required this.onPersonRead,
    required this.onError,
  });

  final Future<void> Function(PersonInfo person) onPersonRead;
  final void Function(Exception error) onError;

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  FlutterBarcodeSdk? barcodeReader;
  List<CameraDescription>? cameras;
  CameraController? cameraController;

  int cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    init(0);
  }

  @override
  void dispose() {
    super.dispose();
    cameraController?.dispose();
  }

  Future<void> init(int index) async {
    final barcodeReader = await globalInitBarcodeSDK();
    final cameras = await globalAvailableCameras();

    if (cameraController != null && cameraController!.value.isInitialized) {
      await cameraController!.dispose();
      setState(() {
        cameraController = null;
      });
    }

    final cam = cameras.length > index ? cameras[index] : null;

    if (cam != null) {
      try {
        final cc = CameraController(cam, ResolutionPreset.max, enableAudio: false);

        if (!cc.value.isInitialized) {
          await cc.initialize();
        }

        setState(() {
          cameraIndex = index;
          cameraController = cc;
          this.barcodeReader = barcodeReader;
          this.cameras = cameras;
        });
      } catch (e) {
        setState(() {
          cameraIndex = index;
          cameraController = null;
          this.barcodeReader = barcodeReader;
          this.cameras = cameras;
        });
      }
    } else {
      setState(() {
        cameraIndex = 0;
      });
    }
  }

  @override
  Widget build(Object context) {
    Widget? cameraSwitcher;
    if (cameras != null && cameras!.length > 1) {
      cameraSwitcher = SelectCameraDropDown(
        cameras: cameras!,
        onCameraSelected: (index) {
          init(index);
        },
        cameraIndex: cameraIndex,
      );
    }

    if (barcodeReader != null && cameraController != null) {
      return Stack(
        children: [
          Mobile(
            onError: widget.onError,
            onPersonRead: widget.onPersonRead,
            cameraController: cameraController!,
            barcodeReader: barcodeReader!,
            cameras: cameras!,
            selectedCameraIndex: cameraIndex,
            onCameraSelected: (index) {},
          ),
          if (cameraSwitcher != null) cameraSwitcher,
        ],
      );
    }

    print(cameraSwitcher);

    return Stack(
      children: [
        const Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(),
          ),
        ),
        const Center(
          child: Icon(Icons.qr_code_scanner_rounded),
        ),
        if (cameraSwitcher != null) cameraSwitcher,
      ],
    );
  }
}

class SelectCameraDropDown extends StatelessWidget {
  const SelectCameraDropDown({
    super.key,
    required this.cameras,
    required this.onCameraSelected,
    required this.cameraIndex,
  });

  final List<CameraDescription> cameras;
  final void Function(int index) onCameraSelected;
  final int cameraIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: IconButton(
        onPressed: () {
          var i = (cameraIndex + 1) % cameras.length;

          onCameraSelected(i);
        },
        icon: const Icon(Icons.cameraswitch_rounded),
      ),
    );
  }
}

class Overlay extends StatelessWidget {
  const Overlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final w = constrains.maxWidth / 2 + 10;
      return ColorFiltered(
        colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut), // This one will create the magic
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                backgroundBlendMode: BlendMode.dstOut,
              ), // This one will handle background + difference out
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: w,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.black,
                ),
                child: const AspectRatio(aspectRatio: 4),
              ),
            ),
          ],
        ),
      );
    });
  }
}
