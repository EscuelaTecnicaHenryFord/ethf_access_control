import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/person_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PersonInfoCard extends StatefulWidget {
  const PersonInfoCard({
    super.key,
    required this.personInfo,
    required this.data,
  });

  final DataProviderWidgetState data;
  final PersonInfo personInfo;

  static const height = 110.0;

  @override
  State<PersonInfoCard> createState() => _PersonInfoCardState();
}

class _PersonInfoCardState extends State<PersonInfoCard> {
  RemotePerson? remotePerson;
  RemotePerson? invitedBy;
  List<Event> events = [];
  bool loading = true;

  List<Event> get currentEvents => events.where((e) => e.isCurrent).toList();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    remotePerson = await AppApi.instance.fetchIdentity(widget.personInfo.dni);

    if (kDebugMode) {
      print("Found: $remotePerson");
    }

    final events = await AppApi.instance.fetchEvents();
    this.events = events;

    if (remotePerson?.type == PersonType.guest && currentEvents.isNotEmpty) {
      final r2 = await AppApi.instance.fetchGuestIdentity(widget.personInfo.dni, currentEvents.first.id);
      if (r2 != null) {
        remotePerson = r2;
      }
    }

    final invitedBy = (remotePerson != null && remotePerson!.invitedBy != null)
        ? await AppApi.instance.fetchIdentity(remotePerson!.invitedBy!)
        : null;
    this.invitedBy = invitedBy;

    if (!context.mounted) return;

    setState(() {
      loading = false;
    });
  }

  bool actionLoading = false;

  void handleRegisterAttendance() async {
    if (actionLoading || loading) return;
    actionLoading = true;
    try {
      await AppApi.instance.postHistory(widget.personInfo.dni, widget.personInfo.toJSON());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registro de ingreso exitoso")));
        providerKey.currentState?.updateHistory();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) print(e);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      actionLoading = false;
    }
  }

  void handleRegisterNewPerson() async {}

  bool isInvitedToCurrentEvent() {
    if (remotePerson == null) return false;

    if (remotePerson!.type != PersonType.guest) return true;

    final currentEvents = events.where((e) => e.isCurrent).toList();

    return remotePerson!.events.any((e) => currentEvents.any((c) => c.id == e));
  }

  Widget eventRow() {
    final children = <Widget>[];

    for (final event in events) {
      if (!remotePerson!.events.contains(event.id)) {
        continue;
      }

      children.add(
        Card(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: event.isCurrent ? Colors.blue : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              event.name,
              style: TextStyle(
                color: event.isCurrent ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 10),
      child: Row(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool isAlreadyIn = widget.data.registeredGuestsToday.contains(widget.personInfo.dni);

    String inviteLabel = 'Registar invitado';

    final isGuest = remotePerson?.type == PersonType.guest || remotePerson == null;

    if (currentEvents.length == 1) {
      inviteLabel = 'Registrar invitado a ${currentEvents.first.name}';
    }

    String notInvitedLabel = "La persona no está registrada";
    if (remotePerson != null && isGuest && remotePerson!.events.isNotEmpty) {
      notInvitedLabel = "La persona no está invitada al evento de la fecha";
    }

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
              if (invitedBy != null && isGuest && isInvitedToCurrentEvent())
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Invitado por ${invitedBy!.name} (${invitedBy!.id} - ${invitedBy!.typeName})",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              if (invitedBy == null && isGuest && isInvitedToCurrentEvent())
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Invitado por ${remotePerson!.invitedBy ?? 'desconocido'}.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              if (remotePerson != null && !isGuest)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Persona registrada como ${remotePerson!.name} (${remotePerson!.id} - ${remotePerson!.typeName})",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              if (!loading && isGuest && !isInvitedToCurrentEvent())
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    notInvitedLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                ),
              if (!loading && !isInvitedToCurrentEvent() && remotePerson != null && remotePerson!.events.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    "Invitado a otros eventos:",
                    style:
                        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                  ),
                ),
              if (!loading && isGuest && remotePerson != null) eventRow()
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
                } else if (index == 1 && !loading && remotePerson != null && !isAlreadyIn) {
                  handleRegisterAttendance();
                } else if (index == 1 && !loading && remotePerson != null && isAlreadyIn) {
                  Navigator.of(context).pop();
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
                if (!loading && isInvitedToCurrentEvent() && !isAlreadyIn)
                  const NavigationDestination(icon: Icon(Icons.done), label: 'Registrar ingreso'),
                if (!loading && isInvitedToCurrentEvent() && isAlreadyIn)
                  const NavigationDestination(icon: Icon(Icons.close), label: 'Ya ingresado'),
                if (!loading && !isInvitedToCurrentEvent())
                  NavigationDestination(icon: const Icon(Icons.person_add), label: inviteLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
