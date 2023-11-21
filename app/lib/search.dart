import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:ethf_access_control_app/data_provider_widget.dart';
import 'package:ethf_access_control_app/person_page.dart';
import 'package:ethf_access_control_app/scan_dni_dialog.dart';
import 'package:flutter/material.dart';

Future<List<RemotePerson>> getIdentities() async {
  final provider = providerKey.currentState;
  if (provider == null || !provider.dataLoaded) {
    return await AppApi.instance.fetchIdentities();
  }

  return provider.identities;
}

class GlobalSearch extends SearchDelegate {
  GlobalSearch({
    this.onResultTap,
  });

  final future = getIdentities();

  final Function(RemotePerson person)? onResultTap;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.qr_code_scanner_rounded),
        onPressed: () {
          showScanDniDialog(context).then((person) {
            if (person != null) {
              query = "${person.displayName} ${person.dni}";
            }
          });
        },
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchResults(
      future: future,
      filter: query,
      onResultTap: onResultTap,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return SearchResults(
      future: future,
      filter: query,
      onResultTap: onResultTap,
    );
  }
}

class SearchResults extends StatefulWidget {
  const SearchResults({super.key, required this.future, required this.filter, this.onResultTap});

  final Future<List<RemotePerson>> future;
  final String filter;

  final Function(RemotePerson person)? onResultTap;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  Timer? timeout;

  List<RemotePerson> list = [];

  bool shouldWriteMoreCharacters = false;

  bool loading = true;

  List<RemotePerson>? snapShotData;

  void calculateResults(List<RemotePerson> data) {
    if (widget.filter.length < 3) {
      setState(() {
        list = [];
        shouldWriteMoreCharacters = true;
      });
      return;
    }

    setState(() {
      list = filterList(data);
      shouldWriteMoreCharacters = false;
    });
  }

  @override
  void initState() {
    super.initState();

    widget.future.then((value) {
      snapShotData = value;
      calculateResults(value);
      setState(() {
        loading = false;
      });
    });
  }

  @override
  didUpdateWidget(SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.filter != widget.filter) {
      timeout?.cancel();

      if (snapShotData == null) return;

      timeout = Timer(const Duration(milliseconds: 300), () {
        timeout?.cancel();
        setState(() {
          calculateResults(snapShotData!);
        });
      });
    }
  }

  List<RemotePerson> filterList(List<RemotePerson> people) {
    String trans(String s) {
      return removeDiacritics(s).toLowerCase().trim().replaceAll(',', '');
    }

    final filter = trans(widget.filter);

    if (filter.isEmpty) {
      return people;
    }

    final words = filter.split(' ').where((element) => element.isNotEmpty).toList();

    final matchLevels = people.map((p) {
      int level = 10;

      if (trans(p.name).contains(filter)) level++;
      if (trans(p.displayCuil).contains(filter)) level++;
      if (p.invitedBy != null && trans(p.invitedBy!).contains(filter)) level++;
      if (p.username != null && trans(p.username!).contains(filter)) level++;

      if (level == 10) {
        level = 0;

        for (final word in words) {
          if (trans(p.name).contains(word)) level++;
          if (trans(p.displayCuil).contains(word)) level++;
          if (p.invitedBy != null && trans(p.invitedBy!).contains(word)) level++;
          if (p.username != null && trans(p.username!).contains(word)) level++;
        }
      }

      return (p, level);
    }).toList();

    matchLevels.sort((a, b) => b.$2.compareTo(a.$2));

    return matchLevels.where((element) => element.$2 > 0).map((e) => e.$1).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shouldWriteMoreCharacters) {
      return const Center(child: Text("Escriba al menos 3 caracteres"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index].name),
          subtitle:
              Text("${list[index].id == '' ? list[index].dni.toString() : list[index].id} - ${list[index].typeName}"),
          onTap: () {
            if (widget.onResultTap != null) {
              widget.onResultTap!(list[index]);
              Navigator.of(context).pop();
              return;
            }

            showPersonPage(context, list[index]);
          },
        );
      },
    );
  }
}
