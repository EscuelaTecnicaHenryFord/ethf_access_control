import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:flutter/material.dart';

final providerKey = GlobalKey<DataProviderWidgetState>();

class DataProvider extends InheritedWidget {
  const DataProvider({super.key, required super.child, required this.state});

  final DataProviderWidgetState state;

  static DataProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DataProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class DataProviderWidget extends StatefulWidget {
  const DataProviderWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  static DataProviderWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<DataProviderWidgetState>()!;

  @override
  State<DataProviderWidget> createState() => DataProviderWidgetState();
}

class DataProviderWidgetState extends State<DataProviderWidget> {
  bool dataLoading = false;
  bool dataLoaded = false;

  bool historyLoaded = false;
  bool historyLoading = false;

  bool identitiesLoaded = false;

  List<RemotePerson> guests = [];
  List<RemotePerson> identities = [];
  List<Event> events = [];
  List<HistoryEntry> history = [];
  Set<String> registeredGuestsToday = {};

  Map<int, RemotePerson> identitiesByDni = {};
  Map<String, RemotePerson> identitiesById = {};
  Map<String, RemotePerson> guestsById = {};

  int lastUpdate = DateTime.now().microsecondsSinceEpoch;

  List<RemotePerson> get currentGuests {
    final list = <RemotePerson>[];
    final currentEvents = events.where((e) => e.isCurrent).toList();
    for (final guest in identities) {
      if (guest.type == PersonType.guest) {
        for (final event in guest.events) {
          if (currentEvents.any((e) => e.id == event)) {
            list.add(guest);
            break;
          }
        }
      } else if (guest.type == PersonType.formerStudent) {
        for (final event in currentEvents) {
          if (event.formerStudentsInvited) {
            list.add(guest);
            break;
          }
        }
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateData() async {
    setState(() {
      dataLoading = true;
    });

    final guests = await AppApi.instance.fetchGuests();
    final events = await AppApi.instance.fetchEvents();
    final identities = await AppApi.instance.fetchIdentities();

    final identitiesByDni = <int, RemotePerson>{};

    for (final identity in identities) {
      if (identity.dni == null) continue;
      identitiesByDni[identity.dni!] = identity;
    }

    final identitiesById = <String, RemotePerson>{};

    for (final identity in identities) {
      identitiesById[identity.id] = identity;
    }

    final guestsById = <String, RemotePerson>{};

    for (final guest in guests) {
      guestsById[guest.id] = guest;
    }

    setState(() {
      dataLoading = false;
      dataLoaded = true;
      this.guests = guests;
      this.events = events;
      this.identities = identities;
      this.identitiesByDni = identitiesByDni;
      lastUpdate = DateTime.now().microsecondsSinceEpoch;
    });
  }

  Future<RemotePerson?> getIdentityByDni(int dni) async {
    if (identitiesByDni.containsKey(dni)) {
      return identitiesByDni[dni]!;
    }

    return await AppApi.instance.fetchIdentity(dni.toString());
  }

  Future<RemotePerson?> getIdentityId(String id) async {
    if (identitiesById.containsKey(id)) {
      return identitiesById[id]!;
    }

    return await AppApi.instance.fetchIdentity(id);
  }

  Future<RemotePerson?> getGuestById(String id, String event) async {
    if (guestsById.containsKey(id)) {
      return guestsById[id]!;
    }

    return await AppApi.instance.fetchGuestIdentity(id, event);
  }

  Future<List<Event>> getEvents() async {
    if (dataLoaded) {
      return events;
    }

    events = await AppApi.instance.fetchEvents();

    return events;
  }

  Future<void> updateHistory() async {
    setState(() {
      historyLoading = true;
    });

    final history = await AppApi.instance.fetchHistory();

    setState(() {
      historyLoaded = true;
      historyLoading = false;
      this.history = history;
      lastUpdate = DateTime.now().microsecondsSinceEpoch;

      for (final entry in history) {
        if (entry.isToday) {
          registeredGuestsToday.add(entry.identity);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataProvider(
      state: this,
      child: widget.child,
    );
  }
}
