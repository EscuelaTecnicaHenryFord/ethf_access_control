import 'package:ethf_access_control_app/person_info.dart';
import 'package:ethf_access_control_app/person_info_card.dart';
import 'package:ethf_access_control_app/scanner.dart';
import 'package:ethf_access_control_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appThemeData,
      darkTheme: appDarkThemeData,
      home: const ScanPage(title: 'ETHF Control de Acceso'),
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.title});

  final String title;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  PersonInfo? personInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Scanner(
            onPersonRead: (person) => setState(() {
              personInfo = person;
            }),
            onError: (error) =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No se pudo leer el documento"))),
          ),
          if (personInfo != null)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: PersonInfoCard(
                key: ValueKey(personInfo!.cuil),
                personInfo: personInfo!,
              ),
            ),
          if (personInfo != null)
            Positioned(
              bottom: PersonInfoCard.height + 26,
              right: 14,
              child: CircleAvatar(
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      personInfo = null;
                    });
                  },
                ),
              ),
            )
        ],
      ),
    );
  }
}
