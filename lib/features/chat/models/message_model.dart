
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String messageType;
  final Map<String, dynamic> metadata;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.messageType = 'text',
    this.metadata = const {},
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];

    return MessageModel(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      senderId: json['sender_id'].toString(),
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ),
      isRead: json['is_read'] == true,
      messageType: json['message_type']?.toString() ?? 'text',
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'message_type': messageType,
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
    );
  }
}
