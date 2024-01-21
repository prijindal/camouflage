import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:memory_cache/memory_cache.dart';

import '../encryption/key.dart';
import '../models/message.dart';

Future<ParsedMessage> decryptMessageDataHandler({
  required String messageId,
  required Uint8List encryptedPayload,
  required String remotePublicKey,
  required String publicKey,
  required String privateKey,
}) async {
  final existing = MemoryCache.instance.read<ParsedMessage>(messageId);
  if (existing != null) {
    return existing;
  }
  final sharedKey = await getSharedKey(
    publicKey: publicKey,
    privateKey: privateKey,
    remotePublicKeyString: remotePublicKey,
  );
  final unencrypted = await decryptMessage(
    sharedKey,
    encryptedPayload,
  );
  final parsed = ParsedMessage.fromJson(
    jsonDecode(unencrypted) as Map<String, dynamic>,
  );
  MemoryCache.instance.create(messageId, parsed);
  return parsed;
}
