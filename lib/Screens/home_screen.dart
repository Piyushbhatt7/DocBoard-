import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/common/widgets/loader.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Change from final to late to allow reassignment
  late UniqueKey _refreshKey = UniqueKey();

  void signOut() {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument() async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel = await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      // Force refresh the document list
      setState(() {
        _refreshKey = UniqueKey();
      });
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text(errorModel.error ?? 'Failed to create document'),
        ),
      );
    }
  }

  void navigateToDocument(String documentId) async {
    await Routemaster.of(context).push('/document/$documentId');
    // Force refresh the document list when returning
    if (mounted) {
      setState(() {
        _refreshKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: createDocument,
            icon: const Icon(Icons.add)
          ),
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout, color: KredColor,),
          ),
        ],
      ),
      body: FutureBuilder<ErrorModel?>(
        key: _refreshKey, // Add key to force rebuild
        future: ref.watch(documentRepositoryProvider)
          .getDocument(ref.watch(userProvider)!.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          if (snapshot.data?.data == null || snapshot.data!.data.isEmpty) {
            return const Center(child: Text('No documents available.'));
          }

          return RefreshIndicator(
            onRefresh: () async {        
              if (mounted) {
                setState(() { 
                  _refreshKey = UniqueKey();
                });
              }
            },
            child: Center(
              child: SizedBox(
                width: 600,
                child: ListView.builder(
                  itemCount: snapshot.data!.data.length,
                  itemBuilder: (context, index) {
                    DocumentModel document = snapshot.data!.data[index];
                
                    return InkWell(
                      onTap: () => navigateToDocument(document.id),
                      child: SizedBox(
                        height: 50,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(),
                          ),
                          child: Center(
                            child: Text(
                              document.title,
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          );
        }
      )
    );
  }
}