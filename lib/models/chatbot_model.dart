enum MessageType {
  user,
  bot,
  system,
  error,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
}

class ChatMessage {
  final String id;
  final String sender;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.status,
    this.metadata,
    this.isRead = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      sender: map['sender'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      type: MessageType.values.firstWhere(
            (e) => e.toString() == 'MessageType.${map['type']}',
        orElse: () => MessageType.user,
      ),
      status: MessageStatus.values.firstWhere(
            (e) => e.toString() == 'MessageStatus.${map['status']}',
        orElse: () => MessageStatus.sent,
      ),
      metadata: map['metadata'],
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'metadata': metadata,
      'isRead': isRead,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sender,
    String? message,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
    );
  }
}