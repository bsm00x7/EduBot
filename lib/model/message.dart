// Message model for better data structure
class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final String? imagePath;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
    this.imagePath,
  });

  // Copy constructor for modifications
  Message copyWith({
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    String? imagePath,
  }) {
    return Message(
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

enum MessageType { text, image, error, system }