import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/message_model.dart';

class WebSocketViewModel extends ChangeNotifier {
  late WebSocketChannel channel;
  bool isConnected = false;
  bool isConnecting = false;
  List<MessageModel> messages = [];

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
          messages.add(
            MessageModel(
              text: message.toString(),
              isMe: false,
              time: getCurrentTime(),
            ),
          );

          notifyListeners();
        },
        onError: (error) {
          print("Error: $error");
          isConnected = false;
          notifyListeners();

          reconnect(); // 🔥 retry
        },
        onDone: () {
          print("Disconnected");
          isConnected = false;
          notifyListeners();

          reconnect(); // 🔥 retry
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
      isMe: true,
      time: getCurrentTime(),
      status: MessageStatus.sending,
    );

    messages.add(message);
    notifyListeners();

    // ❗ Check connection before sending
    if (!isConnected) {
      message.status = MessageStatus.failed;
      notifyListeners();
      return;
    }

    try {
      channel.sink.add(text);

      Future.delayed(Duration(milliseconds: 500), () {
        message.status = MessageStatus.sent;
        notifyListeners();
      });
    } catch (e) {
      message.status = MessageStatus.failed;
      notifyListeners();
    }
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