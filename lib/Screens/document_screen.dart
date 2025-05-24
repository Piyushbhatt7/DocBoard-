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

  TextEditingController titleController = TextEditingController(text: 'Untitled Document');

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Example: Accessing a provider
    // final myValue = ref.watch(myProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.lock, color: kWhiteColor, size: 16),
              label: const Text('Share', style: TextStyle(color: kWhiteColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: KblueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
        title: Row(
          children: [
            Image.asset('assets/images/brand_image.png', height: 50, fit: BoxFit.fill,),

            const SizedBox(width: 10,),

            SizedBox(
              width: 180,
              child: TextField(
                controller: titleController,
                 decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: KblueColor, 
                    )
                  ),
                  contentPadding: EdgeInsets.only(left: 10.0)
                 ),
              ),
            )
          ],
        ),
      ),
      body: Center(child: Text(widget.id)),
    );
  }
}
