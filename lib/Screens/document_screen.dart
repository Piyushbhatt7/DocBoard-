import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;

  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {

  TextEditingController titleController = TextEditingController(text: 'Untitled Document');
  quill.QuillController _controller = quill.QuillController.basic();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void updateTitle(WidgetRef ref, String title)
  {
    ref.read(documentRepositoryProvider).updateTitle(
      token: ref.read(userProvider)!
      .token, 
      id: widget.id, 
      title: title
      );
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
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(
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
                   onSubmitted: (value) {
                     updateTitle(ref, value);
                   },
                ),
              )
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: KgreyColor,
                width: 0.1,
              )
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            quill.QuillSimpleToolbar(
              controller: _controller
            ),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: kWhiteColor,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: _controller,
                               // readOnly: false
                    ),
                  ),
                ),
              ))
          ],
        ),
      ),
    );
  }
}
