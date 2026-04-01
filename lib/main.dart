import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/chat_screen.dart';
import 'viewmodel/websocket_viewmodel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final WebSocketViewModel vm = WebSocketViewModel();

  @override
  Widget build(BuildContext context) {
    vm.connect(); // 🔥 start connection

    return ChangeNotifierProvider(
      create: (_) => vm,
      child: MaterialApp(
        home: ChatScreen(),
      ),
    );
  }
}