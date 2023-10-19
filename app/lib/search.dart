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
    if (filter.isEmpty) {
      return people;
    }

    String trans(String s) {
      return removeDiacritics(s).toLowerCase().trim();
    }

    return people.where((p) {
      if (trans(p.name).contains(trans(filter))) return true;
      if (trans(p.displayCuil).contains(trans(filter))) return true;
      if (p.invitedBy != null && trans(p.invitedBy!).contains(trans(filter))) return true;
      if (p.username != null && trans(p.username!).contains(filter.toLowerCase())) return true;
      return false;
    }).toList();
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
              subtitle: Text(list[index].id),
              onTap: () => showPersonPage(context, list[index]),
            );
          },
        );
      },
    );
  }
}
