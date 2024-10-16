import 'package:chat_app/utils/helpers/auth_helper.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:chat_app/views/pages/drawer_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    User? user = (args is User) ? args : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade200,
        title: const Text(
          'We Chat',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      drawer: MyDrawer(user: user!),
      body: Container(
        color: Colors.blue.shade50,
        child: StreamBuilder(
          stream: FireStoreHelper.fireStoreHelper.fetchallusers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("ERROR: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;
              List<QueryDocumentSnapshot<Map<String, dynamic>>> alldocs =
                  (data == null) ? [] : data.docs;

              return (alldocs.isEmpty)
                  ? const Center(
                      child: Text(
                        'No users available...',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: alldocs.length,
                      itemBuilder: (context, i) {
                        return (AuthHelper.firebaseAuth.currentUser!.email ==
                                alldocs[i].data()['email'])
                            ? Container()
                            : Card(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Get.toNamed('/chat_page',
                                        arguments: alldocs[i]);
                                  },
                                  title: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          alldocs[i]
                                              .data()['email']
                                              .toString()
                                              .split('@')[0],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Icon(Icons.chat,
                                            color: Colors.blue),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                      },
                    );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
