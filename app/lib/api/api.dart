import 'dart:convert';

import 'package:ethf_access_control_app/api/auth.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppApi {
  AppApi._();

  Future<RemotePerson?> fetchIdentity(String id, {String? event, bool? forceCurrentEvent}) async {
    final query = <String, String>{};

    if (forceCurrentEvent != null) {
      query['force_current_event'] = forceCurrentEvent.toString();
    }

    if (event != null) {
      query['event'] = event;
    }

    final data = await jsonGet('/api/identities/$id', query.isNotEmpty ? query : null);

    if (data == null) {
      return null;
    }

    return RemotePerson.fromJson(data);
  }

  Future<List<RemotePerson>> fetchIdentities() async {
    final data = await jsonGet('/api/identities');
    if (data == null) {
      return [];
    }

    return (data as List)
        .map((e) {
          try {
            return RemotePerson.fromJson(e);
          } catch (err) {
            if (kDebugMode) {
              print("Error with: $e, $err");
            }
            return null;
          }
        })
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
  }

  Future<RemotePerson?> fetchGuestIdentity(String id, String event) async {
    final data = await jsonGet('/api/guests/$id/$event');

    if (data == null) {
      return null;
    }

    return RemotePerson.fromJson(data);
  }

  Future<List<RemotePerson>> fetchGuests() async {
    final data = await jsonGet('/api/identities', {'guests_only': 'true'});

    if (data == null) {
      return [];
    }

    return (data as List).map((e) => RemotePerson.fromJson(e)).toList();
  }

  Future<List<Event>> fetchEvents() async {
    final data = await jsonGet('/api/events');

    if (data == null) {
      return [];
    }

    final dataEvents = (data as Map<String, dynamic>)['events'] as List<dynamic>;
    final dataCurrent = data['current'] as List<dynamic>;

    final result = dataEvents.map((e) => Event.fromJson(e, dataCurrent.contains(e['id'] as String))).toList();
    result.sort((a, b) => a.startDate.compareTo(b.startDate));
    result.sort((a, b) {
      if (a.isCurrent && !b.isCurrent) return -1;
      if (!a.isCurrent && b.isCurrent) return 1;
      return 0;
    });
    return result;
  }

  Future<void> postHistory(String id, dynamic data) async {
    await jsonPost('/api/history', {
      'identity': id,
      'data': data,
    });
  }

  Future<List<HistoryEntry>> fetchHistory() async {
    final data = await jsonGet('/api/history');

    if (data == null) {
      return [];
    }

    return ((data as Map)['history'] as List).map((e) => HistoryEntry.fromJson(e)).toList();
  }

  Future<dynamic> jsonGet(String path, [Map<String, String>? query]) {
    return jsonRequest(path, query: query);
  }

  Future<dynamic> jsonPost(String path, dynamic body) {
    return jsonRequest(path, body: body, post: true);
  }

  Future<dynamic> jsonRequest(String path, {Map<String, String>? query, dynamic body, bool post = false}) async {
    final cookie = await AuthHandler.instance.getSecureCookie();

    if (cookie == null) {
      throw Exception('unauthenticated');
    }

    // Url with path and query
    final url = Uri.parse('$baseUrl$path');
    final urlWithQuery = query != null ? url.replace(queryParameters: query) : url;

    late final http.Response response;

    if (post) {
      response = await http.post(urlWithQuery, body: jsonEncode(body), headers: {
        'Accept': 'application/json',
        'Cookie': cookie,
      });
    } else {
      response = await http.get(urlWithQuery, headers: {
        'Accept': 'application/json',
        'Cookie': cookie,
      });
    }

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);

      final data = jsonDecode(body);

      return data;
    } else {
      throw Exception('api_failed');
    }
  }

  static final AppApi instance = AppApi._();
}

String get baseUrl {
  if (kDebugMode) {
    return 'http://10.0.31.28:3000';
  }

  return 'https://ethf-access-control.vercel.app';
}

class Event {
  final String id;
  final String name;
  final String description;
  final bool formerStudentsInvited;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.formerStudentsInvited = false,
  });

  factory Event.fromJson(Map<String, dynamic> json, [isCurrent = false]) {
    print(json);

    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      formerStudentsInvited: json['former_students_invited'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isCurrent: isCurrent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}

class HistoryEntry {
  final String identity;
  final DateTime timestamp;
  final dynamic data;

  HistoryEntry({
    required this.identity,
    required this.timestamp,
    required this.data,
  });

  @override
  String toString() {
    String? firstName;
    String? lastName;
    if (data is Map && data['first_name'] is String) {
      firstName = data['first_name'];
    }
    if (data is Map && data['last_name'] is String) {
      lastName = data['last_name'];
    } else if (data is Map && data['name'] is String && firstName == null) {
      lastName = data['name'];
    }

    String text = identity;

    if (lastName != null) {
      text = '$lastName - $text';
    }

    if (firstName != null && lastName == null) {
      text = '$firstName - $text';
    } else if (firstName != null && lastName != null) {
      text = '$firstName $text';
    }

    return text;
  }

  bool get isToday {
    final now = DateTime.now();
    return timestamp.day == now.day && timestamp.month == now.month && timestamp.year == now.year;
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      identity: json['identity'] ?? '---',
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'],
    );
  }
}
