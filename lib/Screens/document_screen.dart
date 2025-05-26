import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/common/widgets/loader.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:google_docs/repository/socket_repository.dart';
import 'package:routemaster/routemaster.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController = TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;
  final FocusNode _focusNode = FocusNode();
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    print('Initializing DocumentScreen for ID: ${widget.id}');
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListener((data) {
      print('Received socket change: $data');
      if (_controller != null) {
        try {
          final String content = data['content'] as String;
          if (content != _controller!.document.toPlainText()) {
            _controller!.document = quill.Document()..insert(0, content);
          }
        } catch (e) {
          print('Error handling content: $e');
          print('Problematic data: ${data['content']}');
        }
      } else {
        print('Controller is null when receiving socket change');
      }
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_controller != null) {
        final String content = _controller!.document.toPlainText();
        print('Auto-saving document with content: $content');
        socketRepository.autoSave(<String, dynamic>{
          'content': content,
          'room': widget.id,
        });
      }
    });
  }

  void fetchDocumentData() async {
    print('Fetching document data for ID: ${widget.id}');
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );

    if (errorModel!.data != null) {
      print('Document data received: ${errorModel!.data.content}');
      titleController.text = (errorModel!.data as DocumentModel).title;
      
      // Initialize QuillController with content
      final String content = errorModel!.data.content.isEmpty 
          ? '' 
          : errorModel!.data.content;
      
      print('Initializing QuillController with content: $content');
      
      _controller = quill.QuillController(
        document: quill.Document()..insert(0, content),
        selection: const TextSelection.collapsed(offset: 0),
      );

      // Set up document change listener
      _controller!.document.changes.listen((event) {
        if (event.source == quill.ChangeSource.local) {
          // Debounce the changes to avoid too many updates
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 500), () {
            final String content = _controller!.document.toPlainText();
            print('Sending content update: $content');
            Map<String, dynamic> map = {
              'content': content,
              'room': widget.id,
            };
            socketRepository.typing(map);
          });
        }
      });

      setState(() {});
    } else {
      print('Error fetching document: ${errorModel!.error}');
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    _controller?.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateTitle(
          token: ref.read(userProvider)!.token,
          id: widget.id,
          title: title,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Loader());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 'http://localhost:3000/#/document/${widget.id}')).then(
                  (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Link copied!',
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.lock,
                size: 16,
              ),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KblueColor,
              ),
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace('/');
                },
                child: Image.asset(
                  'assets/images/docs-logo.png',
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: KblueColor,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  onSubmitted: (value) => updateTitle(ref, value),
                ),
              ),
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
              ),
            ),
          ),
        ),
      ),
         body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            quill.QuillToolbar.basic(
              controller: _controller!,
              showAlignmentButtons: true,
              multiRowsDisplay: false,
            ),
            const SizedBox(height: 10),
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