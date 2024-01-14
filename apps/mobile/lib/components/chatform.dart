import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/http.dart';
import '../models/message.dart';

class ChatForm extends StatefulWidget {
  const ChatForm({
    super.key,
    required this.user,
  });
  final UserResponse user;

  @override
  State<ChatForm> createState() => _ChatFormState();
}

class _ChatFormState extends State<ChatForm> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  Future<void> _sendChatMessage() async {
    final coreApi = Provider.of<CoreApi>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      final body = Uint8List.fromList(_textController.text.codeUnits);
      _textController.clear();
      await coreApi.sendMessage(
        payload: ParsedMessage(
          type: MessageType.text,
          body: body,
        ),
        username: widget.user.username,
        publicKey: widget.user.publicKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter some text";
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              onPressed: _sendChatMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
