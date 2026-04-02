import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/message_model.dart';

class WebSocketViewModel extends ChangeNotifier {
  late WebSocketChannel channel;
  bool isConnected = false;
  bool isConnecting = false;
  List<MessageModel> messages = [];
  String myUserId = "user_1";
  String otherUserId = "user_2";

  void connect() {
    try {
      print("Connecting...");

      channel = WebSocketChannel.connect(
        Uri.parse('wss://ws.ifelse.io'),
      );

      isConnected = true;
      notifyListeners();

      channel.stream.listen(
            (message) {
              print("Echo ignored: $message");
          notifyListeners();
        },
        onError: (error) {
          print("Error: $error");
          isConnected = false;
          notifyListeners();

          reconnect();
        },
        onDone: () {
          print("Disconnected");
          isConnected = false;
          notifyListeners();

          reconnect();
        },
      );
    } catch (e) {
      print("Connection failed");
      isConnected = false;
      notifyListeners();

      reconnect();
    }
  }

  void sendMessage(String text) {
    if (text.isEmpty) return;

    final message = MessageModel(
      text: text,
      senderId: myUserId,
      time: getCurrentTime(),
      status: MessageStatus.sending,
    );

    messages.add(message);
    notifyListeners();

    if (!isConnected) {
      message.status = MessageStatus.failed;
      notifyListeners();
      return;
    }

    channel.sink.add(text);

    Future.delayed(Duration(milliseconds: 500), () {
      message.status = MessageStatus.sent;
      notifyListeners();

      // 👇 simulate other user
      simulateOtherUserReply(text);
    });
  }

  void simulateOtherUserReply(String text) {
    String reply;

    final lowerText = text.toLowerCase().trim();

    if (lowerText == "hey" || lowerText == "hi") {
      reply = "Hi 👋";
    } else if (lowerText == "how are you?") {
      reply = "I am fine, thank you! 😊 ";
    } else if (lowerText == "how is your work going") {
      reply = "It's going good!";
    } else {
      // fallback replies
      final defaultReplies = [
        "Okay 👍",
        "Got it!",
        "Nice!",
        "Sounds good",
      ];

      reply = defaultReplies[Random().nextInt(defaultReplies.length)];
    }

    Future.delayed(Duration(seconds: 1), () {
      messages.add(
        MessageModel(
          text: reply,
          senderId: otherUserId,
          time: getCurrentTime(),
          status: MessageStatus.sent,
        ),
      );

      notifyListeners();
    });
  }
  Future<void> reconnect() async {
    if (isConnecting) return;

    isConnecting = true;
    notifyListeners();

    print("Reconnecting...");

    await Future.delayed(Duration(seconds: 2));

    try {
      connect();
    } catch (e) {
      print("Reconnect failed");
      reconnect(); // retry again
    }

    isConnecting = false;
  }

  void retryMessage(MessageModel message) {
    // ❗ Check connection first
    if (!isConnected) {
      message.status = MessageStatus.failed;
      notifyListeners();
      return;
    }

    message.status = MessageStatus.sending;
    notifyListeners();

    try {
      channel.sink.add(message.text);

      Future.delayed(Duration(milliseconds: 500), () {
        message.status = MessageStatus.sent;
        notifyListeners();
      });
    } catch (e) {
      message.status = MessageStatus.failed;
      notifyListeners();
    }
  }

  void disconnect() {
    channel.sink.close();
  }

  String getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }
}