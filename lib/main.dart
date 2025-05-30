import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/Screens/router.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check for existing user data when app starts
    Future.microtask(
      () => ref.read(authRepositoryProvider).getUserData().then((errorModel) {
        if (errorModel.error == null && errorModel.data != null) {
          ref.read(userProvider.notifier).update((state) => errorModel.data);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Google Docs Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (BuildContext context) {
          final user = ref.watch(userProvider);
          if (user != null && user.token.isNotEmpty) {
            return loggedInRoute;
          }
          return loggedOutRoute;
        },
      ),
      routeInformationParser: const RoutemasterParser(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
    );
  }
}
