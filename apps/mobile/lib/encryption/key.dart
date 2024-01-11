import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../helpers/constants.dart';

Future<String> getMasterHash(String username, String master_key) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: ITERATIONS,
    bits: HASH_LENGTH,
  );

  final secretKey = SecretKey(const Utf8Encoder().convert(username));
  final salt = const Utf8Encoder().convert(master_key);

  final newSecretKey =
      await pbkdf2.deriveKey(secretKey: secretKey, nonce: salt);
  final newSecretKeyBytes = await newSecretKey.extractBytes();

  return base64Encode(newSecretKeyBytes);
}

String generateMasterKey() {
  var random = Random.secure();
  var values = List<int>.generate(HASH_LENGTH, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

final algorithm = X25519();
Future<SimpleKeyPair> newKeyPair() async {
  final keyPair = await algorithm.newKeyPair();
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
  final sharedSecretKey = await algorithm.sharedSecretKey(
    keyPair: keyPair,
    remotePublicKey: remotePublicKey,
  );
  return sharedSecretKey;
}

Future<String> encryptMessage(SecretKey secretKey, String message) async {
  final algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
  final secretBox = await algorithm.encrypt(
    message.codeUnits,
    secretKey: secretKey,
  );
  return base64Encode(secretBox.concatenation());
}

Future<String> decryptMessage(SecretKey secretKey, String payload) async {
  final algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
  final secretBox = SecretBox.fromConcatenation(
    base64Decode(payload),
    nonceLength: 16,
    macLength: algorithm.macAlgorithm.macLength,
  );
  final unencrypted = await algorithm.decrypt(
    secretBox,
    secretKey: secretKey,
  );
  return String.fromCharCodes(unencrypted);
}
