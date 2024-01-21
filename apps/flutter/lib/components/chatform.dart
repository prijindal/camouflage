import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _picker = ImagePicker();

  bool get _cameraAvailable {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<void> _sendMessage({
    required MessageType type,
    required Uint8List body,
  }) async {
    final coreApi = Provider.of<CoreApi>(context, listen: false);
    await coreApi.sendMessage(
      payload: ParsedMessage(
        type: type,
        body: body,
      ),
      username: widget.user.username,
      publicKey: widget.user.publicKey,
    );
  }

  Future<void> _sendTextMessage() async {
    if (_formKey.currentState!.validate()) {
      final body = Uint8List.fromList(_textController.text.codeUnits);
      _textController.clear();
      await _sendMessage(body: body, type: MessageType.text);
    }
  }

  Future<Uint8List?> _takeProfilePicture() async {
    if (!_cameraAvailable) return null;
    final image = await _picker.pickImage(source: ImageSource.camera);
    return image?.readAsBytes();
  }

  Future<Uint8List?> _selectProfilePicture() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.readAsBytes();
  }

  Future<void> _selectImage() async {
    final image = await showDialog<Uint8List?>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          if (_cameraAvailable)
            ListTile(
              title: const Text("Take a picture"),
              onTap: () async {
                final image = await _takeProfilePicture();
                if (context.mounted) {
                  Navigator.of(context).pop<Uint8List?>(image);
                }
              },
            ),
          ListTile(
            title: const Text("Select an image"),
            onTap: () async {
              final image = await _selectProfilePicture();
              if (context.mounted) {
                Navigator.of(context).pop<Uint8List?>(image);
              }
            },
          ),
          ListTile(
            title: Text("Cancel"),
            onTap: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
    if (image != null) {
      await _sendMessage(type: MessageType.image, body: image);
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
              onPressed: () => _selectImage(),
              icon: const Icon(Icons.image),
            ),
            IconButton(
              onPressed: _sendTextMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
