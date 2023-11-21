import 'package:ethf_access_control_app/person_info.dart';
import 'package:ethf_access_control_app/scanner.dart';
import 'package:flutter/material.dart';

Future<PersonInfo?> showScanDniDialog(BuildContext context) async {
  final result = await showDialog<PersonInfo>(
    context: context,
    builder: (context) => const ScanDniDialog(),
  );
  return result;
}

class ScanDniDialog extends StatelessWidget {
  const ScanDniDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Positioned.fill(
              child: Scanner(
                onPersonRead: (person) async => Navigator.of(context).pop(person),
                onError: (error) {},
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
    );
  }
}
