import 'package:flutter/material.dart';
import 'package:google_docs/Screens/login_scree.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {

  '/': (route) => const MaterialPage(child: LoginScreen())
});