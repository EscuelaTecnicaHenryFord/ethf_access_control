import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/person_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataProvider.of(context).state;

    if (data.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    bool isInHistory(String id) {
      return data.registeredGuestsToday.contains(id);
    }

    return ListView(
      children: [
        const ListTile(title: Text("Invitados")),
        for (final guest in data.currentGuests)
          ListTile(
            title: Text(guest.name),
            subtitle: Text(guest.id),
            onTap: () => showPersonPage(context, guest),
            trailing: isInHistory(guest.id)
                ? const Icon(
                    Icons.check,
                    color: Colors.blue,
                  )
                : null,
          ),
      ],
    );
  }
}
