// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core.dart';

// ignore_for_file: type=lint
class $MessageTable extends Message with TableInfo<$MessageTable, MessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumnWithTypeConverter<MessageDirection, String>
      direction = GeneratedColumn<String>('direction', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<MessageDirection>($MessageTable.$converterdirection);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encryptedPayloadMeta =
      const VerificationMeta('encryptedPayload');
  @override
  late final GeneratedColumn<Uint8List> encryptedPayload =
      GeneratedColumn<Uint8List>('encrypted_payload', aliasedName, false,
          type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _receivedAtMeta =
      const VerificationMeta('receivedAt');
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
      'received_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deletionAtMeta =
      const VerificationMeta('deletionAt');
  @override
  late final GeneratedColumn<DateTime> deletionAt = GeneratedColumn<DateTime>(
      'deletion_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        direction,
        username,
        encryptedPayload,
        sentAt,
        receivedAt,
        readAt,
        deletionAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message';
  @override
  VerificationContext validateIntegrity(Insertable<MessageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    context.handle(_directionMeta, const VerificationResult.success());
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('encrypted_payload')) {
      context.handle(
          _encryptedPayloadMeta,
          encryptedPayload.isAcceptableOrUnknown(
              data['encrypted_payload']!, _encryptedPayloadMeta));
    } else if (isInserting) {
      context.missing(_encryptedPayloadMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    }
    if (data.containsKey('received_at')) {
      context.handle(
          _receivedAtMeta,
          receivedAt.isAcceptableOrUnknown(
              data['received_at']!, _receivedAtMeta));
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    if (data.containsKey('deletion_at')) {
      context.handle(
          _deletionAtMeta,
          deletionAt.isAcceptableOrUnknown(
              data['deletion_at']!, _deletionAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      direction: $MessageTable.$converterdirection.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      encryptedPayload: attachedDatabase.typeMapping.read(
          DriftSqlType.blob, data['${effectivePrefix}encrypted_payload'])!,
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at']),
      receivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}received_at']),
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
      deletionAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deletion_at']),
    );
  }

  @override
  $MessageTable createAlias(String alias) {
    return $MessageTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageDirection, String, String>
      $converterdirection =
      const EnumNameConverter<MessageDirection>(MessageDirection.values);
}

class MessageData extends DataClass implements Insertable<MessageData> {
  final String id;
  final MessageDirection direction;
  final String username;
  final Uint8List encryptedPayload;
  final DateTime? sentAt;
  final DateTime? receivedAt;
  final DateTime? readAt;
  final DateTime? deletionAt;
  const MessageData(
      {required this.id,
      required this.direction,
      required this.username,
      required this.encryptedPayload,
      this.sentAt,
      this.receivedAt,
      this.readAt,
      this.deletionAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['direction'] =
          Variable<String>($MessageTable.$converterdirection.toSql(direction));
    }
    map['username'] = Variable<String>(username);
    map['encrypted_payload'] = Variable<Uint8List>(encryptedPayload);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    if (!nullToAbsent || receivedAt != null) {
      map['received_at'] = Variable<DateTime>(receivedAt);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || deletionAt != null) {
      map['deletion_at'] = Variable<DateTime>(deletionAt);
    }
    return map;
  }

  MessageCompanion toCompanion(bool nullToAbsent) {
    return MessageCompanion(
      id: Value(id),
      direction: Value(direction),
      username: Value(username),
      encryptedPayload: Value(encryptedPayload),
      sentAt:
          sentAt == null && nullToAbsent ? const Value.absent() : Value(sentAt),
      receivedAt: receivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAt),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
      deletionAt: deletionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletionAt),
    );
  }

  factory MessageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageData(
      id: serializer.fromJson<String>(json['id']),
      direction: $MessageTable.$converterdirection
          .fromJson(serializer.fromJson<String>(json['direction'])),
      username: serializer.fromJson<String>(json['username']),
      encryptedPayload:
          serializer.fromJson<Uint8List>(json['encryptedPayload']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      receivedAt: serializer.fromJson<DateTime?>(json['receivedAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      deletionAt: serializer.fromJson<DateTime?>(json['deletionAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'direction': serializer
          .toJson<String>($MessageTable.$converterdirection.toJson(direction)),
      'username': serializer.toJson<String>(username),
      'encryptedPayload': serializer.toJson<Uint8List>(encryptedPayload),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'receivedAt': serializer.toJson<DateTime?>(receivedAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'deletionAt': serializer.toJson<DateTime?>(deletionAt),
    };
  }

  MessageData copyWith(
          {String? id,
          MessageDirection? direction,
          String? username,
          Uint8List? encryptedPayload,
          Value<DateTime?> sentAt = const Value.absent(),
          Value<DateTime?> receivedAt = const Value.absent(),
          Value<DateTime?> readAt = const Value.absent(),
          Value<DateTime?> deletionAt = const Value.absent()}) =>
      MessageData(
        id: id ?? this.id,
        direction: direction ?? this.direction,
        username: username ?? this.username,
        encryptedPayload: encryptedPayload ?? this.encryptedPayload,
        sentAt: sentAt.present ? sentAt.value : this.sentAt,
        receivedAt: receivedAt.present ? receivedAt.value : this.receivedAt,
        readAt: readAt.present ? readAt.value : this.readAt,
        deletionAt: deletionAt.present ? deletionAt.value : this.deletionAt,
      );
  @override
  String toString() {
    return (StringBuffer('MessageData(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('username: $username, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('sentAt: $sentAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('readAt: $readAt, ')
          ..write('deletionAt: $deletionAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      direction,
      username,
      $driftBlobEquality.hash(encryptedPayload),
      sentAt,
      receivedAt,
      readAt,
      deletionAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageData &&
          other.id == this.id &&
          other.direction == this.direction &&
          other.username == this.username &&
          $driftBlobEquality.equals(
              other.encryptedPayload, this.encryptedPayload) &&
          other.sentAt == this.sentAt &&
          other.receivedAt == this.receivedAt &&
          other.readAt == this.readAt &&
          other.deletionAt == this.deletionAt);
}

class MessageCompanion extends UpdateCompanion<MessageData> {
  final Value<String> id;
  final Value<MessageDirection> direction;
  final Value<String> username;
  final Value<Uint8List> encryptedPayload;
  final Value<DateTime?> sentAt;
  final Value<DateTime?> receivedAt;
  final Value<DateTime?> readAt;
  final Value<DateTime?> deletionAt;
  final Value<int> rowid;
  const MessageCompanion({
    this.id = const Value.absent(),
    this.direction = const Value.absent(),
    this.username = const Value.absent(),
    this.encryptedPayload = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.deletionAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageCompanion.insert({
    required String id,
    required MessageDirection direction,
    required String username,
    required Uint8List encryptedPayload,
    this.sentAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.deletionAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        direction = Value(direction),
        username = Value(username),
        encryptedPayload = Value(encryptedPayload);
  static Insertable<MessageData> custom({
    Expression<String>? id,
    Expression<String>? direction,
    Expression<String>? username,
    Expression<Uint8List>? encryptedPayload,
    Expression<DateTime>? sentAt,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? readAt,
    Expression<DateTime>? deletionAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (direction != null) 'direction': direction,
      if (username != null) 'username': username,
      if (encryptedPayload != null) 'encrypted_payload': encryptedPayload,
      if (sentAt != null) 'sent_at': sentAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (readAt != null) 'read_at': readAt,
      if (deletionAt != null) 'deletion_at': deletionAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageCompanion copyWith(
      {Value<String>? id,
      Value<MessageDirection>? direction,
      Value<String>? username,
      Value<Uint8List>? encryptedPayload,
      Value<DateTime?>? sentAt,
      Value<DateTime?>? receivedAt,
      Value<DateTime?>? readAt,
      Value<DateTime?>? deletionAt,
      Value<int>? rowid}) {
    return MessageCompanion(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      username: username ?? this.username,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      sentAt: sentAt ?? this.sentAt,
      receivedAt: receivedAt ?? this.receivedAt,
      readAt: readAt ?? this.readAt,
      deletionAt: deletionAt ?? this.deletionAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
          $MessageTable.$converterdirection.toSql(direction.value));
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (encryptedPayload.present) {
      map['encrypted_payload'] = Variable<Uint8List>(encryptedPayload.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (deletionAt.present) {
      map['deletion_at'] = Variable<DateTime>(deletionAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageCompanion(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('username: $username, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('sentAt: $sentAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('readAt: $readAt, ')
          ..write('deletionAt: $deletionAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SharedDatabase extends GeneratedDatabase {
  _$SharedDatabase(QueryExecutor e) : super(e);
  late final $MessageTable message = $MessageTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [message];
}
