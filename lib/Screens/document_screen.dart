import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/models/document_model.dart';

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    titleController.addListener(_onTitleChanged);
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final token = ref.read(userProvider)?.token;
    if (token == null) return;

    final errorModel = await ref.read(documentRepositoryProvider).getDocumentById(token, widget.id);
    
    if (errorModel.error == null && errorModel.data != null) {
      if (mounted) {
        setState(() {
          titleController.text = errorModel.data.title;
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorModel.error ?? 'Failed to load document')),
        );
      }
    }
  }

  void _onTitleChanged() {
    if (_isSaving) return;
    _isSaving = true;
    
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      final token = ref.read(userProvider)?.token;
      if (token == null) return;

      final errorModel = await ref.read(documentRepositoryProvider).updateTitle(
        token: token,
        id: widget.id,
        title: titleController.text,
      );

      if (errorModel.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorModel.error!)),
          );
        }
      }
      
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    });
  }

  @override
  void dispose() {
    titleController.removeListener(_onTitleChanged);
    titleController.dispose();
    super.dispose();
    _controller.dispose();
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

      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10.0,
            ),
            quill.QuillSimpleToolbar(
            controller: _controller
            ),
            Expanded(
              child: Container(
                child: SizedBox(
                  width: 750,
                  child: Card(
                    color: kWhiteColor,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: quill.QuillEditor.basic(
                        controller: _controller,
                        
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}