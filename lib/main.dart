import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/Screens/router.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp()
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
  

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: RoutemasterDelegate(routesBuilder: (BuildContext context) { 
          final user = ref.watch(userProvider);
          if(user!=null && user.token.isNotEmpty) {
            return loggedInRoute;
          }
          return loggedOutRoute;
       }),
     routeInformationParser: const RoutemasterParser(),
    );
  }
}


