import 'package:ethf_access_control_app/person_info.dart';
import 'package:ethf_access_control_app/person_info_card.dart';
import 'package:ethf_access_control_app/scanner.dart';
import 'package:flutter/material.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  PersonInfo? personInfo;
  int index = 0;

  void showPersonInfo(PersonInfo personInfo) {
    setState(() {
      this.personInfo = personInfo;
    });

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          ),
          enableDrag: true,
          onClosing: () {},
          builder: (context) {
            return PersonInfoCard(personInfo: personInfo);
          },
        );
      },
    );
  }

  void handleError(Exception error) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se pudo leer el documento")));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scanner(
          onPersonRead: showPersonInfo,
          onError: handleError,
        ),
      ],
    );
  }
}
