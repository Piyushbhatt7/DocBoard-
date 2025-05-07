import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/repository/auth_repository.dart';

class LoginScree extends ConsumerStatefulWidget {
  const LoginScree ({Key? key}) : super(key: key);

  
  @override   
  ConsumerState<LoginScree> createState() => _LoginScreeState();    
} 

class _LoginScreeState extends ConsumerState<LoginScree> {

  void signInWithGoogle(WidgetRef ref)
  {
    ref.read(authRepositoryProvider).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authRepositoryProvider).signInWithGoogle();
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(ref),      
          icon: Image.asset( 
            'assets/images/g-logo-2.png',      
            height: 20,  
          ),
          label: const Text(
            "Sign in with Google", 
            style: TextStyle(
            color: kBlackColor
          ),),
          style: ElevatedButton.styleFrom(
            backgroundColor: kWhiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.grey,
                width: 1.5
              )
            ),
           minimumSize: const Size(150, 50)
          ),
          ),
      ),
    );
  }
}
