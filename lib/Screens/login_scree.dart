import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


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

    try {
      final sMessanger = ScaffoldMessenger.of(context);
      final navigator = Routemaster.of(context);
      final errorModel = await ref.read(authRepositoryProvider).signInWithGoogle();   

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        if (errorModel.error == null && errorModel.data != null) {
          ref.read(userProvider.notifier).update((state) => errorModel.data);
          navigator.replace('/');
        } else {
          sMessanger.showSnackBar(
            SnackBar(
              content: Text(errorModel.error ?? 'An error occurred'),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Google Docs Clone',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (kIsWeb) 
              const Text(
                'Web Version',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 20),
            isLoading
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
                    minimumSize: const Size(200, 50),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
