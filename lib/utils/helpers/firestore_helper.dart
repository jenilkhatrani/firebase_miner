import 'package:chat_app/models/usermodel.dart';
import 'package:chat_app/utils/helpers/auth_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper {
  FireStoreHelper._();

  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();
  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<void> addUser({required UserModel userModel}) async {
    bool isUserExists = false;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection('users').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    allDocs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      String email = doc.data()['email'];

      if (email == userModel.email) {
        isUserExists = true;
      }
    });

    if (isUserExists == false) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firebaseFirestore.collection('records').doc('users').get();

      int id = documentSnapshot.data()!['id'];
      int counter = documentSnapshot.data()!['counter'];

      id = id + 1;
      await firebaseFirestore.collection('users').doc('$id').set({
        'email': userModel.email,
        'timestamp': userModel.timestamp,
      });

      await firebaseFirestore
          .collection('records')
          .doc('users')
          .update({'id': id, 'counter': ++counter});
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchallusers() {
    return firebaseFirestore.collection('users').snapshots();
  }

  Future<void> sendmessage(
      {required String msg, required String receiverEmail}) async {
    String? senderEmail = AuthHelper.firebaseAuth.currentUser!.email;

    bool isChatRoomExists = false;
    String? docId;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection('chatrooms').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List user = chatroom.data()['users'];

      if (user.contains(senderEmail) && user.contains(receiverEmail)) {
        isChatRoomExists = true;
        docId = chatroom.id;
      }
    });

    if (isChatRoomExists == false) {
      DocumentReference<Map<String, dynamic>> docRef =
          await firebaseFirestore.collection('chatrooms').add({
        "users": [
          receiverEmail,
          senderEmail,
        ]
      });
      docId = docRef.id;
    }
    firebaseFirestore
        .collection('chatrooms')
        .doc(docId)
        .collection('messages')
        .add({
      "msg": msg,
      "sentby": senderEmail,
      "receivedby": receiverEmail,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchallmessages(
      {required String receiverEmail}) async {
    String? senderEmail = AuthHelper.firebaseAuth.currentUser!.email;

    String? docId;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection('chatrooms').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List user = chatroom.data()['users'];

      if (user.contains(senderEmail) && user.contains(receiverEmail)) {
        docId = chatroom.id;
      }
    });
    Stream<QuerySnapshot<Map<String, dynamic>>> allmessages = firebaseFirestore
        .collection('chatrooms')
        .doc(docId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return allmessages;
  }

  Future<void> deleteMessage(
      {required String receiverEmail, required String messageId}) async {
    String? senderEmail = AuthHelper.firebaseAuth.currentUser!.email;

    String? chatId;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection('chatrooms').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List user = chatroom.data()['users'];

      if (user.contains(senderEmail) && user.contains(receiverEmail)) {
        chatId = chatroom.id;
      }
    });

    firebaseFirestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> editMessage(
      {required String receiverEmail,
      required String messageId,
      required String msg}) async {
    String? senderEmail = AuthHelper.firebaseAuth.currentUser!.email;

    String? chatId;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection('chatrooms').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List user = chatroom.data()['users'];

      if (user.contains(senderEmail) && user.contains(receiverEmail)) {
        chatId = chatroom.id;
      }
    });

    firebaseFirestore
        .collection('chatrooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'msg': msg});
  }
}
