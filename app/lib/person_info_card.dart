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
  bool loading = true;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    final remotePerson = await AppApi.instance.fetchIdentity(widget.personInfo.cuil);
    final invitedBy = remotePerson != null ? await AppApi.instance.fetchIdentity(remotePerson.invitedBy!) : null;

    if (!context.mounted) return;

    setState(() {
      this.remotePerson = remotePerson;
      this.invitedBy = invitedBy;
      loading = false;
    });
  }

  void handleRegisterAttendance() async {}

  void handleRegisterNewPerson() async {}

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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Invitado por ${invitedBy!.name} (${invitedBy!.id})",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              if (invitedBy == null && !loading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "La persona no está registrada para el evento de la fecha",
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                } else if (index == 1 && !loading && remotePerson != null) {
                  handleRegisterAttendance();
                } else if (index == 1 && !loading && remotePerson == null) {
                  handleRegisterNewPerson();
                }
              },
              selectedIndex: 1,
              destinations: [
                const NavigationDestination(icon: Icon(Icons.cancel), label: 'Cancelar'),
                if (loading)
                  const NavigationDestination(
                    icon: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                    label: 'Registrar ingreso',
                  ),
                if (!loading && remotePerson != null)
                  const NavigationDestination(icon: Icon(Icons.done), label: 'Registrar ingreso'),
                if (!loading && remotePerson == null)
                  const NavigationDestination(icon: Icon(Icons.person_add), label: 'Registar invitado'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
