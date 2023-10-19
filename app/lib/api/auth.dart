import 'dart:convert';

import 'package:ethf_access_control_app/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_keychain/flutter_keychain.dart';

enum SessionStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthHandler {
  AuthHandler._();

  Future<String?> getSecureCookie() {
    return FlutterKeychain.get(key: "cookie");
  }

  Future<void> setSecureCookie(String cookie) {
    return FlutterKeychain.put(key: "cookie", value: cookie);
  }

  Future<void> removeSecureCookie() {
    return FlutterKeychain.remove(key: "cookie");
  }

  Future<SessionStatus> getSessionStatus([String? testCookie]) async {
    final cookie = testCookie ?? await getSecureCookie();
    if (cookie == null) {
      return SessionStatus.unauthenticated;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/auth/session'), headers: {
        'Cookie': cookie,
      });

      final data = jsonDecode(response.body);

      if (data is Map && data['user'] is Map) {
        return SessionStatus.authenticated;
      }
    } catch (e) {
      print(e);

      return SessionStatus.unknown;
    }

    return SessionStatus.unauthenticated;
  }

  static final AuthHandler instance = AuthHandler._();
}
