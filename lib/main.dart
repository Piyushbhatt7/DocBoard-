 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/Screens/login_scree.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';

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

ErrorModel? errorModel;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();

  }

  void getUserData() async
  {
    errorModel = await ref.read(authRepositoryProvider).getUserData();

    if(errorModel!= null && errorModel!.data != null){
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScree(), 
    );
  }
}

