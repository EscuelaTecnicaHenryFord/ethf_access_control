import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:ethf_access_control_app/person_info.dart';
import 'package:flutter/material.dart';

class PersonInfoCard extends StatefulWidget {
  const PersonInfoCard({
    super.key,
    required this.personInfo,
  });

  final PersonInfo personInfo;

  static const height = 110.0;

  @override
  State<PersonInfoCard> createState() => _PersonInfoCardState();
}

class _PersonInfoCardState extends State<PersonInfoCard> {
  RemotePerson? remotePerson;
  RemotePerson? invitedBy;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    final remotePerson = await fetchIdentity(widget.personInfo.cuil);
    final invitedBy = remotePerson != null ? await fetchIdentity(remotePerson.invitedBy!) : null;

    if (!context.mounted) return;

    setState(() {
      this.remotePerson = remotePerson;
      this.invitedBy = invitedBy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 270,
      width: double.infinity,
      child: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                child: Text(
                  widget.personInfo.displayName,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (invitedBy != null)
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    "Invitado por ${invitedBy!.name} (${invitedBy!.id})",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavigationBar(
              onDestinationSelected: (index) {
                if (index == 0) {
                  Navigator.of(context).pop();
                }
              },
              selectedIndex: 1,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.cancel), label: 'Cancelar'),
                NavigationDestination(icon: Icon(Icons.done), label: 'Registrar ingreso'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
