import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_docs/colors.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    Key? key, 
    required this.id
    }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {

  TextEditingController titleController = TextEditingController(text: 'Untitled Document');
  final quill.QuillController _controller = quill.QuillController.basic();


 @override
 void dispose() {
   titleController.dispose();
   super.dispose();
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(onPressed: (){}, 
            icon: Icon(Icons.lock, size: 16, color: kWhiteColor,),
            label: const Text('Share', style: TextStyle(
              color: kWhiteColor
            ),),
            style: ElevatedButton.styleFrom(
            backgroundColor: KblueColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            ),
          )
          )
        ],

        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/brand_image.png',
                height: 60,
                //fit: BoxFit.cover,
              ),
          
              const SizedBox(width: 10.0,),
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
                    contentPadding: EdgeInsets.only(left: 10.0),
                  ),
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
          )
          ),
      ),

      body: Column(
        children: [
          quill.QuillSimpleToolbar(
          controller: _controller
          ),
          Expanded(
            child: Container(
              child: quill.QuillEditor.basic(
                controller: _controller,
                
              ),
            ),
          )
        ],
      ),
    );
  }
}