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
