import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/person_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  void showPage(BuildContext context, String id) async {
    final person = await AppApi.instance.fetchIdentity(id);

    if (person == null) return;

    if (context.mounted) showPersonPage(context, person);
  }

  @override
  Widget build(BuildContext context) {
    final data = DataProvider.of(context).state;

    if (data.dataLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.historyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SmartRefresher(
      onRefresh: () async {
        await data.updateHistory();
        refreshController.refreshCompleted();
      },
      controller: refreshController,
      child: data.historyLoaded
          ? ListView.builder(
              itemCount: data.history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data.history[index].toString()),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(data.history[index].timestamp)),
                  onTap: () => showPage(context, data.history[index].identity),
                );
              },
            )
          : ListView(
              children: [
                ListTile(
                  title: const Text("Cargar historial"),
                  subtitle: const Text("Hacé click para cargar el historial de hoy"),
                  leading: const Icon(Icons.sync),
                  onTap: () {
                    data.updateHistory();
                  },
                ),
              ],
            ),
    );
  }
}
