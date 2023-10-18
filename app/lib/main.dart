import 'package:ethf_access_control_app/auth_wrapper.dart';
import 'package:ethf_access_control_app/scanner_view.dart';
import 'package:ethf_access_control_app/theme.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const AuthWrapper(
        child: ScanPage(title: 'ETHF Control de Acceso'),
      ),
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
  int index = 0;

  @override
  Widget build(BuildContext context) {
    late Widget body;

    if (index == 1) {
      body = const ScannerView();
    } else if (index == 2) {
      body = const Center(child: Text("Historial"));
    } else {
      body = const Center(child: Text("Inicio"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) => setState(() => index = value),
        selectedIndex: index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Inicio"),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: "Escanear"),
          NavigationDestination(icon: Icon(Icons.history), label: "Historial"),
        ],
      ),
      body: body,
    );
  }
}
