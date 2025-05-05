import 'package:flutter/material.dart';

class LoginScree extends StatefulWidget {
  const LoginScree({super.key});

  @override
  State<LoginScree> createState() => _LoginScreeState();
}

class _LoginScreeState extends State<LoginScree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: (){}, 
          icon: Image.asset(
            'assets/images/g-logo-2.png',
            height: 20,
          ),
          label: const Text("Sign in with Google"),
          style: ElevatedButton.styleFrom(
            
          ),
          ),
      ),
    );
  }
}
