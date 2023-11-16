import 'package:ethf_access_control_app/add_guest_screen.dart';
import 'package:ethf_access_control_app/auth_wrapper.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/history_screen.dart';
import 'package:ethf_access_control_app/home_screen.dart';
import 'package:ethf_access_control_app/scanner_view.dart';
import 'package:ethf_access_control_app/search.dart';
import 'package:ethf_access_control_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
        child: DataWrapper(),
      ),
    );
  }
}

class DataWrapper extends StatelessWidget {
  const DataWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return DataProviderWidget(key: providerKey, child: const MainPage(title: 'Control de Acceso'));
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

  final RefreshController refreshController = RefreshController(initialRefresh: false);

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

  int get currentRegisteredToday {
    final data = DataProvider.of(context).state;
    final today = DateTime.now();
    return data.history
        .where(
            (e) => e.timestamp.day == today.day && e.timestamp.month == today.month && e.timestamp.year == today.year)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Text(
                currentRegisteredToday.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              )),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              refreshController.requestRefresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: GlobalSearch(),
              );
            },
          ),
        ],
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
      body: SmartRefresher(
        onRefresh: () async {
          DataProvider.of(context).state.update();
          refreshController.refreshCompleted();
        },
        controller: refreshController,
        child: TabBarView(controller: controller, children: const [
          HomeScreen(),
          ScannerView(),
          HistoryScreen(),
        ]),
      ),
      floatingActionButton: controller.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddGuestScreen()));
              },
              icon: const Icon(Icons.person_add_rounded),
              label: const Text("Agregar invitado"))
          : null,
    );
  }
}
