import 'dart:convert';

import 'package:ethf_access_control_app/api/remote_person.dart';
import 'package:http/http.dart' as http;

Future<RemotePerson?> fetchIdentity(String id) async {
  final response = await http.get(Uri.parse('http://10.0.31.28:3000/api/identity/$id'));

  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);

    final data = jsonDecode(body);

    if (data == null) {
      return null;
    }

    return RemotePerson.fromJson(data);
  } else {
    throw Exception('Failed to load person');
  }
}
