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

  List<RemotePerson> guests = [];
  List<RemotePerson> identities = [];
  List<Event> events = [];
  List<HistoryEntry> history = [];
  Set<String> registeredGuestsToday = {};

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

    setState(() {
      dataLoading = false;
      dataLoaded = true;
      this.guests = guests;
      this.events = events;
      this.identities = identities;
      lastUpdate = DateTime.now().microsecondsSinceEpoch;
    });
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
