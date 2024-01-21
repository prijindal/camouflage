import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../helpers/constants.dart';

Future<String> getMasterHash(String username, String masterKey) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: hashLength,
  );

  final secretKey = SecretKey(const Utf8Encoder().convert(username));
  final salt = const Utf8Encoder().convert(masterKey);

  final newSecretKey =
      await pbkdf2.deriveKey(secretKey: secretKey, nonce: salt);
  final newSecretKeyBytes = await newSecretKey.extractBytes();

  return base64Encode(newSecretKeyBytes);
}

String generateMasterKey() {
  var random = Random.secure();
  var values = List<int>.generate(hashLength, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

final keyShairAlgorithm = X25519();
Future<SimpleKeyPair> newKeyPair() async {
  final keyPair = await keyShairAlgorithm.newKeyPair();
  return keyPair;
}

// Here publicKey and privateKeys are from different users
Future<SecretKey> getSharedKey({
  required String publicKey,
  required String privateKey,
  required String remotePublicKeyString,
}) async {
  final remotePublicKey = SimplePublicKey(
    base64Decode(remotePublicKeyString),
    type: KeyPairType.x25519,
  );
  final keyPair = SimpleKeyPairData(
    base64Decode(privateKey),
    publicKey: SimplePublicKey(
      base64Decode(publicKey),
      type: KeyPairType.x25519,
    ),
    type: KeyPairType.x25519,
  );
  final sharedSecretKey = await keyShairAlgorithm.sharedSecretKey(
    keyPair: keyPair,
    remotePublicKey: remotePublicKey,
  );
  return sharedSecretKey;
}

Future<Uint8List> encryptMessage(SecretKey secretKey, String message) async {
  final encryptionAlgorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
  final secretBox = await encryptionAlgorithm.encrypt(
    message.codeUnits,
    secretKey: secretKey,
  );
  return secretBox.concatenation();
}

class DecryptMessageParams {
  SecretKey secretKey;
  Uint8List payload;

  DecryptMessageParams({
    required this.secretKey,
    required this.payload,
  });
}

Future<String> decryptMessage(SecretKey secretKey, Uint8List payload) async {
  return await compute<DecryptMessageParams, String>(
    (message) async {
      final encryptionAlgorithm =
          AesCbc.with256bits(macAlgorithm: Hmac.sha256());
      final secretBox = SecretBox.fromConcatenation(
        payload,
        nonceLength: 16,
        macLength: encryptionAlgorithm.macAlgorithm.macLength,
      );
      final unencrypted = await encryptionAlgorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );
      return String.fromCharCodes(unencrypted);
    },
    DecryptMessageParams(
      payload: payload,
      secretKey: secretKey,
    ),
  );
}
