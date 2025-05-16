import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:routemaster/routemaster.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref)
  {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(WidgetRef ref) async {

    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(onPressed: ()
          {

          }, icon: const Icon(Icons.add)
          ),

           IconButton(onPressed: ()
          {
            signOut(ref);
          }, icon: const Icon(Icons.logout, color: KredColor,),
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