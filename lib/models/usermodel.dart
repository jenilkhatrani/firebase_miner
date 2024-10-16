import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  FieldValue timestamp;

  UserModel({required this.email, required this.timestamp});
}
