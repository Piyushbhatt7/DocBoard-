import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/Screens/home_screen.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:routemaster/routemaster.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen ({Key? key}) : super(key: key);

  @override                                     
  ConsumerState<LoginScreen> createState() => _LoginScreenState();                                     
}        

class _LoginScreenState extends ConsumerState<LoginScreen> {               
  bool isLoading = false;

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final sMessanger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel = await ref.read(authRepositoryProvider).signInWithGoogle();   

    setState(() {
      isLoading = false;
    });

    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.pushReplacement('/');
    } else {
      sMessanger.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }         
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
          ? const CircularProgressIndicator()
          : ElevatedButton.icon(
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
