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
        title: Row(
          children: [
            Text("Chat"),
            SizedBox(width: 10),

            if (vm.isConnecting)
              Text("Connecting...", style: TextStyle(color: Colors.orange))
            else
              Icon(
                Icons.circle,
                size: 10,
                color: vm.isConnected ? Colors.green : Colors.red,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: vm.messages.length,
              itemBuilder: (context, index) {
                final msg = vm.messages[index];

                return Align(
                  alignment: msg.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                      msg.isMe ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: msg.isMe
                            ? Radius.circular(16)
                            : Radius.circular(0),
                        bottomRight: msg.isMe
                            ? Radius.circular(0)
                            : Radius.circular(16),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (msg.status == MessageStatus.failed) {
                          vm.retryMessage(msg);
                        }
                      },
                      child: Column(
                        crossAxisAlignment:
                        msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isMe ? Colors.white : Colors.black,
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
                                  color: msg.isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              SizedBox(width: 5),

                              if (msg.isMe) ...[
                                if (msg.status == MessageStatus.sending)
                                  Icon(Icons.access_time, size: 12, color: Colors.white70),

                                if (msg.status == MessageStatus.sent)
                                  Icon(Icons.check, size: 12, color: Colors.white70),

                                if (msg.status == MessageStatus.failed)
                                  Icon(Icons.refresh, size: 12, color: Colors.red),
                              ],
                            ],
                          ),

                          if (msg.status == MessageStatus.failed)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                "Tap to retry",
                                style: TextStyle(fontSize: 10, color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    )
                  ),
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration:
                  InputDecoration(hintText: "Enter message"),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  vm.sendMessage(controller.text);
                  controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}