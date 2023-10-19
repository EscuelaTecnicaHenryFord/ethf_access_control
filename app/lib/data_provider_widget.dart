import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:flutter/material.dart';

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
  bool loading = true;
  List<RemotePerson> guests = [];
  List<Event> events = [];
  List<HistoryEntry> history = [];

  int lastUpdate = DateTime.now().microsecondsSinceEpoch;

  List<RemotePerson> get currentGuests {
    final list = <RemotePerson>[];
    final currentEvents = events.where((e) => e.isCurrent).toList();
    for (final guest in guests) {
      if (guest.type == PersonType.guest) {
        for (final event in guest.events) {
          if (currentEvents.any((e) => e.id == event)) {
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
    fetchData();
    super.initState();
  }

  void fetchData() async {
    final guests = await AppApi.instance.fetchGuests();
    final events = await AppApi.instance.fetchEvents();
    final history = await AppApi.instance.fetchHistory();

    setState(() {
      loading = false;
      this.guests = guests;
      this.events = events;
      this.history = history;
      lastUpdate = DateTime.now().microsecondsSinceEpoch;
    });
  }

  void update() {
    fetchData();
  }

  void updateHistory() async {
    final history = await AppApi.instance.fetchHistory();

    setState(() {
      this.history = history;
      lastUpdate = DateTime.now().microsecondsSinceEpoch;
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
