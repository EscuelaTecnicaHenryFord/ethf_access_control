import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pretty_json/pretty_json.dart';

void showPersonPage(BuildContext context, RemotePerson person) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) {
      return PersonPage(person: person);
    },
  ));
}

class PersonPage extends StatefulWidget {
  const PersonPage({
    super.key,
    required this.person,
  });

  final RemotePerson person;

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  List<HistoryEntry> history = [];

  void fetchHistory() {
    AppApi.instance.fetchHistory().then((value) {
      setState(() {
        history = value.where((element) => element.identity == widget.person.id).toList();
      });
    });
  }

  @override
  void initState() {
    fetchHistory();
    super.initState();
  }

  bool actionLoading = false;

  Future<bool?> confirm() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Está seguro que desea registrar el ingreso de esta persona?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void handleRegisterAttendance() async {
    if (actionLoading) return;
    if (await confirm() != true) return;
    setState(() {
      actionLoading = true;
    });
    try {
      await AppApi.instance.postHistory(widget.person.id, widget.person.toJSON());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registro de ingreso exitoso")));
        providerKey.currentState?.updateHistory();
      }
    } catch (e) {
      if (kDebugMode) print(e);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() {
        actionLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyIn = history.where((element) => element.isToday).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person.name),
      ),
      floatingActionButton: !isAlreadyIn
          ? FloatingActionButton.extended(
              onPressed: actionLoading ? null : handleRegisterAttendance,
              label: const Text("Registrar ingreso"),
              icon: const Icon(Icons.done),
            )
          : null,
      body: ListView(
        children: [
          ListTile(
            title: Text(widget.person.typeName),
          ),
          if (widget.person.hasCuil)
            ListTile(
              title: const Text('CUIL'),
              subtitle: Text(widget.person.displayCuil),
            ),
          if (!widget.person.hasCuil && widget.person.hasDni)
            ListTile(
              title: const Text('DNI'),
              subtitle: Text(widget.person.displayId),
            ),
          if (history.isNotEmpty) const Divider(color: Color.fromARGB(60, 127, 127, 127)),
          if (history.isNotEmpty) const ListTile(title: Text('Historial')),
          for (final entry in history)
            ListTile(
              title: Text(DateFormat('dd/MM/yyyy HH:mm').format(entry.timestamp)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Detalles'),
                      content: Text("Datos escaneados: \n\n${prettyJson(entry.data)}"),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
