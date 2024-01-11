import 'dart:typed_data';

import './core.dart';

enum MessageType {
  text,
  image,
}

class DisplayMessage {
  final MessageDirection direction;
  final MessageType type;
  final Uint8List body;
  final DateTime sentAt;
  final DateTime? receivedAt;
  final DateTime? readAt;

  DisplayMessage({
    required this.direction,
    required this.type,
    required this.body,
    required this.sentAt,
    required this.receivedAt,
    required this.readAt,
  });
}

class ParsedMessage {
  final MessageType type;
  final Uint8List body;

  ParsedMessage({
    required this.type,
    required this.body,
  });

  // Convert the object to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last, // Convert enum to string
      'body': body,
    };
  }

  // Create an object from a JSON representation
  factory ParsedMessage.fromJson(Map<String, dynamic> json) {
    return ParsedMessage(
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      body: Uint8List.fromList(List<int>.from(json['body'] as List<dynamic>)),
    );
  }
}
