import 'package:chat_app/utils/helpers/auth_helper.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:super_context_menu/super_context_menu.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  String? editingMessageId;

  @override
  Widget build(BuildContext context) {
    QueryDocumentSnapshot<Map<String, dynamic>> data = ModalRoute.of(context)!
        .settings
        .arguments as QueryDocumentSnapshot<Map<String, dynamic>>;

    String receiverEmail = data.data()['email'];

    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 10,
            child: FutureBuilder(
              future: FireStoreHelper.fireStoreHelper
                  .fetchallmessages(receiverEmail: receiverEmail),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('ERROR ${snapshot.error}');
                } else if (snapshot.hasData) {
                  Stream<QuerySnapshot<Map<String, dynamic>>>? data =
                      snapshot.data;

                  return StreamBuilder(
                      stream: data,
                      builder: (context, ss) {
                        if (snapshot.hasError) {
                          return Text('ERROR ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          QuerySnapshot<Map<String, dynamic>>? message =
                              ss.data;

                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              alldocs = (message == null) ? [] : message.docs;

                          return (alldocs.isEmpty)
                              ? const Center(
                                  child: Text('No chat available'),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  reverse: true,
                                  itemCount: alldocs.length,
                                  itemBuilder: (context, index) {
                                    bool isSentByCurrentUser = AuthHelper
                                            .firebaseAuth.currentUser!.email ==
                                        alldocs[index].data()['sentby'];

                                    return Row(
                                      mainAxisAlignment: isSentByCurrentUser
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        isSentByCurrentUser
                                            ? ContextMenuWidget(
                                                menuProvider:
                                                    (MenuRequest request) {
                                                  return Menu(children: [
                                                    MenuAction(
                                                        callback: () {
                                                          messageController
                                                              .text = alldocs[
                                                                  index]
                                                              .data()['msg'];
                                                          setState(() {
                                                            editingMessageId =
                                                                alldocs[index]
                                                                    .id;
                                                          });
                                                        },
                                                        title: 'Edit'),
                                                    MenuAction(
                                                        callback: () async {
                                                          await FireStoreHelper
                                                              .fireStoreHelper
                                                              .deleteMessage(
                                                                  receiverEmail:
                                                                      receiverEmail,
                                                                  messageId:
                                                                      alldocs[index]
                                                                          .id);
                                                        },
                                                        attributes:
                                                            const MenuActionAttributes(
                                                                destructive:
                                                                    true),
                                                        title: 'Delete'),
                                                  ]);
                                                },
                                                child: MessageBubble(
                                                  message: alldocs[index]
                                                      .data()['msg'],
                                                  isSentByCurrentUser:
                                                      isSentByCurrentUser,
                                                ),
                                              )
                                            : MessageBubble(
                                                message: alldocs[index]
                                                    .data()['msg'],
                                                isSentByCurrentUser:
                                                    isSentByCurrentUser,
                                              ),
                                      ],
                                    );
                                  });
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      });
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Message',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Circular shape
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                fillColor: Colors.grey.shade200, // Background color
                filled: true, // Show the background color
                suffixIcon: IconButton(
                  onPressed: () async {
                    if (editingMessageId != null) {
                      await FireStoreHelper.fireStoreHelper.editMessage(
                        receiverEmail: receiverEmail,
                        messageId: editingMessageId!,
                        msg: messageController.text,
                      );
                      editingMessageId = null;
                    } else {
                      await FireStoreHelper.fireStoreHelper.sendmessage(
                        msg: messageController.text,
                        receiverEmail: receiverEmail,
                      );
                    }
                    messageController.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSentByCurrentUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isSentByCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color messageBackground = isSentByCurrentUser
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;
    final Color textColor =
        isSentByCurrentUser ? Colors.white : theme.colorScheme.onSecondary;

    return Align(
      alignment:
          isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: messageBackground,
          borderRadius: isSentByCurrentUser
              ? const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  topRight: Radius.circular(0),
                  bottomRight: Radius.circular(16),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(16),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
