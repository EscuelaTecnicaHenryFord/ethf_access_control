import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
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

  Set<String> scanned = {};

  void showPersonInfo(PersonInfo personInfo) {
    if (scanned.contains(personInfo.dni)) return;

    setState(() {
      this.personInfo = personInfo;
    });

    scanned.add(personInfo.dni);

    final data = DataProvider.of(context).state;

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
            return PersonInfoCard(
              personInfo: personInfo,
              data: data,
            );
          },
        );
      },
    ).then((value) {
      scanned.remove(personInfo.dni);
    });
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
        ),
      ],
    );
  }
}
