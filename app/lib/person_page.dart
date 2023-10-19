import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:flutter/material.dart';

void showPersonPage(RemotePerson person) {}

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person.name),
      ),
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
        ],
      ),
    );
  }
}
