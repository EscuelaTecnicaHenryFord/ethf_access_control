import 'package:ethf_access_control_app/auth_wrapper.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/home_screen.dart';
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
        child: MainPage(title: 'ETHF Control de Acceso'),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int index = 0;

  late final TabController controller;

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    controller.addListener(listener);
    super.initState();
  }

  void listener() {
    setState(() {
      index = controller.index;
    });
  }

  void onDestinationSelected(int value) {
    controller.animateTo(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: onDestinationSelected,
        selectedIndex: controller.index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Inicio"),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: "Escanear"),
          NavigationDestination(icon: Icon(Icons.history), label: "Historial"),
        ],
      ),
      body: DataProviderWidget(
        child: TabBarView(controller: controller, children: const [
          HomeScreen(),
          ScannerView(),
          Center(child: Text("Historial")),
        ]),
      ),
    );
  }
}
