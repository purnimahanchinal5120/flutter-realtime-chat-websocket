enum MessageStatus { sending, sent, failed }

class MessageModel {
  final String text;
  final String senderId;
  final String time;
  MessageStatus status;

  MessageModel({
    required this.text,
    required this.senderId,
    required this.time,
    this.status = MessageStatus.sending,
  });
}