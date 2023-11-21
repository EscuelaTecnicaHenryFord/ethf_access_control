import 'dart:convert';

import 'package:ethf_access_control_app/person_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

class Mobile extends StatefulWidget {
  final CameraDescription camera;

  const Mobile({
    super.key,
    required this.camera,
    required this.onPersonRead,
    required this.onError,
  });

  final Future<void> Function(PersonInfo person) onPersonRead;
  final void Function(Exception error) onError;

  @override
  MobileState createState() => MobileState();
}

class MobileState extends State<Mobile> {
  CameraController? _controller;
  FlutterBarcodeSdk? _barcodeReader;
  bool _isScanAvailable = true;
  bool _isScanRunning = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _controller!.initialize().then((_) {
      setState(() {});
      startVideo();
    });
    // Initialize Dynamsoft Barcode Reader
    initBarcodeSDK();
  }

  Future<void> initBarcodeSDK() async {
    _barcodeReader = FlutterBarcodeSdk();
    // Get 30-day FREEE trial license from https://www.dynamsoft.com/customer/license/trialLicense?product=dbr
    await _barcodeReader!.setLicense(
        'DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==');
    await _barcodeReader!.init();
    await _barcodeReader!.setBarcodeFormats(BarcodeFormat.PDF417);
    // Get all current parameters.
    // Refer to: https://www.dynamsoft.com/barcode-reader/parameters/reference/image-parameter/?ver=latest
    String params = await _barcodeReader!.getParameters();
    // Convert parameters to a JSON object.
    dynamic obj = json.decode(params);
    // Modify parameters.
    obj['ImageParameter']['DeblurLevel'] = 5;
    // Update the parameters.
    int ret = await _barcodeReader!.setParameters(json.encode(obj));
    print('Parameter update: $ret');
  }

  void pictureScan() async {
    if (_isScanRunning) stopVideo();
    final image = await _controller!.takePicture();
    List<BarcodeResult> results = await _barcodeReader!.decodeFile(image.path);

    onResults(results);
  }

  void onResults(List<BarcodeResult> results) {
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
      stopVideo();
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

  void startVideo() async {
    _isScanRunning = true;
    await _controller!.startImageStream((CameraImage availableImage) async {
      assert(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
      int format = ImagePixelFormat.IPF_NV21.index;

      switch (availableImage.format.group) {
        case ImageFormatGroup.yuv420:
          format = ImagePixelFormat.IPF_NV21.index;
          break;
        case ImageFormatGroup.bgra8888:
          format = ImagePixelFormat.IPF_ARGB_8888.index;
          break;
        default:
          format = ImagePixelFormat.IPF_RGB_888.index;
      }

      if (!_isScanAvailable) {
        return;
      }

      _isScanAvailable = false;

      _barcodeReader!
          .decodeImageBuffer(availableImage.planes[0].bytes, availableImage.width, availableImage.height,
              availableImage.planes[0].bytesPerRow, format)
          .then((results) {
        if (_isScanRunning) {
          setState(() {
            onResults(results);
          });
        }

        _isScanAvailable = true;
      }).catchError((error) {
        _isScanAvailable = false;
      });
    });
  }

  void stopVideo() async {
    _isScanRunning = false;
    await _controller!.stopImageStream();
  }

  void videoScan() async {
    if (!_isScanRunning) {
      startVideo();
    } else {
      stopVideo();
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  Widget getCameraWidget() {
    if (!_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    } else {
      // https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched
      final size = MediaQuery.of(context).size;
      var scale = size.aspectRatio * _controller!.value.aspectRatio;

      if (scale < 1) scale = 1 / scale;

      return Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      );
      // return CameraPreview(_controller);
    }
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
            if (_isScanRunning) {
              stopVideo();
            } else {
              startVideo();
            }
          },
          icon: _isScanRunning ? const Icon(Icons.pause_rounded) : const Icon(Icons.play_arrow_rounded),
        ),
      ),
      Positioned(
        bottom: 10,
        right: 60,
        child: IconButton(
          onPressed: () {
            if (_isScanRunning) {
              stopVideo();
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
  });

  final Future<void> Function(PersonInfo person) onPersonRead;
  final void Function(Exception error) onError;

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final cameras = availableCameras();

  @override
  Widget build(Object context) {
    return FutureBuilder(
        future: cameras,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Mobile(
              camera: snapshot.data![0],
              onError: widget.onError,
              onPersonRead: widget.onPersonRead,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class Overlay extends StatelessWidget {
  const Overlay({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final w = width / 2 + 10;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut), // This one will create the magic
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
  }
}
