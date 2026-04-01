enum MessageStatus { sending, sent, failed }

class MessageModel {
  final String text;
  final bool isMe;
  final String time;
  MessageStatus status;

  MessageModel({
    required this.text,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.sending,
  });
}