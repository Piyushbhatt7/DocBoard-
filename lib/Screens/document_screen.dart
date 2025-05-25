import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/common/widgets/loader.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:google_docs/repository/socket_repository.dart';



class DocumentScreen extends ConsumerStatefulWidget {
  final String id;

  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {

  TextEditingController titleController = TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();


  @override
  void initState() {
    // TODO: implement initState
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    super.initState();

    socketRepository.changeListener((data) {
      _controller?.compose(
        Delta.fromJson(data['delta']),
        _controller?.selection ?? const TextSelection.collapsed(offset: 0), 
        quill.ChangeSource.remote,
         );
    });
  }

  void fetchDocumentData() async {
    try {
      errorModel = await ref.read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

      if (errorModel!.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorModel!.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (errorModel!.data != null) {
        titleController.text = (errorModel!.data as DocumentModel).title;
        _controller = quill.QuillController(
          document: errorModel!.data.content.isEmpty
          ? quill.Document()
          : quill.Document.fromJson(errorModel!.data.content),
          selection: const TextSelection.collapsed(offset: 0),
        );
        if (mounted) {
          setState(() {});
        }

        _controller!.document.changes.listen((event)
        {
          // 1-> entire content of document
          // 2-> changes that are made from previous part
          // 3-> local? -> we have typed remote?

          if(event.item3 == quill.ChangeSource.local)
          {
            Map<String, dynamic> map = {
              'delta': event.item2,
              'room': widget.id,
            };
            socketRepository.typing(map);
          }
        });
      }
    } 
    
    catch (e) {
      print('Error in fetchDocumentData: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void updateTitle(WidgetRef ref, String title) async {
    if (title.trim().isEmpty) {
      return;
    }

    try {
      final errorModel = await ref.read(documentRepositoryProvider).updateTitle(
        token: ref.read(userProvider)!.token, 
        id: widget.id, 
        title: title
      );

      if (errorModel.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorModel.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Update the local title controller
        titleController.text = title;
        // Refresh the document data after updating the title
        fetchDocumentData();
      }
    } catch (e) {
      print('Error in updateTitle: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating title: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Example: Accessing a provider
    // final myValue = ref.watch(myProvider);
    if(_controller == null)
    {
      return const Scaffold(
        body: Loader(),
      );
    }
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
                    if (value.trim().isNotEmpty) {
                      updateTitle(ref, value);
                    }
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
              controller: _controller!
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
                      controller: _controller!,
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
