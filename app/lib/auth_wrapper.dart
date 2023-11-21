import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:ethf_access_control_app/api/api.dart';
import 'package:ethf_access_control_app/api/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  static of(BuildContext context) => context.findAncestorStateOfType<_AuthWrapperState>()!;

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late StreamSubscription _sub;
  final _appLinks = AppLinks();

  SessionStatus status = SessionStatus.unknown;

  void setUnauthenticated() {
    setState(() {
      status = SessionStatus.unauthenticated;
    });
  }

  Future<void> _initReceiveIntentit() async {
    _sub = _appLinks.allUriLinkStream.listen((uri) {
      handleIntentUri(uri);
    });
  }

  Future<void> _initialAuthCheck() async {
    var status = await AuthHandler.instance.getSessionStatus();
    while (status == SessionStatus.unknown && context.mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Problemas autenticando. Reintentando...')));
      }

      await Future.delayed(const Duration(seconds: 1));
      status = await AuthHandler.instance.getSessionStatus();
    }

    if (!context.mounted) return;

    setState(() {
      this.status = status;
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _sub.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _initReceiveIntentit();
    _initialAuthCheck();
    super.initState();
  }

  void handleIntentUri(Uri url) async {
    final cookie = url.queryParameters['cookie'];

    if (cookie == null) return;

    final status = await AuthHandler.instance.getSessionStatus(cookie);

    if (status == SessionStatus.authenticated) {
      await AuthHandler.instance.setSecureCookie(cookie);
    }

    setState(() {
      this.status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (status == SessionStatus.authenticated) {
      return widget.child;
    }

    if (status == SessionStatus.unknown) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ChromeSafariBrowser? browser;

  void openLoginBrowser() {
    browser = MyChromeSafariBrowser();
    browser!.open(url: Uri.parse("$baseUrl/login/app"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ETHF Control de Acceso"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: openLoginBrowser,
          child: const Text("Ingresar con ETHF"),
        ),
      ),
    );
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser();
}
