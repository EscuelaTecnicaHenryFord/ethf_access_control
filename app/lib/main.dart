import 'package:ethf_access_control_app/person_info.dart';
import 'package:ethf_access_control_app/person_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

void main() {
  runApp(const MyApp());
}

final Map<int, Color> color = {
  50: const Color.fromRGBO(0, 0, 0, .1),
  100: const Color.fromRGBO(0, 0, 0, .2),
  200: const Color.fromRGBO(0, 0, 0, .3),
  300: const Color.fromRGBO(0, 0, 0, .4),
  400: const Color.fromRGBO(0, 0, 0, .5),
  500: const Color.fromRGBO(0, 0, 0, .6),
  600: const Color.fromRGBO(0, 0, 0, .7),
  700: const Color.fromRGBO(0, 0, 0, .8),
  800: const Color.fromRGBO(0, 0, 0, .9),
  900: const Color.fromRGBO(0, 0, 0, 1),
};

final Map<int, Color> colorWhite = {
  50: const Color.fromRGBO(255, 255, 255, .1),
  100: const Color.fromRGBO(255, 255, 255, .2),
  200: const Color.fromRGBO(255, 255, 255, .3),
  300: const Color.fromRGBO(255, 255, 255, .4),
  400: const Color.fromRGBO(255, 255, 255, .5),
  500: const Color.fromRGBO(255, 255, 255, .6),
  600: const Color.fromRGBO(255, 255, 255, .7),
  700: const Color.fromRGBO(255, 255, 255, .8),
  800: const Color.fromRGBO(255, 255, 255, .9),
  900: const Color.fromRGBO(255, 255, 255, 1),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          secondaryContainer: Colors.grey,
          primary: MaterialColor(0xFF000000, color),
          surface: MaterialColor(0xFFFFFFFF, colorWhite),
          surfaceVariant: MaterialColor(0xFFFFFFFF, colorWhite),
          onSurface: Colors.black,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: MaterialColor(0xFF000000, color),
        ),
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
          color: MaterialColor(0xFF000000, color),
        )),
        primarySwatch: MaterialColor(0xFF000000, color),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: MaterialColor(0xFFFFFFFF, colorWhite),
          secondary: Colors.lightBlue,
          tertiary: Colors.lightBlue,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: MaterialColor(0xFFFFFFFF, colorWhite),
        ),
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
          color: MaterialColor(0xFFFFFFFF, colorWhite),
        )),
        primarySwatch: MaterialColor(0xFFFFFFFF, colorWhite),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
          ReaderWidget(
            actionButtonsPadding: EdgeInsets.only(
              bottom: personInfo != null ? PersonInfoCard.height + 26 : 14,
              left: 14,
            ),
            showGallery: false,
            tryHarder: false,
            scanDelay: Duration(milliseconds: 500),
            cropPercent: 0.85,
            onScan: (result) async {
              final text = result.text;
              if (text == null) return;
              try {
                setState(() {
                  personInfo = PersonInfo.parse(text);
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "No se puedo leer el documento, vuelva a intentar"),
                  ),
                );
              }
            },
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
