import 'package:diacritic/diacritic.dart';
import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:ethf_access_control_app/person_page.dart';
import 'package:flutter/material.dart';

class GlobalSearch extends SearchDelegate {
  final future = AppApi.instance.fetchIdentities();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
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
    return SearchResults(future: future, filter: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return SearchResults(future: future, filter: query);
  }
}

class SearchResults extends StatelessWidget {
  const SearchResults({super.key, required this.future, required this.filter});

  final Future<List<RemotePerson>> future;
  final String filter;

  List<RemotePerson> filterList(List<RemotePerson> people) {
    String trans(String s) {
      return removeDiacritics(s).toLowerCase().trim().replaceAll(',', '');
    }

    final filter = trans(this.filter);

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
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = filterList(snapshot.data!);

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(list[index].name),
              subtitle: Text(
                  "${list[index].id == '' ? list[index].dni.toString() : list[index].id} - ${list[index].typeName}"),
              onTap: () => showPersonPage(context, list[index]),
            );
          },
        );
      },
    );
  }
}
