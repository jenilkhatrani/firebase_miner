import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var messageController = TextEditingController();
  var editingMessageId = RxnString();

  void clearMessage() {
    messageController.clear();
    editingMessageId.value = null;
  }

  void setEditingMessage(String message, String messageId) {
    messageController.text = message;
    editingMessageId.value = messageId;
  }
}
