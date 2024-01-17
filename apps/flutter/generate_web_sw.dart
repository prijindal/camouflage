import 'dart:io';

void main(List<String> args) async {
  final firebaseOptionsFile = File("./lib/firebase_options.dart");

  final firebaseOptionsContent = await firebaseOptionsFile.readAsString();

  final file = File("./web/firebase-messaging-sw.js");

  String content = await file.readAsString();

  final keys = [
    "apiKey",
    "appId",
    "messagingSenderId",
    "projectId",
    "authDomain",
    "storageBucket"
  ];

  for (final key in keys) {
    final exp = RegExp("$key: '([A-Za-z0-9:.-]*)'");

    final match = exp.firstMatch(firebaseOptionsContent);
    if (match != null) {
      final value = match.group(1);

      content = content.replaceAll("{{$key}}", value!);
    }
  }

  await file.writeAsString(content);
}
