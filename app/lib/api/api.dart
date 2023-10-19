import 'dart:convert';

import 'package:ethf_access_control_app/api/auth.dart';
import 'package:ethf_access_control_app/api/remote_person.dart';
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

    final data = await jsonGet('/api/identity/$id', query.isNotEmpty ? query : null);

    if (data == null) {
      return null;
    }

    return RemotePerson.fromJson(data);
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

const baseUrl = 'http://192.168.0.137:3000';
