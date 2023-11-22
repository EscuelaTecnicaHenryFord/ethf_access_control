import 'package:ethf_access_control_app/person_info.dart';
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
  });

  final Future<void> Function(PersonInfo person) onPersonRead;
  final void Function(Exception error) onError;
  final CameraController cameraController;
  final FlutterBarcodeSdk barcodeReader;

  @override
  MobileState createState() => MobileState();
}

class MobileState extends State<Mobile> {
  bool imageStreamStarted = false;

  int allowNextScanMS = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.cameraController.value.isInitialized) {
      widget.cameraController.initialize();
    }
    startVideo();
  }

  void pictureScan() async {
    if (imageStreamStarted) stopVideo();
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
        stopVideo();
        allowNextScanMS = 0x7FFFFFFFFFFFFFFF;
        await widget.onPersonRead(personInfo);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      } finally {
        await startVideo();
        allowNextScanMS = DateTime.now().millisecondsSinceEpoch + 200;
      }

      widget.onPersonRead(personInfo).then((value) {}).catchError((error) {
        if (kDebugMode) {
          print(error);
        }
      }).whenComplete(() {
        startVideo();
      });
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
    assert(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
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

  Future<void> stopVideo() async {
    setState(() {
      imageStreamStarted = false;
    });
    await widget.cameraController.stopImageStream();
  }

  @override
  void dispose() {
    // widget.cameraController.dispose();
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
    return Stack(children: [
      Positioned.fill(child: getCameraWidget()),
      const Positioned.fill(child: Overlay()),
      Positioned(
        bottom: 10,
        right: 10,
        child: IconButton(
          onPressed: () {
            if (imageStreamStarted) {
              stopVideo();
            } else {
              startVideo();
            }
          },
          icon: imageStreamStarted ? const Icon(Icons.pause_rounded) : const Icon(Icons.play_arrow_rounded),
        ),
      ),
      Positioned(
        bottom: 10,
        right: 60,
        child: IconButton(
          onPressed: () async {
            if (imageStreamStarted) {
              await stopVideo();
            }

            pictureScan();
          },
          icon: const Icon(Icons.camera_alt_rounded),
        ),
      )
    ]);
  }
}

class Scanner extends StatefulWidget {
  const Scanner({
    super.key,
    required this.onPersonRead,
    required this.onError,
    required this.cameras,
    required this.barcodeReader,
  });

  final Future<void> Function(PersonInfo person) onPersonRead;
  final void Function(Exception error) onError;
  final List<CameraDescription>? cameras;
  final FlutterBarcodeSdk? barcodeReader;

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  CameraController? cameraController;

  @override
  void initState() {
    init();

    super.initState();
  }

  Future<void> init() async {
    final cam = widget.cameras?.firstOrNull;

    if (cam != null) {
      final cc = CameraController(cam, ResolutionPreset.max);

      await cc.initialize();

      setState(() {
        cameraController = cc;
      });
    }
  }

  @override
  Widget build(Object context) {
    print(cameraController);
    if (widget.barcodeReader != null && cameraController != null) {
      return Mobile(
        onError: widget.onError,
        onPersonRead: widget.onPersonRead,
        cameraController: cameraController!,
        barcodeReader: widget.barcodeReader!,
      );
    }

    return const Stack(
      children: [
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(),
          ),
        ),
        Center(
          child: Icon(Icons.qr_code_scanner_rounded),
        ),
      ],
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
