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

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    final guests = await AppApi.instance.fetchGuests();
    final events = await AppApi.instance.fetchEvents();

    setState(() {
      loading = false;
      this.guests = guests;
      this.events = events;
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
