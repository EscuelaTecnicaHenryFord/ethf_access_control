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

  Future<dynamic> jsonGet(String path, [Map<String, String>? query]) async {
    final cookie = await AuthHandler.instance.getSecureCookie();

    if (cookie == null) {
      throw Exception('unauthenticated');
    }

    // Url with path and query
    final url = Uri.parse('$baseUrl$path');
    final urlWithQuery = query != null ? url.replace(queryParameters: query) : url;

    final response = await http.get(urlWithQuery, headers: {
      'Accept': 'application/json',
      'Cookie': cookie,
    });

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
  });

  factory Event.fromJson(Map<String, dynamic> json, [isCurrent = false]) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
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
