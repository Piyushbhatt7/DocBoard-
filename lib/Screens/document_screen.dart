import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/repository/socket_repository.dart';
import 'dart:convert';
import 'dart:async';

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
  late quill.QuillController _controller;
  bool _isSaving = false;
  final SocketRepository socketRepository = SocketRepository();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController.basic();
    socketRepository.joinRoom(widget.id);
    titleController.addListener(_onTitleChanged);
    _loadDocument();
    _setupSocketListeners();

    socketRepository.changeListener((data)=> null);
  }

  void _setupSocketListeners() {
    print('Setting up socket listeners for document: ${widget.id}');
    
    socketRepository.changeListener((data) {
      print('Received socket change: $data');
      if (data['type'] == 'content') {
        final content = data['content'];
        if (content != null) {
          try {
            print('Parsing document content: $content');
            final doc = quill.Document.fromJson(content);
            if (mounted) {
              setState(() {
                _controller.document = doc;
                print('Document updated with new content');
              });
            }
          } catch (e) {
            print('Error parsing document content: $e');
          }
        }
      }
    });

    _controller.document.changes.listen((event) {
      if (!mounted) return;
      
      // Cancel any existing timer
      _debounceTimer?.cancel();
      
      // Set a new timer
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        final content = _controller.document.toDelta().toJson();
        print('Auto-saving document content: $content');
        
        // Save to server
        _saveDocument(content);
        
        // Save to socket for real-time updates
        socketRepository.autoSave({
          'type': 'content',
          'content': content,
          'documentId': widget.id,
        });
      });
    });
  }

  Future<void> _saveDocument(List<dynamic> content) async {
    final token = ref.read(userProvider)?.token;
    if (token == null) {
      print('No token available for saving document');
      return;
    }

    try {
      final errorModel = await ref.read(documentRepositoryProvider).updateDocument(
        token: token,
        id: widget.id,
        content: content,
      );

      if (errorModel.error != null) {
        print('Error saving document: ${errorModel.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving document: ${errorModel.error}')),
          );
        }
      } else {
        print('Document saved successfully');
      }
    } catch (e) {
      print('Exception while saving document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving document: $e')),
        );
      }
    }
  }

  Future<void> _loadDocument() async {
    print('Loading document: ${widget.id}');
    final token = ref.read(userProvider)?.token;
    if (token == null) {
      print('No token available');
      return;
    }

    final errorModel = await ref.read(documentRepositoryProvider).getDocumentById(token, widget.id);
    
    if (errorModel.error == null && errorModel.data != null) {
      print('Document loaded successfully: ${errorModel.data.title}');
      if (mounted) {
        setState(() {
          titleController.text = errorModel.data.title;
          if (errorModel.data.content.isNotEmpty) {
            try {
              print('Loading document content: ${errorModel.data.content}');
              final doc = quill.Document.fromJson(errorModel.data.content);
              _controller.document = doc;
              print('Document content loaded successfully');
            } catch (e) {
              print('Error loading document content: $e');
              _controller.document = quill.Document();
            }
          } else {
            print('No content found, initializing empty document');
            _controller.document = quill.Document();
          }
        });
      }
    } else {
      print('Error loading document: ${errorModel.error}');
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
    _debounceTimer?.cancel();
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
            child: ElevatedButton.icon(
              onPressed: (){}, 
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
            const SizedBox(height: 10.0),
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