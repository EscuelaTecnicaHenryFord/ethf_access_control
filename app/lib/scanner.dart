import 'package:ethf_access_control_app/person_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'dart:io' as io;

class Scanner extends StatelessWidget {
  const Scanner({
    super.key,
    required this.onPersonRead,
    required this.onError,
  });

  final void Function(PersonInfo person) onPersonRead;
  final void Function(Exception error) onError;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && io.Platform.isWindows) {
      return const Center(
        child: Text("No se puede usar el escaner en Windows"),
      );
    }

    final isIOS = io.Platform.isIOS;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            ReaderWidget(
              showScannerOverlay: false,
              showFlashlight: false,
              showToggleCamera: false,
              showGallery: false,
              tryHarder: isIOS ? true : false,
              cropPercent: isIOS ? 0.3 : 0.5,
              resolution: isIOS ? ResolutionPreset.max : ResolutionPreset.high,
              scanDelay: Duration(milliseconds: isIOS ? 100 : 1000),
              onScan: (result) async {
                final text = result.text;
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
                  onPersonRead(personInfo);
                } else {
                  onError(Exception("No se pudo leer el documento"));
                }
              },
            ),
            const Overlay(),
          ],
        );
      },
    );
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
