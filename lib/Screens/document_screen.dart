import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;

  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  @override
  Widget build(BuildContext context) {
    // Example: Accessing a provider
    // final myValue = ref.watch(myProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 5,
        actions: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton.icon(
                    onPressed: () {
          
                    }, 
                    icon: Icon(Icons.lock, color: kWhiteColor, size: 16,),
                    label: const Text('Share', style: TextStyle(color: kWhiteColor),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
        ),
                ],
      ),
      body: Center(
        child: Text(
          widget.id,
        ),
      ),
    );
  }
}
