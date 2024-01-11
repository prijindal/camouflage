class ChatMessagePayload {
  final String messageId;
  final String encryptedPayload;
  final String timestamp;
  final String username;

  ChatMessagePayload({
    required this.messageId,
    required this.encryptedPayload,
    required this.timestamp,
    required this.username,
  });

  // Convert the object to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'encrypted_payload': encryptedPayload,
      'timestamp': timestamp,
      'username': username,
    };
  }

  // Create an object from a JSON representation
  factory ChatMessagePayload.fromJson(Map<String, dynamic> json) {
    return ChatMessagePayload(
      messageId: json['message_id'] as String,
      encryptedPayload: json['encrypted_payload'] as String,
      timestamp: json['timestamp'] as String,
      username: json['username'] as String,
    );
  }
}
