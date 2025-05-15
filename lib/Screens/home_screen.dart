import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/repository/auth_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: ()
          {

          }, icon: const Icon(Icons.add)
          ),

           IconButton(onPressed: ()
          {

          }, icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: 
        Text(ref.watch(userProvider)!.email),
      ),
    );
  }
}