import 'package:camera/camera.dart';
import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/person_info.dart';
import 'package:ethf_access_control_app/person_info_card.dart';
import 'package:ethf_access_control_app/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key, required this.cameras, required this.barcodeReader});

  final List<CameraDescription>? cameras;
  final FlutterBarcodeSdk? barcodeReader;

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  PersonInfo? personInfo;
  int index = 0;

  Set<String> scanned = {};

  Future<void> showPersonInfo(PersonInfo personInfo) async {
    if (scanned.contains(personInfo.dni)) return;

    setState(() {
      this.personInfo = personInfo;
    });

    scanned.add(personInfo.dni);

    final data = DataProvider.of(context).state;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          ),
          enableDrag: true,
          onClosing: () {},
          builder: (context) {
            return PersonInfoCard(
              personInfo: personInfo,
              data: data,
            );
          },
        );
      },
    );

    scanned.remove(personInfo.dni);
  }

  void handleError(Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se pudo leer el documento")));
  }

  List<HistoryEntry> get history {
    final data = DataProvider.of(context).state;
    return data.history;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scanner(
          onPersonRead: showPersonInfo,
          onError: handleError,
          barcodeReader: widget.barcodeReader,
          cameras: widget.cameras,
        ),
      ],
    );
  }
}
