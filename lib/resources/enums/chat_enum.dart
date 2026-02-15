enum MessageStatus { sent, delivered, read, failed, unknown }

extension MessageStatusX on MessageStatus {
  static MessageStatus fromString(String? status) {
    switch (status) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.unknown;
    }
  }

  String get value {
    switch (this) {
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
      case MessageStatus.unknown:
        return 'unknown';
    }
  }
}
