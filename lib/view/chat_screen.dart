import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/message_model.dart';
import '../viewmodel/websocket_viewmodel.dart';

class ChatScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<WebSocketViewModel>(context);

    // ✅ Auto scroll after UI build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Chat", style: TextStyle(fontSize: 16)),
                Text(
                  vm.isConnecting
                      ? "Connecting..."
                      : vm.isConnected
                      ? "Online"
                      : "Offline",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: vm.messages.length,
                itemBuilder: (context, index) {
                  final msg = vm.messages[index];
                  final isMe = msg.senderId == vm.myUserId;
                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (msg.status == MessageStatus.failed) {
                            vm.retryMessage(msg);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg.time,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                SizedBox(width: 5),

                                if (isMe) ...[
                                  if (msg.status == MessageStatus.sending)
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.white70,
                                    ),

                                  if (msg.status == MessageStatus.sent)
                                    Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white70,
                                    ),

                                  if (msg.status == MessageStatus.failed)
                                    Icon(
                                      Icons.refresh,
                                      size: 12,
                                      color: Colors.red,
                                    ),
                                ],
                              ],
                            ),

                            if (msg.status == MessageStatus.failed)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  "Tap to retry",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        vm.sendMessage(controller.text);
                        controller.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
