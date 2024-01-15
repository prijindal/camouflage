import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'core.g.dart';

// this will generate a table called "todos" for us. The rows of that table will
// be represented by a class called "Todo".

const _uuid = Uuid();

enum MessageDirection {
  sent,
  received,
}

class Message extends Table {
  TextColumn get id => text().unique()();
  TextColumn get direction => textEnum<MessageDirection>()();
  TextColumn get username => text()();
  BlobColumn get encryptedPayload => blob()();
  DateTimeColumn get sentAt => dateTime().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get deletionAt => dateTime().nullable()();
}

// this annotation tells drift to prepare a database class that uses both of the
// tables we just defined. We'll see how to use that database class in a moment.
@DriftDatabase(tables: [Message])
class SharedDatabase extends _$SharedDatabase {
  SharedDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
