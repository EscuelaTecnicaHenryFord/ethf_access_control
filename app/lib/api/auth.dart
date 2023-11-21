import 'dart:convert';
import 'dart:io';

import 'package:ethf_access_control_app/api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SessionStatus {
  unknown,
  authenticated,
  unauthenticated,
}

Future<SharedPreferences> getPrefs() {
  return SharedPreferences.getInstance();
}

class AuthHandler {
  AuthHandler._();

  Future<String?> getSecureCookie() async {
    if (Platform.isWindows) {
      final SharedPreferences prefs = await getPrefs();
      return prefs.getString("cookie");
    }

    return await FlutterKeychain.get(key: "cookie");
  }

  Future<void> setSecureCookie(String cookie) async {
    if (Platform.isWindows) {
      final SharedPreferences prefs = await getPrefs();
      await prefs.setString("cookie", cookie);
      return;
    }

    return await FlutterKeychain.put(key: "cookie", value: cookie);
  }

  Future<void> removeSecureCookie() async {
    if (Platform.isWindows) {
      final SharedPreferences prefs = await getPrefs();
      await prefs.remove("cookie");
      return;
    }

    return await FlutterKeychain.remove(key: "cookie");
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
      if (kDebugMode) {
        print(e);
      }

      return SessionStatus.unknown;
    }

    return SessionStatus.unauthenticated;
  }

  static final AuthHandler instance = AuthHandler._();
}
