import 'package:camera/camera.dart';
import 'package:ethf_access_control_app/person_info.dart';
import 'package:ethf_access_control_app/scanner.dart';
import 'package:ethf_access_control_app/scanner_sdk_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

Future<PersonInfo?> showScanDniDialog(BuildContext context) async {
  final result = await showDialog<PersonInfo>(
    context: context,
    builder: (context) => const ScanDniDialog(),
  );
  return result;
}

class ScanDniDialog extends StatefulWidget {
  const ScanDniDialog({super.key});

  @override
  State<ScanDniDialog> createState() => _ScanDniDialogState();
}

class _ScanDniDialogState extends State<ScanDniDialog> {
  FlutterBarcodeSdk? barcodeReader;
  List<CameraDescription>? cameras;

  void initBarcode() {
    initBarcodeSDK().then((value) {
      barcodeReader = value;
    });

    availableCameras().then((value) {
      cameras = value;
    });
  }

  @override
  void initState() {
    initBarcode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: Scanner(
                  onPersonRead: (person) async => Navigator.of(context).pop(person),
                  onError: (error) {},
                  barcodeReader: barcodeReader,
                  cameras: cameras,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
