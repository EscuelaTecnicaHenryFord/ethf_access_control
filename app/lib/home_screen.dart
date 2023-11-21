import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/person_page.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    final data = DataProvider.of(context).state;

    if (data.dataLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    bool isInHistory(String id) {
      return data.registeredGuestsToday.contains(id);
    }

    return SmartRefresher(
      onRefresh: () async {
        await DataProvider.of(context).state.updateData();
        refreshController.refreshCompleted();
      },
      controller: refreshController,
      child: ListView(
        children: [
          ListTile(tileColor: Colors.grey.shade900, title: const Text("Invitados")),
          if (!data.dataLoaded)
            ListTile(
              title: const Text("Cargar invitados"),
              subtitle: const Text("Hacé click para cargar los invitados de hoy"),
              leading: const Icon(Icons.sync),
              onTap: () {
                data.updateData();
              },
            ),
          for (final guest in data.currentGuests)
            ListTile(
              title: Text(guest.name),
              subtitle: Text("${guest.id} - ${guest.typeName}"),
              onTap: () => showPersonPage(context, guest),
              trailing: isInHistory(guest.id)
                  ? const Icon(
                      Icons.check,
                      color: Colors.blue,
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}
