import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/person_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void showPage(BuildContext context, String id) async {
    final person = await AppApi.instance.fetchIdentity(id);

    if (person == null) return;

    if (context.mounted) showPersonPage(context, person);
  }

  @override
  Widget build(BuildContext context) {
    final data = DataProvider.of(context).state;

    if (data.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: data.history.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(data.history[index].toString()),
          subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(data.history[index].timestamp)),
          onTap: () => showPage(context, data.history[index].identity),
        );
      },
    );
  }
}
