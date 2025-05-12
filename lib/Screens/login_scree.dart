import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/Screens/home_screen.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';

class LoginScree extends ConsumerStatefulWidget {
  const LoginScree ({Key? key}) : super(key: key);

  @override                                     
  ConsumerState<LoginScree> createState() => _LoginScreeState();                                     
}        

class _LoginScreeState extends ConsumerState<LoginScree> {               
  
  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessanger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorModel = await ref.read(authRepositoryProvider).signInWithGoogle();   

    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.pushReplacement( // Use pushReplacement to replace login screen
        MaterialPageRoute(builder: (context) => const HomeScreen())
      );
    } else {
      sMessanger.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }         
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(ref, context),
          icon: Image.asset(
            'assets/images/g-logo-2.png',
            height: 20,
          ),
          label: const Text(
            "Sign in with Google", 
            style: TextStyle(color: kBlackColor),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kWhiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            minimumSize: const Size(150, 50),
          ),
        ),
      ),
    );
  }
}
