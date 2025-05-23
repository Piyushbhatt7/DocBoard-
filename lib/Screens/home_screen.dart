import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/common/widgets/loader.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:routemaster/routemaster.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void signOut(WidgetRef ref)
  {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel = await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text(errorModel.error ?? 'Failed to create document'),
        ),
      );
    }
  }

  void navigateToDocument(BuildContext context, String documentId)
  {
    Routemaster.of(context).push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          IconButton(onPressed: ()
          {
            createDocument(context, ref);
          }, icon: const Icon(Icons.add)
          ),

           IconButton(onPressed: ()
          {
            signOut(ref);
          }, icon: const Icon(Icons.logout, color: KredColor,),
          ),
        ],
      ),
      body:FutureBuilder <ErrorModel?>(
        future: ref.watch(documentRepositoryProvider)
        .getDocument(
          ref.watch(userProvider)!.token), 

        builder: (context, snapshot)
        {
          if(snapshot.connectionState == ConnectionState.waiting)
          {
            return const Loader();
          }

          if (snapshot.data?.data == null || snapshot.data!.data.isEmpty) {
            return const Center(child: Text('No documents available.'));
          }

          return Center(
            child: SizedBox(
              width: 600,
              child: ListView.builder(
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index)
                {
                  DocumentModel document = snapshot.data!.data[index];
              
                  return InkWell(
                    onTap: () {
                      navigateToDocument(context, document.id);
                    },
                    child: SizedBox(
                      height: 50,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side:  BorderSide(
                           // color: Colors.black,
                           // width: 1
                          ),
                         // borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            document.title, style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                ),
            ),
          );
        }
        )
    );
  }
}