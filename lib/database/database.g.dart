// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $OfflineSyncQueueTable extends OfflineSyncQueue
    with TableInfo<$OfflineSyncQueueTable, OfflineSyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineSyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncTableNameMeta = const VerificationMeta(
    'syncTableName',
  );
  @override
  late final GeneratedColumn<String> syncTableName = GeneratedColumn<String>(
    'sync_table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncTableName,
    recordId,
    operation,
    data,
    status,
    retryCount,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineSyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_table_name')) {
      context.handle(
        _syncTableNameMeta,
        syncTableName.isAcceptableOrUnknown(
          data['sync_table_name']!,
          _syncTableNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncTableNameMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineSyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineSyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncTableName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_table_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $OfflineSyncQueueTable createAlias(String alias) {
    return $OfflineSyncQueueTable(attachedDatabase, alias);
  }
}

class OfflineSyncQueueData extends DataClass
    implements Insertable<OfflineSyncQueueData> {
  final int id;
  final String syncTableName;
  final String recordId;
  final String operation;
  final String data;
  final int status;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const OfflineSyncQueueData({
    required this.id,
    required this.syncTableName,
    required this.recordId,
    required this.operation,
    required this.data,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sync_table_name'] = Variable<String>(syncTableName);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['data'] = Variable<String>(data);
    map['status'] = Variable<int>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  OfflineSyncQueueCompanion toCompanion(bool nullToAbsent) {
    return OfflineSyncQueueCompanion(
      id: Value(id),
      syncTableName: Value(syncTableName),
      recordId: Value(recordId),
      operation: Value(operation),
      data: Value(data),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory OfflineSyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineSyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      syncTableName: serializer.fromJson<String>(json['syncTableName']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      data: serializer.fromJson<String>(json['data']),
      status: serializer.fromJson<int>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncTableName': serializer.toJson<String>(syncTableName),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'data': serializer.toJson<String>(data),
      'status': serializer.toJson<int>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  OfflineSyncQueueData copyWith({
    int? id,
    String? syncTableName,
    String? recordId,
    String? operation,
    String? data,
    int? status,
    int? retryCount,
    DateTime? createdAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => OfflineSyncQueueData(
    id: id ?? this.id,
    syncTableName: syncTableName ?? this.syncTableName,
    recordId: recordId ?? this.recordId,
    operation: operation ?? this.operation,
    data: data ?? this.data,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  OfflineSyncQueueData copyWithCompanion(OfflineSyncQueueCompanion data) {
    return OfflineSyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      syncTableName: data.syncTableName.present
          ? data.syncTableName.value
          : this.syncTableName,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      data: data.data.present ? data.data.value : this.data,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSyncQueueData(')
          ..write('id: $id, ')
          ..write('syncTableName: $syncTableName, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncTableName,
    recordId,
    operation,
    data,
    status,
    retryCount,
    createdAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineSyncQueueData &&
          other.id == this.id &&
          other.syncTableName == this.syncTableName &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.data == this.data &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class OfflineSyncQueueCompanion extends UpdateCompanion<OfflineSyncQueueData> {
  final Value<int> id;
  final Value<String> syncTableName;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> data;
  final Value<int> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const OfflineSyncQueueCompanion({
    this.id = const Value.absent(),
    this.syncTableName = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.data = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  OfflineSyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String syncTableName,
    required String recordId,
    required String operation,
    required String data,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  }) : syncTableName = Value(syncTableName),
       recordId = Value(recordId),
       operation = Value(operation),
       data = Value(data);
  static Insertable<OfflineSyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? syncTableName,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? data,
    Expression<int>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncTableName != null) 'sync_table_name': syncTableName,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (data != null) 'data': data,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  OfflineSyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? syncTableName,
    Value<String>? recordId,
    Value<String>? operation,
    Value<String>? data,
    Value<int>? status,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? syncedAt,
  }) {
    return OfflineSyncQueueCompanion(
      id: id ?? this.id,
      syncTableName: syncTableName ?? this.syncTableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncTableName.present) {
      map['sync_table_name'] = Variable<String>(syncTableName.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('syncTableName: $syncTableName, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalUserConfigTable extends LocalUserConfig
    with TableInfo<$LocalUserConfigTable, LocalUserConfigData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mockModeMeta = const VerificationMeta(
    'mockMode',
  );
  @override
  late final GeneratedColumn<bool> mockMode = GeneratedColumn<bool>(
    'mock_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mock_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificationAutoRecordEnabledMeta =
      const VerificationMeta('notificationAutoRecordEnabled');
  @override
  late final GeneratedColumn<bool> notificationAutoRecordEnabled =
      GeneratedColumn<bool>(
        'notification_auto_record_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notification_auto_record_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _accessibilityAutoRecordEnabledMeta =
      const VerificationMeta('accessibilityAutoRecordEnabled');
  @override
  late final GeneratedColumn<bool> accessibilityAutoRecordEnabled =
      GeneratedColumn<bool>(
        'accessibility_auto_record_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("accessibility_auto_record_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _smsListenEnabledMeta = const VerificationMeta(
    'smsListenEnabled',
  );
  @override
  late final GeneratedColumn<bool> smsListenEnabled = GeneratedColumn<bool>(
    'sms_listen_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sms_listen_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationListenEnabledMeta =
      const VerificationMeta('notificationListenEnabled');
  @override
  late final GeneratedColumn<bool> notificationListenEnabled =
      GeneratedColumn<bool>(
        'notification_listen_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notification_listen_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _monthlyBudgetMeta = const VerificationMeta(
    'monthlyBudget',
  );
  @override
  late final GeneratedColumn<double> monthlyBudget = GeneratedColumn<double>(
    'monthly_budget',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _categoryOrderMeta = const VerificationMeta(
    'categoryOrder',
  );
  @override
  late final GeneratedColumn<String> categoryOrder = GeneratedColumn<String>(
    'category_order',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _categoryUsageMeta = const VerificationMeta(
    'categoryUsage',
  );
  @override
  late final GeneratedColumn<String> categoryUsage = GeneratedColumn<String>(
    'category_usage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    phone,
    token,
    mockMode,
    notificationAutoRecordEnabled,
    accessibilityAutoRecordEnabled,
    smsListenEnabled,
    notificationListenEnabled,
    monthlyBudget,
    categoryOrder,
    categoryUsage,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_config';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUserConfigData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    }
    if (data.containsKey('mock_mode')) {
      context.handle(
        _mockModeMeta,
        mockMode.isAcceptableOrUnknown(data['mock_mode']!, _mockModeMeta),
      );
    }
    if (data.containsKey('notification_auto_record_enabled')) {
      context.handle(
        _notificationAutoRecordEnabledMeta,
        notificationAutoRecordEnabled.isAcceptableOrUnknown(
          data['notification_auto_record_enabled']!,
          _notificationAutoRecordEnabledMeta,
        ),
      );
    }
    if (data.containsKey('accessibility_auto_record_enabled')) {
      context.handle(
        _accessibilityAutoRecordEnabledMeta,
        accessibilityAutoRecordEnabled.isAcceptableOrUnknown(
          data['accessibility_auto_record_enabled']!,
          _accessibilityAutoRecordEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sms_listen_enabled')) {
      context.handle(
        _smsListenEnabledMeta,
        smsListenEnabled.isAcceptableOrUnknown(
          data['sms_listen_enabled']!,
          _smsListenEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notification_listen_enabled')) {
      context.handle(
        _notificationListenEnabledMeta,
        notificationListenEnabled.isAcceptableOrUnknown(
          data['notification_listen_enabled']!,
          _notificationListenEnabledMeta,
        ),
      );
    }
    if (data.containsKey('monthly_budget')) {
      context.handle(
        _monthlyBudgetMeta,
        monthlyBudget.isAcceptableOrUnknown(
          data['monthly_budget']!,
          _monthlyBudgetMeta,
        ),
      );
    }
    if (data.containsKey('category_order')) {
      context.handle(
        _categoryOrderMeta,
        categoryOrder.isAcceptableOrUnknown(
          data['category_order']!,
          _categoryOrderMeta,
        ),
      );
    }
    if (data.containsKey('category_usage')) {
      context.handle(
        _categoryUsageMeta,
        categoryUsage.isAcceptableOrUnknown(
          data['category_usage']!,
          _categoryUsageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUserConfigData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserConfigData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      ),
      mockMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mock_mode'],
      )!,
      notificationAutoRecordEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_auto_record_enabled'],
      )!,
      accessibilityAutoRecordEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}accessibility_auto_record_enabled'],
      )!,
      smsListenEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sms_listen_enabled'],
      )!,
      notificationListenEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_listen_enabled'],
      )!,
      monthlyBudget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_budget'],
      )!,
      categoryOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_order'],
      )!,
      categoryUsage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_usage'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalUserConfigTable createAlias(String alias) {
    return $LocalUserConfigTable(attachedDatabase, alias);
  }
}

class LocalUserConfigData extends DataClass
    implements Insertable<LocalUserConfigData> {
  final int id;
  final String? userId;
  final String? phone;
  final String? token;
  final bool mockMode;
  final bool notificationAutoRecordEnabled;
  final bool accessibilityAutoRecordEnabled;
  final bool smsListenEnabled;
  final bool notificationListenEnabled;
  final double monthlyBudget;
  final String categoryOrder;
  final String categoryUsage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalUserConfigData({
    required this.id,
    this.userId,
    this.phone,
    this.token,
    required this.mockMode,
    required this.notificationAutoRecordEnabled,
    required this.accessibilityAutoRecordEnabled,
    required this.smsListenEnabled,
    required this.notificationListenEnabled,
    required this.monthlyBudget,
    required this.categoryOrder,
    required this.categoryUsage,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    map['mock_mode'] = Variable<bool>(mockMode);
    map['notification_auto_record_enabled'] = Variable<bool>(
      notificationAutoRecordEnabled,
    );
    map['accessibility_auto_record_enabled'] = Variable<bool>(
      accessibilityAutoRecordEnabled,
    );
    map['sms_listen_enabled'] = Variable<bool>(smsListenEnabled);
    map['notification_listen_enabled'] = Variable<bool>(
      notificationListenEnabled,
    );
    map['monthly_budget'] = Variable<double>(monthlyBudget);
    map['category_order'] = Variable<String>(categoryOrder);
    map['category_usage'] = Variable<String>(categoryUsage);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalUserConfigCompanion toCompanion(bool nullToAbsent) {
    return LocalUserConfigCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      token: token == null && nullToAbsent
          ? const Value.absent()
          : Value(token),
      mockMode: Value(mockMode),
      notificationAutoRecordEnabled: Value(notificationAutoRecordEnabled),
      accessibilityAutoRecordEnabled: Value(accessibilityAutoRecordEnabled),
      smsListenEnabled: Value(smsListenEnabled),
      notificationListenEnabled: Value(notificationListenEnabled),
      monthlyBudget: Value(monthlyBudget),
      categoryOrder: Value(categoryOrder),
      categoryUsage: Value(categoryUsage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalUserConfigData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserConfigData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      phone: serializer.fromJson<String?>(json['phone']),
      token: serializer.fromJson<String?>(json['token']),
      mockMode: serializer.fromJson<bool>(json['mockMode']),
      notificationAutoRecordEnabled: serializer.fromJson<bool>(
        json['notificationAutoRecordEnabled'],
      ),
      accessibilityAutoRecordEnabled: serializer.fromJson<bool>(
        json['accessibilityAutoRecordEnabled'],
      ),
      smsListenEnabled: serializer.fromJson<bool>(json['smsListenEnabled']),
      notificationListenEnabled: serializer.fromJson<bool>(
        json['notificationListenEnabled'],
      ),
      monthlyBudget: serializer.fromJson<double>(json['monthlyBudget']),
      categoryOrder: serializer.fromJson<String>(json['categoryOrder']),
      categoryUsage: serializer.fromJson<String>(json['categoryUsage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String?>(userId),
      'phone': serializer.toJson<String?>(phone),
      'token': serializer.toJson<String?>(token),
      'mockMode': serializer.toJson<bool>(mockMode),
      'notificationAutoRecordEnabled': serializer.toJson<bool>(
        notificationAutoRecordEnabled,
      ),
      'accessibilityAutoRecordEnabled': serializer.toJson<bool>(
        accessibilityAutoRecordEnabled,
      ),
      'smsListenEnabled': serializer.toJson<bool>(smsListenEnabled),
      'notificationListenEnabled': serializer.toJson<bool>(
        notificationListenEnabled,
      ),
      'monthlyBudget': serializer.toJson<double>(monthlyBudget),
      'categoryOrder': serializer.toJson<String>(categoryOrder),
      'categoryUsage': serializer.toJson<String>(categoryUsage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalUserConfigData copyWith({
    int? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> token = const Value.absent(),
    bool? mockMode,
    bool? notificationAutoRecordEnabled,
    bool? accessibilityAutoRecordEnabled,
    bool? smsListenEnabled,
    bool? notificationListenEnabled,
    double? monthlyBudget,
    String? categoryOrder,
    String? categoryUsage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalUserConfigData(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    phone: phone.present ? phone.value : this.phone,
    token: token.present ? token.value : this.token,
    mockMode: mockMode ?? this.mockMode,
    notificationAutoRecordEnabled:
        notificationAutoRecordEnabled ?? this.notificationAutoRecordEnabled,
    accessibilityAutoRecordEnabled:
        accessibilityAutoRecordEnabled ?? this.accessibilityAutoRecordEnabled,
    smsListenEnabled: smsListenEnabled ?? this.smsListenEnabled,
    notificationListenEnabled:
        notificationListenEnabled ?? this.notificationListenEnabled,
    monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    categoryOrder: categoryOrder ?? this.categoryOrder,
    categoryUsage: categoryUsage ?? this.categoryUsage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalUserConfigData copyWithCompanion(LocalUserConfigCompanion data) {
    return LocalUserConfigData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      phone: data.phone.present ? data.phone.value : this.phone,
      token: data.token.present ? data.token.value : this.token,
      mockMode: data.mockMode.present ? data.mockMode.value : this.mockMode,
      notificationAutoRecordEnabled: data.notificationAutoRecordEnabled.present
          ? data.notificationAutoRecordEnabled.value
          : this.notificationAutoRecordEnabled,
      accessibilityAutoRecordEnabled:
          data.accessibilityAutoRecordEnabled.present
          ? data.accessibilityAutoRecordEnabled.value
          : this.accessibilityAutoRecordEnabled,
      smsListenEnabled: data.smsListenEnabled.present
          ? data.smsListenEnabled.value
          : this.smsListenEnabled,
      notificationListenEnabled: data.notificationListenEnabled.present
          ? data.notificationListenEnabled.value
          : this.notificationListenEnabled,
      monthlyBudget: data.monthlyBudget.present
          ? data.monthlyBudget.value
          : this.monthlyBudget,
      categoryOrder: data.categoryOrder.present
          ? data.categoryOrder.value
          : this.categoryOrder,
      categoryUsage: data.categoryUsage.present
          ? data.categoryUsage.value
          : this.categoryUsage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserConfigData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('phone: $phone, ')
          ..write('token: $token, ')
          ..write('mockMode: $mockMode, ')
          ..write(
            'notificationAutoRecordEnabled: $notificationAutoRecordEnabled, ',
          )
          ..write(
            'accessibilityAutoRecordEnabled: $accessibilityAutoRecordEnabled, ',
          )
          ..write('smsListenEnabled: $smsListenEnabled, ')
          ..write('notificationListenEnabled: $notificationListenEnabled, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('categoryOrder: $categoryOrder, ')
          ..write('categoryUsage: $categoryUsage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    phone,
    token,
    mockMode,
    notificationAutoRecordEnabled,
    accessibilityAutoRecordEnabled,
    smsListenEnabled,
    notificationListenEnabled,
    monthlyBudget,
    categoryOrder,
    categoryUsage,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserConfigData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.phone == this.phone &&
          other.token == this.token &&
          other.mockMode == this.mockMode &&
          other.notificationAutoRecordEnabled ==
              this.notificationAutoRecordEnabled &&
          other.accessibilityAutoRecordEnabled ==
              this.accessibilityAutoRecordEnabled &&
          other.smsListenEnabled == this.smsListenEnabled &&
          other.notificationListenEnabled == this.notificationListenEnabled &&
          other.monthlyBudget == this.monthlyBudget &&
          other.categoryOrder == this.categoryOrder &&
          other.categoryUsage == this.categoryUsage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalUserConfigCompanion extends UpdateCompanion<LocalUserConfigData> {
  final Value<int> id;
  final Value<String?> userId;
  final Value<String?> phone;
  final Value<String?> token;
  final Value<bool> mockMode;
  final Value<bool> notificationAutoRecordEnabled;
  final Value<bool> accessibilityAutoRecordEnabled;
  final Value<bool> smsListenEnabled;
  final Value<bool> notificationListenEnabled;
  final Value<double> monthlyBudget;
  final Value<String> categoryOrder;
  final Value<String> categoryUsage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LocalUserConfigCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.phone = const Value.absent(),
    this.token = const Value.absent(),
    this.mockMode = const Value.absent(),
    this.notificationAutoRecordEnabled = const Value.absent(),
    this.accessibilityAutoRecordEnabled = const Value.absent(),
    this.smsListenEnabled = const Value.absent(),
    this.notificationListenEnabled = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    this.categoryOrder = const Value.absent(),
    this.categoryUsage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalUserConfigCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.phone = const Value.absent(),
    this.token = const Value.absent(),
    this.mockMode = const Value.absent(),
    this.notificationAutoRecordEnabled = const Value.absent(),
    this.accessibilityAutoRecordEnabled = const Value.absent(),
    this.smsListenEnabled = const Value.absent(),
    this.notificationListenEnabled = const Value.absent(),
    this.monthlyBudget = const Value.absent(),
    this.categoryOrder = const Value.absent(),
    this.categoryUsage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<LocalUserConfigData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? phone,
    Expression<String>? token,
    Expression<bool>? mockMode,
    Expression<bool>? notificationAutoRecordEnabled,
    Expression<bool>? accessibilityAutoRecordEnabled,
    Expression<bool>? smsListenEnabled,
    Expression<bool>? notificationListenEnabled,
    Expression<double>? monthlyBudget,
    Expression<String>? categoryOrder,
    Expression<String>? categoryUsage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (phone != null) 'phone': phone,
      if (token != null) 'token': token,
      if (mockMode != null) 'mock_mode': mockMode,
      if (notificationAutoRecordEnabled != null)
        'notification_auto_record_enabled': notificationAutoRecordEnabled,
      if (accessibilityAutoRecordEnabled != null)
        'accessibility_auto_record_enabled': accessibilityAutoRecordEnabled,
      if (smsListenEnabled != null) 'sms_listen_enabled': smsListenEnabled,
      if (notificationListenEnabled != null)
        'notification_listen_enabled': notificationListenEnabled,
      if (monthlyBudget != null) 'monthly_budget': monthlyBudget,
      if (categoryOrder != null) 'category_order': categoryOrder,
      if (categoryUsage != null) 'category_usage': categoryUsage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalUserConfigCompanion copyWith({
    Value<int>? id,
    Value<String?>? userId,
    Value<String?>? phone,
    Value<String?>? token,
    Value<bool>? mockMode,
    Value<bool>? notificationAutoRecordEnabled,
    Value<bool>? accessibilityAutoRecordEnabled,
    Value<bool>? smsListenEnabled,
    Value<bool>? notificationListenEnabled,
    Value<double>? monthlyBudget,
    Value<String>? categoryOrder,
    Value<String>? categoryUsage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LocalUserConfigCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      mockMode: mockMode ?? this.mockMode,
      notificationAutoRecordEnabled:
          notificationAutoRecordEnabled ?? this.notificationAutoRecordEnabled,
      accessibilityAutoRecordEnabled:
          accessibilityAutoRecordEnabled ?? this.accessibilityAutoRecordEnabled,
      smsListenEnabled: smsListenEnabled ?? this.smsListenEnabled,
      notificationListenEnabled:
          notificationListenEnabled ?? this.notificationListenEnabled,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      categoryOrder: categoryOrder ?? this.categoryOrder,
      categoryUsage: categoryUsage ?? this.categoryUsage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (mockMode.present) {
      map['mock_mode'] = Variable<bool>(mockMode.value);
    }
    if (notificationAutoRecordEnabled.present) {
      map['notification_auto_record_enabled'] = Variable<bool>(
        notificationAutoRecordEnabled.value,
      );
    }
    if (accessibilityAutoRecordEnabled.present) {
      map['accessibility_auto_record_enabled'] = Variable<bool>(
        accessibilityAutoRecordEnabled.value,
      );
    }
    if (smsListenEnabled.present) {
      map['sms_listen_enabled'] = Variable<bool>(smsListenEnabled.value);
    }
    if (notificationListenEnabled.present) {
      map['notification_listen_enabled'] = Variable<bool>(
        notificationListenEnabled.value,
      );
    }
    if (monthlyBudget.present) {
      map['monthly_budget'] = Variable<double>(monthlyBudget.value);
    }
    if (categoryOrder.present) {
      map['category_order'] = Variable<String>(categoryOrder.value);
    }
    if (categoryUsage.present) {
      map['category_usage'] = Variable<String>(categoryUsage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserConfigCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('phone: $phone, ')
          ..write('token: $token, ')
          ..write('mockMode: $mockMode, ')
          ..write(
            'notificationAutoRecordEnabled: $notificationAutoRecordEnabled, ',
          )
          ..write(
            'accessibilityAutoRecordEnabled: $accessibilityAutoRecordEnabled, ',
          )
          ..write('smsListenEnabled: $smsListenEnabled, ')
          ..write('notificationListenEnabled: $notificationListenEnabled, ')
          ..write('monthlyBudget: $monthlyBudget, ')
          ..write('categoryOrder: $categoryOrder, ')
          ..write('categoryUsage: $categoryUsage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalAccountsTable extends LocalAccounts
    with TableInfo<$LocalAccountsTable, LocalAccountsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('wallet'),
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#7C4DFF'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    name,
    type,
    icon,
    balance,
    color,
    sortOrder,
    isEnabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccountsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAccountsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccountsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAccountsTable createAlias(String alias) {
    return $LocalAccountsTable(attachedDatabase, alias);
  }
}

class LocalAccountsData extends DataClass
    implements Insertable<LocalAccountsData> {
  final int id;
  final String accountId;
  final String name;
  final String type;
  final String icon;
  final double balance;
  final String color;
  final int sortOrder;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalAccountsData({
    required this.id,
    required this.accountId,
    required this.name,
    required this.type,
    required this.icon,
    required this.balance,
    required this.color,
    required this.sortOrder,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<String>(accountId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon'] = Variable<String>(icon);
    map['balance'] = Variable<double>(balance);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAccountsCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      name: Value(name),
      type: Value(type),
      icon: Value(icon),
      balance: Value(balance),
      color: Value(color),
      sortOrder: Value(sortOrder),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAccountsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccountsData(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String>(json['icon']),
      balance: serializer.fromJson<double>(json['balance']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<String>(accountId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String>(icon),
      'balance': serializer.toJson<double>(balance),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAccountsData copyWith({
    int? id,
    String? accountId,
    String? name,
    String? type,
    String? icon,
    double? balance,
    String? color,
    int? sortOrder,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalAccountsData(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon ?? this.icon,
    balance: balance ?? this.balance,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAccountsData copyWithCompanion(LocalAccountsCompanion data) {
    return LocalAccountsData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      balance: data.balance.present ? data.balance.value : this.balance,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountsData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('balance: $balance, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    name,
    type,
    icon,
    balance,
    color,
    sortOrder,
    isEnabled,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccountsData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.balance == this.balance &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalAccountsCompanion extends UpdateCompanion<LocalAccountsData> {
  final Value<int> id;
  final Value<String> accountId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> icon;
  final Value<double> balance;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LocalAccountsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.balance = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String accountId,
    required String name,
    required String type,
    this.icon = const Value.absent(),
    this.balance = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : accountId = Value(accountId),
       name = Value(name),
       type = Value(type);
  static Insertable<LocalAccountsData> custom({
    Expression<int>? id,
    Expression<String>? accountId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<double>? balance,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (balance != null) 'balance': balance,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? accountId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? icon,
    Value<double>? balance,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LocalAccountsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('balance: $balance, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalBillsTable extends LocalBills
    with TableInfo<$LocalBillsTable, LocalBillsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _billIdMeta = const VerificationMeta('billId');
  @override
  late final GeneratedColumn<String> billId = GeneratedColumn<String>(
    'bill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sourceHashMeta = const VerificationMeta(
    'sourceHash',
  );
  @override
  late final GeneratedColumn<String> sourceHash = GeneratedColumn<String>(
    'source_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _liabilityIdMeta = const VerificationMeta(
    'liabilityId',
  );
  @override
  late final GeneratedColumn<String> liabilityId = GeneratedColumn<String>(
    'liability_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billTimeMeta = const VerificationMeta(
    'billTime',
  );
  @override
  late final GeneratedColumn<DateTime> billTime = GeneratedColumn<DateTime>(
    'bill_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _confirmStatusMeta = const VerificationMeta(
    'confirmStatus',
  );
  @override
  late final GeneratedColumn<int> confirmStatus = GeneratedColumn<int>(
    'confirm_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    billId,
    sourceHash,
    type,
    amount,
    categoryId,
    categoryName,
    accountId,
    toAccountId,
    liabilityId,
    remark,
    billTime,
    source,
    confirmStatus,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_bills';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBillsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bill_id')) {
      context.handle(
        _billIdMeta,
        billId.isAcceptableOrUnknown(data['bill_id']!, _billIdMeta),
      );
    } else if (isInserting) {
      context.missing(_billIdMeta);
    }
    if (data.containsKey('source_hash')) {
      context.handle(
        _sourceHashMeta,
        sourceHash.isAcceptableOrUnknown(data['source_hash']!, _sourceHashMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('liability_id')) {
      context.handle(
        _liabilityIdMeta,
        liabilityId.isAcceptableOrUnknown(
          data['liability_id']!,
          _liabilityIdMeta,
        ),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('bill_time')) {
      context.handle(
        _billTimeMeta,
        billTime.isAcceptableOrUnknown(data['bill_time']!, _billTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_billTimeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('confirm_status')) {
      context.handle(
        _confirmStatusMeta,
        confirmStatus.isAcceptableOrUnknown(
          data['confirm_status']!,
          _confirmStatusMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBillsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBillsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      billId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_id'],
      )!,
      sourceHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hash'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_id'],
      ),
      liabilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liability_id'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
      billTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bill_time'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      confirmStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirm_status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalBillsTable createAlias(String alias) {
    return $LocalBillsTable(attachedDatabase, alias);
  }
}

class LocalBillsData extends DataClass implements Insertable<LocalBillsData> {
  final int id;
  final String billId;
  final String? sourceHash;
  final String type;
  final double amount;
  final String? categoryId;
  final String? categoryName;
  final String accountId;
  final String? toAccountId;
  final String? liabilityId;
  final String? remark;
  final DateTime billTime;
  final String source;
  final int confirmStatus;
  final int syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalBillsData({
    required this.id,
    required this.billId,
    this.sourceHash,
    required this.type,
    required this.amount,
    this.categoryId,
    this.categoryName,
    required this.accountId,
    this.toAccountId,
    this.liabilityId,
    this.remark,
    required this.billTime,
    required this.source,
    required this.confirmStatus,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bill_id'] = Variable<String>(billId);
    if (!nullToAbsent || sourceHash != null) {
      map['source_hash'] = Variable<String>(sourceHash);
    }
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || liabilityId != null) {
      map['liability_id'] = Variable<String>(liabilityId);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    map['bill_time'] = Variable<DateTime>(billTime);
    map['source'] = Variable<String>(source);
    map['confirm_status'] = Variable<int>(confirmStatus);
    map['sync_status'] = Variable<int>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalBillsCompanion toCompanion(bool nullToAbsent) {
    return LocalBillsCompanion(
      id: Value(id),
      billId: Value(billId),
      sourceHash: sourceHash == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceHash),
      type: Value(type),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      accountId: Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      liabilityId: liabilityId == null && nullToAbsent
          ? const Value.absent()
          : Value(liabilityId),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
      billTime: Value(billTime),
      source: Value(source),
      confirmStatus: Value(confirmStatus),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalBillsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBillsData(
      id: serializer.fromJson<int>(json['id']),
      billId: serializer.fromJson<String>(json['billId']),
      sourceHash: serializer.fromJson<String?>(json['sourceHash']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      accountId: serializer.fromJson<String>(json['accountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      liabilityId: serializer.fromJson<String?>(json['liabilityId']),
      remark: serializer.fromJson<String?>(json['remark']),
      billTime: serializer.fromJson<DateTime>(json['billTime']),
      source: serializer.fromJson<String>(json['source']),
      confirmStatus: serializer.fromJson<int>(json['confirmStatus']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'billId': serializer.toJson<String>(billId),
      'sourceHash': serializer.toJson<String?>(sourceHash),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<String?>(categoryId),
      'categoryName': serializer.toJson<String?>(categoryName),
      'accountId': serializer.toJson<String>(accountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'liabilityId': serializer.toJson<String?>(liabilityId),
      'remark': serializer.toJson<String?>(remark),
      'billTime': serializer.toJson<DateTime>(billTime),
      'source': serializer.toJson<String>(source),
      'confirmStatus': serializer.toJson<int>(confirmStatus),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalBillsData copyWith({
    int? id,
    String? billId,
    Value<String?> sourceHash = const Value.absent(),
    String? type,
    double? amount,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> categoryName = const Value.absent(),
    String? accountId,
    Value<String?> toAccountId = const Value.absent(),
    Value<String?> liabilityId = const Value.absent(),
    Value<String?> remark = const Value.absent(),
    DateTime? billTime,
    String? source,
    int? confirmStatus,
    int? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalBillsData(
    id: id ?? this.id,
    billId: billId ?? this.billId,
    sourceHash: sourceHash.present ? sourceHash.value : this.sourceHash,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    categoryName: categoryName.present ? categoryName.value : this.categoryName,
    accountId: accountId ?? this.accountId,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    liabilityId: liabilityId.present ? liabilityId.value : this.liabilityId,
    remark: remark.present ? remark.value : this.remark,
    billTime: billTime ?? this.billTime,
    source: source ?? this.source,
    confirmStatus: confirmStatus ?? this.confirmStatus,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalBillsData copyWithCompanion(LocalBillsCompanion data) {
    return LocalBillsData(
      id: data.id.present ? data.id.value : this.id,
      billId: data.billId.present ? data.billId.value : this.billId,
      sourceHash: data.sourceHash.present
          ? data.sourceHash.value
          : this.sourceHash,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      liabilityId: data.liabilityId.present
          ? data.liabilityId.value
          : this.liabilityId,
      remark: data.remark.present ? data.remark.value : this.remark,
      billTime: data.billTime.present ? data.billTime.value : this.billTime,
      source: data.source.present ? data.source.value : this.source,
      confirmStatus: data.confirmStatus.present
          ? data.confirmStatus.value
          : this.confirmStatus,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBillsData(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('liabilityId: $liabilityId, ')
          ..write('remark: $remark, ')
          ..write('billTime: $billTime, ')
          ..write('source: $source, ')
          ..write('confirmStatus: $confirmStatus, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    billId,
    sourceHash,
    type,
    amount,
    categoryId,
    categoryName,
    accountId,
    toAccountId,
    liabilityId,
    remark,
    billTime,
    source,
    confirmStatus,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBillsData &&
          other.id == this.id &&
          other.billId == this.billId &&
          other.sourceHash == this.sourceHash &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.liabilityId == this.liabilityId &&
          other.remark == this.remark &&
          other.billTime == this.billTime &&
          other.source == this.source &&
          other.confirmStatus == this.confirmStatus &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalBillsCompanion extends UpdateCompanion<LocalBillsData> {
  final Value<int> id;
  final Value<String> billId;
  final Value<String?> sourceHash;
  final Value<String> type;
  final Value<double> amount;
  final Value<String?> categoryId;
  final Value<String?> categoryName;
  final Value<String> accountId;
  final Value<String?> toAccountId;
  final Value<String?> liabilityId;
  final Value<String?> remark;
  final Value<DateTime> billTime;
  final Value<String> source;
  final Value<int> confirmStatus;
  final Value<int> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LocalBillsCompanion({
    this.id = const Value.absent(),
    this.billId = const Value.absent(),
    this.sourceHash = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.liabilityId = const Value.absent(),
    this.remark = const Value.absent(),
    this.billTime = const Value.absent(),
    this.source = const Value.absent(),
    this.confirmStatus = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalBillsCompanion.insert({
    this.id = const Value.absent(),
    required String billId,
    this.sourceHash = const Value.absent(),
    required String type,
    required double amount,
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    required String accountId,
    this.toAccountId = const Value.absent(),
    this.liabilityId = const Value.absent(),
    this.remark = const Value.absent(),
    required DateTime billTime,
    this.source = const Value.absent(),
    this.confirmStatus = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : billId = Value(billId),
       type = Value(type),
       amount = Value(amount),
       accountId = Value(accountId),
       billTime = Value(billTime);
  static Insertable<LocalBillsData> custom({
    Expression<int>? id,
    Expression<String>? billId,
    Expression<String>? sourceHash,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? categoryId,
    Expression<String>? categoryName,
    Expression<String>? accountId,
    Expression<String>? toAccountId,
    Expression<String>? liabilityId,
    Expression<String>? remark,
    Expression<DateTime>? billTime,
    Expression<String>? source,
    Expression<int>? confirmStatus,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (billId != null) 'bill_id': billId,
      if (sourceHash != null) 'source_hash': sourceHash,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (liabilityId != null) 'liability_id': liabilityId,
      if (remark != null) 'remark': remark,
      if (billTime != null) 'bill_time': billTime,
      if (source != null) 'source': source,
      if (confirmStatus != null) 'confirm_status': confirmStatus,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalBillsCompanion copyWith({
    Value<int>? id,
    Value<String>? billId,
    Value<String?>? sourceHash,
    Value<String>? type,
    Value<double>? amount,
    Value<String?>? categoryId,
    Value<String?>? categoryName,
    Value<String>? accountId,
    Value<String?>? toAccountId,
    Value<String?>? liabilityId,
    Value<String?>? remark,
    Value<DateTime>? billTime,
    Value<String>? source,
    Value<int>? confirmStatus,
    Value<int>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LocalBillsCompanion(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      sourceHash: sourceHash ?? this.sourceHash,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      liabilityId: liabilityId ?? this.liabilityId,
      remark: remark ?? this.remark,
      billTime: billTime ?? this.billTime,
      source: source ?? this.source,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (billId.present) {
      map['bill_id'] = Variable<String>(billId.value);
    }
    if (sourceHash.present) {
      map['source_hash'] = Variable<String>(sourceHash.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (liabilityId.present) {
      map['liability_id'] = Variable<String>(liabilityId.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (billTime.present) {
      map['bill_time'] = Variable<DateTime>(billTime.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (confirmStatus.present) {
      map['confirm_status'] = Variable<int>(confirmStatus.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBillsCompanion(')
          ..write('id: $id, ')
          ..write('billId: $billId, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('liabilityId: $liabilityId, ')
          ..write('remark: $remark, ')
          ..write('billTime: $billTime, ')
          ..write('source: $source, ')
          ..write('confirmStatus: $confirmStatus, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalLiabilitiesTable extends LocalLiabilities
    with TableInfo<$LocalLiabilitiesTable, LocalLiabilitiesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLiabilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _liabilityIdMeta = const VerificationMeta(
    'liabilityId',
  );
  @override
  late final GeneratedColumn<String> liabilityId = GeneratedColumn<String>(
    'liability_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repaidAmountMeta = const VerificationMeta(
    'repaidAmount',
  );
  @override
  late final GeneratedColumn<double> repaidAmount = GeneratedColumn<double>(
    'repaid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _overdueAmountMeta = const VerificationMeta(
    'overdueAmount',
  );
  @override
  late final GeneratedColumn<double> overdueAmount = GeneratedColumn<double>(
    'overdue_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repayDateMeta = const VerificationMeta(
    'repayDate',
  );
  @override
  late final GeneratedColumn<DateTime> repayDate = GeneratedColumn<DateTime>(
    'repay_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _institutionMeta = const VerificationMeta(
    'institution',
  );
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
    'institution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loanDateMeta = const VerificationMeta(
    'loanDate',
  );
  @override
  late final GeneratedColumn<String> loanDate = GeneratedColumn<String>(
    'loan_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstPaymentDateMeta = const VerificationMeta(
    'firstPaymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> firstPaymentDate =
      GeneratedColumn<DateTime>(
        'first_payment_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastPaymentDateMeta = const VerificationMeta(
    'lastPaymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastPaymentDate =
      GeneratedColumn<DateTime>(
        'last_payment_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    liabilityId,
    name,
    type,
    accountId,
    totalAmount,
    repaidAmount,
    overdueAmount,
    dueDate,
    repayDate,
    institution,
    loanDate,
    firstPaymentDate,
    lastPaymentDate,
    remark,
    status,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_liabilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLiabilitiesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('liability_id')) {
      context.handle(
        _liabilityIdMeta,
        liabilityId.isAcceptableOrUnknown(
          data['liability_id']!,
          _liabilityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_liabilityIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('repaid_amount')) {
      context.handle(
        _repaidAmountMeta,
        repaidAmount.isAcceptableOrUnknown(
          data['repaid_amount']!,
          _repaidAmountMeta,
        ),
      );
    }
    if (data.containsKey('overdue_amount')) {
      context.handle(
        _overdueAmountMeta,
        overdueAmount.isAcceptableOrUnknown(
          data['overdue_amount']!,
          _overdueAmountMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('repay_date')) {
      context.handle(
        _repayDateMeta,
        repayDate.isAcceptableOrUnknown(data['repay_date']!, _repayDateMeta),
      );
    }
    if (data.containsKey('institution')) {
      context.handle(
        _institutionMeta,
        institution.isAcceptableOrUnknown(
          data['institution']!,
          _institutionMeta,
        ),
      );
    }
    if (data.containsKey('loan_date')) {
      context.handle(
        _loanDateMeta,
        loanDate.isAcceptableOrUnknown(data['loan_date']!, _loanDateMeta),
      );
    }
    if (data.containsKey('first_payment_date')) {
      context.handle(
        _firstPaymentDateMeta,
        firstPaymentDate.isAcceptableOrUnknown(
          data['first_payment_date']!,
          _firstPaymentDateMeta,
        ),
      );
    }
    if (data.containsKey('last_payment_date')) {
      context.handle(
        _lastPaymentDateMeta,
        lastPaymentDate.isAcceptableOrUnknown(
          data['last_payment_date']!,
          _lastPaymentDateMeta,
        ),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLiabilitiesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLiabilitiesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      liabilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liability_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      repaidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}repaid_amount'],
      )!,
      overdueAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overdue_amount'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      repayDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}repay_date'],
      ),
      institution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution'],
      ),
      loanDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_date'],
      ),
      firstPaymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_payment_date'],
      ),
      lastPaymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_payment_date'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalLiabilitiesTable createAlias(String alias) {
    return $LocalLiabilitiesTable(attachedDatabase, alias);
  }
}

class LocalLiabilitiesData extends DataClass
    implements Insertable<LocalLiabilitiesData> {
  final int id;
  final String liabilityId;
  final String name;
  final String type;
  final String accountId;
  final double totalAmount;
  final double repaidAmount;
  final double overdueAmount;
  final DateTime dueDate;
  final DateTime? repayDate;
  final String? institution;
  final String? loanDate;
  final DateTime? firstPaymentDate;
  final DateTime? lastPaymentDate;
  final String? remark;
  final int status;
  final int syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalLiabilitiesData({
    required this.id,
    required this.liabilityId,
    required this.name,
    required this.type,
    required this.accountId,
    required this.totalAmount,
    required this.repaidAmount,
    required this.overdueAmount,
    required this.dueDate,
    this.repayDate,
    this.institution,
    this.loanDate,
    this.firstPaymentDate,
    this.lastPaymentDate,
    this.remark,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['liability_id'] = Variable<String>(liabilityId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['account_id'] = Variable<String>(accountId);
    map['total_amount'] = Variable<double>(totalAmount);
    map['repaid_amount'] = Variable<double>(repaidAmount);
    map['overdue_amount'] = Variable<double>(overdueAmount);
    map['due_date'] = Variable<DateTime>(dueDate);
    if (!nullToAbsent || repayDate != null) {
      map['repay_date'] = Variable<DateTime>(repayDate);
    }
    if (!nullToAbsent || institution != null) {
      map['institution'] = Variable<String>(institution);
    }
    if (!nullToAbsent || loanDate != null) {
      map['loan_date'] = Variable<String>(loanDate);
    }
    if (!nullToAbsent || firstPaymentDate != null) {
      map['first_payment_date'] = Variable<DateTime>(firstPaymentDate);
    }
    if (!nullToAbsent || lastPaymentDate != null) {
      map['last_payment_date'] = Variable<DateTime>(lastPaymentDate);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    map['status'] = Variable<int>(status);
    map['sync_status'] = Variable<int>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalLiabilitiesCompanion toCompanion(bool nullToAbsent) {
    return LocalLiabilitiesCompanion(
      id: Value(id),
      liabilityId: Value(liabilityId),
      name: Value(name),
      type: Value(type),
      accountId: Value(accountId),
      totalAmount: Value(totalAmount),
      repaidAmount: Value(repaidAmount),
      overdueAmount: Value(overdueAmount),
      dueDate: Value(dueDate),
      repayDate: repayDate == null && nullToAbsent
          ? const Value.absent()
          : Value(repayDate),
      institution: institution == null && nullToAbsent
          ? const Value.absent()
          : Value(institution),
      loanDate: loanDate == null && nullToAbsent
          ? const Value.absent()
          : Value(loanDate),
      firstPaymentDate: firstPaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(firstPaymentDate),
      lastPaymentDate: lastPaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPaymentDate),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
      status: Value(status),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalLiabilitiesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLiabilitiesData(
      id: serializer.fromJson<int>(json['id']),
      liabilityId: serializer.fromJson<String>(json['liabilityId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      accountId: serializer.fromJson<String>(json['accountId']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      repaidAmount: serializer.fromJson<double>(json['repaidAmount']),
      overdueAmount: serializer.fromJson<double>(json['overdueAmount']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      repayDate: serializer.fromJson<DateTime?>(json['repayDate']),
      institution: serializer.fromJson<String?>(json['institution']),
      loanDate: serializer.fromJson<String?>(json['loanDate']),
      firstPaymentDate: serializer.fromJson<DateTime?>(
        json['firstPaymentDate'],
      ),
      lastPaymentDate: serializer.fromJson<DateTime?>(json['lastPaymentDate']),
      remark: serializer.fromJson<String?>(json['remark']),
      status: serializer.fromJson<int>(json['status']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'liabilityId': serializer.toJson<String>(liabilityId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'accountId': serializer.toJson<String>(accountId),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'repaidAmount': serializer.toJson<double>(repaidAmount),
      'overdueAmount': serializer.toJson<double>(overdueAmount),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'repayDate': serializer.toJson<DateTime?>(repayDate),
      'institution': serializer.toJson<String?>(institution),
      'loanDate': serializer.toJson<String?>(loanDate),
      'firstPaymentDate': serializer.toJson<DateTime?>(firstPaymentDate),
      'lastPaymentDate': serializer.toJson<DateTime?>(lastPaymentDate),
      'remark': serializer.toJson<String?>(remark),
      'status': serializer.toJson<int>(status),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalLiabilitiesData copyWith({
    int? id,
    String? liabilityId,
    String? name,
    String? type,
    String? accountId,
    double? totalAmount,
    double? repaidAmount,
    double? overdueAmount,
    DateTime? dueDate,
    Value<DateTime?> repayDate = const Value.absent(),
    Value<String?> institution = const Value.absent(),
    Value<String?> loanDate = const Value.absent(),
    Value<DateTime?> firstPaymentDate = const Value.absent(),
    Value<DateTime?> lastPaymentDate = const Value.absent(),
    Value<String?> remark = const Value.absent(),
    int? status,
    int? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalLiabilitiesData(
    id: id ?? this.id,
    liabilityId: liabilityId ?? this.liabilityId,
    name: name ?? this.name,
    type: type ?? this.type,
    accountId: accountId ?? this.accountId,
    totalAmount: totalAmount ?? this.totalAmount,
    repaidAmount: repaidAmount ?? this.repaidAmount,
    overdueAmount: overdueAmount ?? this.overdueAmount,
    dueDate: dueDate ?? this.dueDate,
    repayDate: repayDate.present ? repayDate.value : this.repayDate,
    institution: institution.present ? institution.value : this.institution,
    loanDate: loanDate.present ? loanDate.value : this.loanDate,
    firstPaymentDate: firstPaymentDate.present
        ? firstPaymentDate.value
        : this.firstPaymentDate,
    lastPaymentDate: lastPaymentDate.present
        ? lastPaymentDate.value
        : this.lastPaymentDate,
    remark: remark.present ? remark.value : this.remark,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalLiabilitiesData copyWithCompanion(LocalLiabilitiesCompanion data) {
    return LocalLiabilitiesData(
      id: data.id.present ? data.id.value : this.id,
      liabilityId: data.liabilityId.present
          ? data.liabilityId.value
          : this.liabilityId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      repaidAmount: data.repaidAmount.present
          ? data.repaidAmount.value
          : this.repaidAmount,
      overdueAmount: data.overdueAmount.present
          ? data.overdueAmount.value
          : this.overdueAmount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      repayDate: data.repayDate.present ? data.repayDate.value : this.repayDate,
      institution: data.institution.present
          ? data.institution.value
          : this.institution,
      loanDate: data.loanDate.present ? data.loanDate.value : this.loanDate,
      firstPaymentDate: data.firstPaymentDate.present
          ? data.firstPaymentDate.value
          : this.firstPaymentDate,
      lastPaymentDate: data.lastPaymentDate.present
          ? data.lastPaymentDate.value
          : this.lastPaymentDate,
      remark: data.remark.present ? data.remark.value : this.remark,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLiabilitiesData(')
          ..write('id: $id, ')
          ..write('liabilityId: $liabilityId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('accountId: $accountId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('repaidAmount: $repaidAmount, ')
          ..write('overdueAmount: $overdueAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('repayDate: $repayDate, ')
          ..write('institution: $institution, ')
          ..write('loanDate: $loanDate, ')
          ..write('firstPaymentDate: $firstPaymentDate, ')
          ..write('lastPaymentDate: $lastPaymentDate, ')
          ..write('remark: $remark, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    liabilityId,
    name,
    type,
    accountId,
    totalAmount,
    repaidAmount,
    overdueAmount,
    dueDate,
    repayDate,
    institution,
    loanDate,
    firstPaymentDate,
    lastPaymentDate,
    remark,
    status,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLiabilitiesData &&
          other.id == this.id &&
          other.liabilityId == this.liabilityId &&
          other.name == this.name &&
          other.type == this.type &&
          other.accountId == this.accountId &&
          other.totalAmount == this.totalAmount &&
          other.repaidAmount == this.repaidAmount &&
          other.overdueAmount == this.overdueAmount &&
          other.dueDate == this.dueDate &&
          other.repayDate == this.repayDate &&
          other.institution == this.institution &&
          other.loanDate == this.loanDate &&
          other.firstPaymentDate == this.firstPaymentDate &&
          other.lastPaymentDate == this.lastPaymentDate &&
          other.remark == this.remark &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalLiabilitiesCompanion extends UpdateCompanion<LocalLiabilitiesData> {
  final Value<int> id;
  final Value<String> liabilityId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> accountId;
  final Value<double> totalAmount;
  final Value<double> repaidAmount;
  final Value<double> overdueAmount;
  final Value<DateTime> dueDate;
  final Value<DateTime?> repayDate;
  final Value<String?> institution;
  final Value<String?> loanDate;
  final Value<DateTime?> firstPaymentDate;
  final Value<DateTime?> lastPaymentDate;
  final Value<String?> remark;
  final Value<int> status;
  final Value<int> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LocalLiabilitiesCompanion({
    this.id = const Value.absent(),
    this.liabilityId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.accountId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.repaidAmount = const Value.absent(),
    this.overdueAmount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.repayDate = const Value.absent(),
    this.institution = const Value.absent(),
    this.loanDate = const Value.absent(),
    this.firstPaymentDate = const Value.absent(),
    this.lastPaymentDate = const Value.absent(),
    this.remark = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalLiabilitiesCompanion.insert({
    this.id = const Value.absent(),
    required String liabilityId,
    required String name,
    required String type,
    required String accountId,
    required double totalAmount,
    this.repaidAmount = const Value.absent(),
    this.overdueAmount = const Value.absent(),
    required DateTime dueDate,
    this.repayDate = const Value.absent(),
    this.institution = const Value.absent(),
    this.loanDate = const Value.absent(),
    this.firstPaymentDate = const Value.absent(),
    this.lastPaymentDate = const Value.absent(),
    this.remark = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : liabilityId = Value(liabilityId),
       name = Value(name),
       type = Value(type),
       accountId = Value(accountId),
       totalAmount = Value(totalAmount),
       dueDate = Value(dueDate);
  static Insertable<LocalLiabilitiesData> custom({
    Expression<int>? id,
    Expression<String>? liabilityId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? accountId,
    Expression<double>? totalAmount,
    Expression<double>? repaidAmount,
    Expression<double>? overdueAmount,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? repayDate,
    Expression<String>? institution,
    Expression<String>? loanDate,
    Expression<DateTime>? firstPaymentDate,
    Expression<DateTime>? lastPaymentDate,
    Expression<String>? remark,
    Expression<int>? status,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (liabilityId != null) 'liability_id': liabilityId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (accountId != null) 'account_id': accountId,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (repaidAmount != null) 'repaid_amount': repaidAmount,
      if (overdueAmount != null) 'overdue_amount': overdueAmount,
      if (dueDate != null) 'due_date': dueDate,
      if (repayDate != null) 'repay_date': repayDate,
      if (institution != null) 'institution': institution,
      if (loanDate != null) 'loan_date': loanDate,
      if (firstPaymentDate != null) 'first_payment_date': firstPaymentDate,
      if (lastPaymentDate != null) 'last_payment_date': lastPaymentDate,
      if (remark != null) 'remark': remark,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalLiabilitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? liabilityId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? accountId,
    Value<double>? totalAmount,
    Value<double>? repaidAmount,
    Value<double>? overdueAmount,
    Value<DateTime>? dueDate,
    Value<DateTime?>? repayDate,
    Value<String?>? institution,
    Value<String?>? loanDate,
    Value<DateTime?>? firstPaymentDate,
    Value<DateTime?>? lastPaymentDate,
    Value<String?>? remark,
    Value<int>? status,
    Value<int>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LocalLiabilitiesCompanion(
      id: id ?? this.id,
      liabilityId: liabilityId ?? this.liabilityId,
      name: name ?? this.name,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      totalAmount: totalAmount ?? this.totalAmount,
      repaidAmount: repaidAmount ?? this.repaidAmount,
      overdueAmount: overdueAmount ?? this.overdueAmount,
      dueDate: dueDate ?? this.dueDate,
      repayDate: repayDate ?? this.repayDate,
      institution: institution ?? this.institution,
      loanDate: loanDate ?? this.loanDate,
      firstPaymentDate: firstPaymentDate ?? this.firstPaymentDate,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      remark: remark ?? this.remark,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (liabilityId.present) {
      map['liability_id'] = Variable<String>(liabilityId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (repaidAmount.present) {
      map['repaid_amount'] = Variable<double>(repaidAmount.value);
    }
    if (overdueAmount.present) {
      map['overdue_amount'] = Variable<double>(overdueAmount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (repayDate.present) {
      map['repay_date'] = Variable<DateTime>(repayDate.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (loanDate.present) {
      map['loan_date'] = Variable<String>(loanDate.value);
    }
    if (firstPaymentDate.present) {
      map['first_payment_date'] = Variable<DateTime>(firstPaymentDate.value);
    }
    if (lastPaymentDate.present) {
      map['last_payment_date'] = Variable<DateTime>(lastPaymentDate.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLiabilitiesCompanion(')
          ..write('id: $id, ')
          ..write('liabilityId: $liabilityId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('accountId: $accountId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('repaidAmount: $repaidAmount, ')
          ..write('overdueAmount: $overdueAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('repayDate: $repayDate, ')
          ..write('institution: $institution, ')
          ..write('loanDate: $loanDate, ')
          ..write('firstPaymentDate: $firstPaymentDate, ')
          ..write('lastPaymentDate: $lastPaymentDate, ')
          ..write('remark: $remark, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalLiabilityRepaysTable extends LocalLiabilityRepays
    with TableInfo<$LocalLiabilityRepaysTable, LocalLiabilityRepaysData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLiabilityRepaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _repayIdMeta = const VerificationMeta(
    'repayId',
  );
  @override
  late final GeneratedColumn<String> repayId = GeneratedColumn<String>(
    'repay_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _liabilityIdMeta = const VerificationMeta(
    'liabilityId',
  );
  @override
  late final GeneratedColumn<String> liabilityId = GeneratedColumn<String>(
    'liability_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repayTimeMeta = const VerificationMeta(
    'repayTime',
  );
  @override
  late final GeneratedColumn<DateTime> repayTime = GeneratedColumn<DateTime>(
    'repay_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    repayId,
    liabilityId,
    amount,
    accountId,
    repayTime,
    remark,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_liability_repays';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLiabilityRepaysData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('repay_id')) {
      context.handle(
        _repayIdMeta,
        repayId.isAcceptableOrUnknown(data['repay_id']!, _repayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_repayIdMeta);
    }
    if (data.containsKey('liability_id')) {
      context.handle(
        _liabilityIdMeta,
        liabilityId.isAcceptableOrUnknown(
          data['liability_id']!,
          _liabilityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_liabilityIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('repay_time')) {
      context.handle(
        _repayTimeMeta,
        repayTime.isAcceptableOrUnknown(data['repay_time']!, _repayTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_repayTimeMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLiabilityRepaysData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLiabilityRepaysData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      repayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repay_id'],
      )!,
      liabilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liability_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      repayTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}repay_time'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalLiabilityRepaysTable createAlias(String alias) {
    return $LocalLiabilityRepaysTable(attachedDatabase, alias);
  }
}

class LocalLiabilityRepaysData extends DataClass
    implements Insertable<LocalLiabilityRepaysData> {
  final int id;
  final String repayId;
  final String liabilityId;
  final double amount;
  final String accountId;
  final DateTime repayTime;
  final String? remark;
  final int syncStatus;
  final DateTime createdAt;
  const LocalLiabilityRepaysData({
    required this.id,
    required this.repayId,
    required this.liabilityId,
    required this.amount,
    required this.accountId,
    required this.repayTime,
    this.remark,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['repay_id'] = Variable<String>(repayId);
    map['liability_id'] = Variable<String>(liabilityId);
    map['amount'] = Variable<double>(amount);
    map['account_id'] = Variable<String>(accountId);
    map['repay_time'] = Variable<DateTime>(repayTime);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    map['sync_status'] = Variable<int>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalLiabilityRepaysCompanion toCompanion(bool nullToAbsent) {
    return LocalLiabilityRepaysCompanion(
      id: Value(id),
      repayId: Value(repayId),
      liabilityId: Value(liabilityId),
      amount: Value(amount),
      accountId: Value(accountId),
      repayTime: Value(repayTime),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LocalLiabilityRepaysData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLiabilityRepaysData(
      id: serializer.fromJson<int>(json['id']),
      repayId: serializer.fromJson<String>(json['repayId']),
      liabilityId: serializer.fromJson<String>(json['liabilityId']),
      amount: serializer.fromJson<double>(json['amount']),
      accountId: serializer.fromJson<String>(json['accountId']),
      repayTime: serializer.fromJson<DateTime>(json['repayTime']),
      remark: serializer.fromJson<String?>(json['remark']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'repayId': serializer.toJson<String>(repayId),
      'liabilityId': serializer.toJson<String>(liabilityId),
      'amount': serializer.toJson<double>(amount),
      'accountId': serializer.toJson<String>(accountId),
      'repayTime': serializer.toJson<DateTime>(repayTime),
      'remark': serializer.toJson<String?>(remark),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalLiabilityRepaysData copyWith({
    int? id,
    String? repayId,
    String? liabilityId,
    double? amount,
    String? accountId,
    DateTime? repayTime,
    Value<String?> remark = const Value.absent(),
    int? syncStatus,
    DateTime? createdAt,
  }) => LocalLiabilityRepaysData(
    id: id ?? this.id,
    repayId: repayId ?? this.repayId,
    liabilityId: liabilityId ?? this.liabilityId,
    amount: amount ?? this.amount,
    accountId: accountId ?? this.accountId,
    repayTime: repayTime ?? this.repayTime,
    remark: remark.present ? remark.value : this.remark,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalLiabilityRepaysData copyWithCompanion(
    LocalLiabilityRepaysCompanion data,
  ) {
    return LocalLiabilityRepaysData(
      id: data.id.present ? data.id.value : this.id,
      repayId: data.repayId.present ? data.repayId.value : this.repayId,
      liabilityId: data.liabilityId.present
          ? data.liabilityId.value
          : this.liabilityId,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      repayTime: data.repayTime.present ? data.repayTime.value : this.repayTime,
      remark: data.remark.present ? data.remark.value : this.remark,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLiabilityRepaysData(')
          ..write('id: $id, ')
          ..write('repayId: $repayId, ')
          ..write('liabilityId: $liabilityId, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('repayTime: $repayTime, ')
          ..write('remark: $remark, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    repayId,
    liabilityId,
    amount,
    accountId,
    repayTime,
    remark,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLiabilityRepaysData &&
          other.id == this.id &&
          other.repayId == this.repayId &&
          other.liabilityId == this.liabilityId &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.repayTime == this.repayTime &&
          other.remark == this.remark &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class LocalLiabilityRepaysCompanion
    extends UpdateCompanion<LocalLiabilityRepaysData> {
  final Value<int> id;
  final Value<String> repayId;
  final Value<String> liabilityId;
  final Value<double> amount;
  final Value<String> accountId;
  final Value<DateTime> repayTime;
  final Value<String?> remark;
  final Value<int> syncStatus;
  final Value<DateTime> createdAt;
  const LocalLiabilityRepaysCompanion({
    this.id = const Value.absent(),
    this.repayId = const Value.absent(),
    this.liabilityId = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.repayTime = const Value.absent(),
    this.remark = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LocalLiabilityRepaysCompanion.insert({
    this.id = const Value.absent(),
    required String repayId,
    required String liabilityId,
    required double amount,
    required String accountId,
    required DateTime repayTime,
    this.remark = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : repayId = Value(repayId),
       liabilityId = Value(liabilityId),
       amount = Value(amount),
       accountId = Value(accountId),
       repayTime = Value(repayTime);
  static Insertable<LocalLiabilityRepaysData> custom({
    Expression<int>? id,
    Expression<String>? repayId,
    Expression<String>? liabilityId,
    Expression<double>? amount,
    Expression<String>? accountId,
    Expression<DateTime>? repayTime,
    Expression<String>? remark,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (repayId != null) 'repay_id': repayId,
      if (liabilityId != null) 'liability_id': liabilityId,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (repayTime != null) 'repay_time': repayTime,
      if (remark != null) 'remark': remark,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LocalLiabilityRepaysCompanion copyWith({
    Value<int>? id,
    Value<String>? repayId,
    Value<String>? liabilityId,
    Value<double>? amount,
    Value<String>? accountId,
    Value<DateTime>? repayTime,
    Value<String?>? remark,
    Value<int>? syncStatus,
    Value<DateTime>? createdAt,
  }) {
    return LocalLiabilityRepaysCompanion(
      id: id ?? this.id,
      repayId: repayId ?? this.repayId,
      liabilityId: liabilityId ?? this.liabilityId,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      repayTime: repayTime ?? this.repayTime,
      remark: remark ?? this.remark,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (repayId.present) {
      map['repay_id'] = Variable<String>(repayId.value);
    }
    if (liabilityId.present) {
      map['liability_id'] = Variable<String>(liabilityId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (repayTime.present) {
      map['repay_time'] = Variable<DateTime>(repayTime.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLiabilityRepaysCompanion(')
          ..write('id: $id, ')
          ..write('repayId: $repayId, ')
          ..write('liabilityId: $liabilityId, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('repayTime: $repayTime, ')
          ..write('remark: $remark, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategoriesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('category'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#7C4DFF'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    icon,
    color,
    type,
    parentId,
    sortOrder,
    isEnabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategoriesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCategoriesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategoriesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategoriesData extends DataClass
    implements Insertable<LocalCategoriesData> {
  final int id;
  final String categoryId;
  final String name;
  final String icon;
  final String color;
  final String type;
  final String? parentId;
  final int sortOrder;
  final bool isEnabled;
  final DateTime createdAt;
  const LocalCategoriesData({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.parentId,
    required this.sortOrder,
    required this.isEnabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      type: Value(type),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      sortOrder: Value(sortOrder),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
    );
  }

  factory LocalCategoriesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategoriesData(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      type: serializer.fromJson<String>(json['type']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'type': serializer.toJson<String>(type),
      'parentId': serializer.toJson<String?>(parentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalCategoriesData copyWith({
    int? id,
    String? categoryId,
    String? name,
    String? icon,
    String? color,
    String? type,
    Value<String?> parentId = const Value.absent(),
    int? sortOrder,
    bool? isEnabled,
    DateTime? createdAt,
  }) => LocalCategoriesData(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    type: type ?? this.type,
    parentId: parentId.present ? parentId.value : this.parentId,
    sortOrder: sortOrder ?? this.sortOrder,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalCategoriesData copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategoriesData(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesData(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    name,
    icon,
    color,
    type,
    parentId,
    sortOrder,
    isEnabled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategoriesData &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.type == this.type &&
          other.parentId == this.parentId &&
          other.sortOrder == this.sortOrder &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategoriesData> {
  final Value<int> id;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> color;
  final Value<String> type;
  final Value<String?> parentId;
  final Value<int> sortOrder;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  const LocalCategoriesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String categoryId,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    required String type,
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : categoryId = Value(categoryId),
       name = Value(name),
       type = Value(type);
  static Insertable<LocalCategoriesData> custom({
    Expression<int>? id,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? type,
    Expression<String>? parentId,
    Expression<int>? sortOrder,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LocalCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? categoryId,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? color,
    Value<String>? type,
    Value<String?>? parentId,
    Value<int>? sortOrder,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
  }) {
    return LocalCategoriesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LocalBanksTable extends LocalBanks
    with TableInfo<$LocalBanksTable, LocalBanksData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBanksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bankIdMeta = const VerificationMeta('bankId');
  @override
  late final GeneratedColumn<String> bankId = GeneratedColumn<String>(
    'bank_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('account_balance'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#1976D2'),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankId,
    name,
    icon,
    color,
    code,
    sortOrder,
    isEnabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_banks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBanksData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank_id')) {
      context.handle(
        _bankIdMeta,
        bankId.isAcceptableOrUnknown(data['bank_id']!, _bankIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bankIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBanksData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBanksData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bankId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalBanksTable createAlias(String alias) {
    return $LocalBanksTable(attachedDatabase, alias);
  }
}

class LocalBanksData extends DataClass implements Insertable<LocalBanksData> {
  final int id;
  final String bankId;
  final String name;
  final String icon;
  final String color;
  final String? code;
  final int sortOrder;
  final bool isEnabled;
  final DateTime createdAt;
  const LocalBanksData({
    required this.id,
    required this.bankId,
    required this.name,
    required this.icon,
    required this.color,
    this.code,
    required this.sortOrder,
    required this.isEnabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank_id'] = Variable<String>(bankId);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalBanksCompanion toCompanion(bool nullToAbsent) {
    return LocalBanksCompanion(
      id: Value(id),
      bankId: Value(bankId),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      sortOrder: Value(sortOrder),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
    );
  }

  factory LocalBanksData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBanksData(
      id: serializer.fromJson<int>(json['id']),
      bankId: serializer.fromJson<String>(json['bankId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      code: serializer.fromJson<String?>(json['code']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bankId': serializer.toJson<String>(bankId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'code': serializer.toJson<String?>(code),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalBanksData copyWith({
    int? id,
    String? bankId,
    String? name,
    String? icon,
    String? color,
    Value<String?> code = const Value.absent(),
    int? sortOrder,
    bool? isEnabled,
    DateTime? createdAt,
  }) => LocalBanksData(
    id: id ?? this.id,
    bankId: bankId ?? this.bankId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    code: code.present ? code.value : this.code,
    sortOrder: sortOrder ?? this.sortOrder,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalBanksData copyWithCompanion(LocalBanksCompanion data) {
    return LocalBanksData(
      id: data.id.present ? data.id.value : this.id,
      bankId: data.bankId.present ? data.bankId.value : this.bankId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      code: data.code.present ? data.code.value : this.code,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBanksData(')
          ..write('id: $id, ')
          ..write('bankId: $bankId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('code: $code, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankId,
    name,
    icon,
    color,
    code,
    sortOrder,
    isEnabled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBanksData &&
          other.id == this.id &&
          other.bankId == this.bankId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.code == this.code &&
          other.sortOrder == this.sortOrder &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt);
}

class LocalBanksCompanion extends UpdateCompanion<LocalBanksData> {
  final Value<int> id;
  final Value<String> bankId;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> color;
  final Value<String?> code;
  final Value<int> sortOrder;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  const LocalBanksCompanion({
    this.id = const Value.absent(),
    this.bankId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.code = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LocalBanksCompanion.insert({
    this.id = const Value.absent(),
    required String bankId,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.code = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : bankId = Value(bankId),
       name = Value(name);
  static Insertable<LocalBanksData> custom({
    Expression<int>? id,
    Expression<String>? bankId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? code,
    Expression<int>? sortOrder,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankId != null) 'bank_id': bankId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (code != null) 'code': code,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LocalBanksCompanion copyWith({
    Value<int>? id,
    Value<String>? bankId,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? color,
    Value<String?>? code,
    Value<int>? sortOrder,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
  }) {
    return LocalBanksCompanion(
      id: id ?? this.id,
      bankId: bankId ?? this.bankId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      code: code ?? this.code,
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bankId.present) {
      map['bank_id'] = Variable<String>(bankId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBanksCompanion(')
          ..write('id: $id, ')
          ..write('bankId: $bankId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('code: $code, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LocalCreditInstitutionsTable extends LocalCreditInstitutions
    with TableInfo<$LocalCreditInstitutionsTable, LocalCreditInstitutionsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCreditInstitutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _institutionIdMeta = const VerificationMeta(
    'institutionId',
  );
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
    'institution_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('payments'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#FF5722'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    institutionId,
    name,
    type,
    icon,
    color,
    sortOrder,
    isEnabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_credit_institutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCreditInstitutionsData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('institution_id')) {
      context.handle(
        _institutionIdMeta,
        institutionId.isAcceptableOrUnknown(
          data['institution_id']!,
          _institutionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_institutionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCreditInstitutionsData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCreditInstitutionsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      institutionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalCreditInstitutionsTable createAlias(String alias) {
    return $LocalCreditInstitutionsTable(attachedDatabase, alias);
  }
}

class LocalCreditInstitutionsData extends DataClass
    implements Insertable<LocalCreditInstitutionsData> {
  final int id;
  final String institutionId;
  final String name;
  final String type;
  final String icon;
  final String color;
  final int sortOrder;
  final bool isEnabled;
  final DateTime createdAt;
  const LocalCreditInstitutionsData({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.isEnabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['institution_id'] = Variable<String>(institutionId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalCreditInstitutionsCompanion toCompanion(bool nullToAbsent) {
    return LocalCreditInstitutionsCompanion(
      id: Value(id),
      institutionId: Value(institutionId),
      name: Value(name),
      type: Value(type),
      icon: Value(icon),
      color: Value(color),
      sortOrder: Value(sortOrder),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
    );
  }

  factory LocalCreditInstitutionsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCreditInstitutionsData(
      id: serializer.fromJson<int>(json['id']),
      institutionId: serializer.fromJson<String>(json['institutionId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'institutionId': serializer.toJson<String>(institutionId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalCreditInstitutionsData copyWith({
    int? id,
    String? institutionId,
    String? name,
    String? type,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isEnabled,
    DateTime? createdAt,
  }) => LocalCreditInstitutionsData(
    id: id ?? this.id,
    institutionId: institutionId ?? this.institutionId,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalCreditInstitutionsData copyWithCompanion(
    LocalCreditInstitutionsCompanion data,
  ) {
    return LocalCreditInstitutionsData(
      id: data.id.present ? data.id.value : this.id,
      institutionId: data.institutionId.present
          ? data.institutionId.value
          : this.institutionId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCreditInstitutionsData(')
          ..write('id: $id, ')
          ..write('institutionId: $institutionId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    institutionId,
    name,
    type,
    icon,
    color,
    sortOrder,
    isEnabled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCreditInstitutionsData &&
          other.id == this.id &&
          other.institutionId == this.institutionId &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt);
}

class LocalCreditInstitutionsCompanion
    extends UpdateCompanion<LocalCreditInstitutionsData> {
  final Value<int> id;
  final Value<String> institutionId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> icon;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<bool> isEnabled;
  final Value<DateTime> createdAt;
  const LocalCreditInstitutionsCompanion({
    this.id = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LocalCreditInstitutionsCompanion.insert({
    this.id = const Value.absent(),
    required String institutionId,
    required String name,
    required String type,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : institutionId = Value(institutionId),
       name = Value(name),
       type = Value(type);
  static Insertable<LocalCreditInstitutionsData> custom({
    Expression<int>? id,
    Expression<String>? institutionId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<bool>? isEnabled,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (institutionId != null) 'institution_id': institutionId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LocalCreditInstitutionsCompanion copyWith({
    Value<int>? id,
    Value<String>? institutionId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? icon,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<bool>? isEnabled,
    Value<DateTime>? createdAt,
  }) {
    return LocalCreditInstitutionsCompanion(
      id: id ?? this.id,
      institutionId: institutionId ?? this.institutionId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCreditInstitutionsCompanion(')
          ..write('id: $id, ')
          ..write('institutionId: $institutionId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OfflineSyncQueueTable offlineSyncQueue = $OfflineSyncQueueTable(
    this,
  );
  late final $LocalUserConfigTable localUserConfig = $LocalUserConfigTable(
    this,
  );
  late final $LocalAccountsTable localAccounts = $LocalAccountsTable(this);
  late final $LocalBillsTable localBills = $LocalBillsTable(this);
  late final $LocalLiabilitiesTable localLiabilities = $LocalLiabilitiesTable(
    this,
  );
  late final $LocalLiabilityRepaysTable localLiabilityRepays =
      $LocalLiabilityRepaysTable(this);
  late final $LocalCategoriesTable localCategories = $LocalCategoriesTable(
    this,
  );
  late final $LocalBanksTable localBanks = $LocalBanksTable(this);
  late final $LocalCreditInstitutionsTable localCreditInstitutions =
      $LocalCreditInstitutionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    offlineSyncQueue,
    localUserConfig,
    localAccounts,
    localBills,
    localLiabilities,
    localLiabilityRepays,
    localCategories,
    localBanks,
    localCreditInstitutions,
  ];
}

typedef $$OfflineSyncQueueTableCreateCompanionBuilder =
    OfflineSyncQueueCompanion Function({
      Value<int> id,
      required String syncTableName,
      required String recordId,
      required String operation,
      required String data,
      Value<int> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
    });
typedef $$OfflineSyncQueueTableUpdateCompanionBuilder =
    OfflineSyncQueueCompanion Function({
      Value<int> id,
      Value<String> syncTableName,
      Value<String> recordId,
      Value<String> operation,
      Value<String> data,
      Value<int> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
    });

class $$OfflineSyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTable> {
  $$OfflineSyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncTableName => $composableBuilder(
    column: $table.syncTableName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineSyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTable> {
  $$OfflineSyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncTableName => $composableBuilder(
    column: $table.syncTableName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineSyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineSyncQueueTable> {
  $$OfflineSyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncTableName => $composableBuilder(
    column: $table.syncTableName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$OfflineSyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfflineSyncQueueTable,
          OfflineSyncQueueData,
          $$OfflineSyncQueueTableFilterComposer,
          $$OfflineSyncQueueTableOrderingComposer,
          $$OfflineSyncQueueTableAnnotationComposer,
          $$OfflineSyncQueueTableCreateCompanionBuilder,
          $$OfflineSyncQueueTableUpdateCompanionBuilder,
          (
            OfflineSyncQueueData,
            BaseReferences<
              _$AppDatabase,
              $OfflineSyncQueueTable,
              OfflineSyncQueueData
            >,
          ),
          OfflineSyncQueueData,
          PrefetchHooks Function()
        > {
  $$OfflineSyncQueueTableTableManager(
    _$AppDatabase db,
    $OfflineSyncQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineSyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineSyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineSyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> syncTableName = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => OfflineSyncQueueCompanion(
                id: id,
                syncTableName: syncTableName,
                recordId: recordId,
                operation: operation,
                data: data,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String syncTableName,
                required String recordId,
                required String operation,
                required String data,
                Value<int> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => OfflineSyncQueueCompanion.insert(
                id: id,
                syncTableName: syncTableName,
                recordId: recordId,
                operation: operation,
                data: data,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineSyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfflineSyncQueueTable,
      OfflineSyncQueueData,
      $$OfflineSyncQueueTableFilterComposer,
      $$OfflineSyncQueueTableOrderingComposer,
      $$OfflineSyncQueueTableAnnotationComposer,
      $$OfflineSyncQueueTableCreateCompanionBuilder,
      $$OfflineSyncQueueTableUpdateCompanionBuilder,
      (
        OfflineSyncQueueData,
        BaseReferences<
          _$AppDatabase,
          $OfflineSyncQueueTable,
          OfflineSyncQueueData
        >,
      ),
      OfflineSyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$LocalUserConfigTableCreateCompanionBuilder =
    LocalUserConfigCompanion Function({
      Value<int> id,
      Value<String?> userId,
      Value<String?> phone,
      Value<String?> token,
      Value<bool> mockMode,
      Value<bool> notificationAutoRecordEnabled,
      Value<bool> accessibilityAutoRecordEnabled,
      Value<bool> smsListenEnabled,
      Value<bool> notificationListenEnabled,
      Value<double> monthlyBudget,
      Value<String> categoryOrder,
      Value<String> categoryUsage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LocalUserConfigTableUpdateCompanionBuilder =
    LocalUserConfigCompanion Function({
      Value<int> id,
      Value<String?> userId,
      Value<String?> phone,
      Value<String?> token,
      Value<bool> mockMode,
      Value<bool> notificationAutoRecordEnabled,
      Value<bool> accessibilityAutoRecordEnabled,
      Value<bool> smsListenEnabled,
      Value<bool> notificationListenEnabled,
      Value<double> monthlyBudget,
      Value<String> categoryOrder,
      Value<String> categoryUsage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LocalUserConfigTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserConfigTable> {
  $$LocalUserConfigTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mockMode => $composableBuilder(
    column: $table.mockMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationAutoRecordEnabled => $composableBuilder(
    column: $table.notificationAutoRecordEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get accessibilityAutoRecordEnabled => $composableBuilder(
    column: $table.accessibilityAutoRecordEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get smsListenEnabled => $composableBuilder(
    column: $table.smsListenEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationListenEnabled => $composableBuilder(
    column: $table.notificationListenEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryOrder => $composableBuilder(
    column: $table.categoryOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryUsage => $composableBuilder(
    column: $table.categoryUsage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUserConfigTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserConfigTable> {
  $$LocalUserConfigTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mockMode => $composableBuilder(
    column: $table.mockMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationAutoRecordEnabled => $composableBuilder(
    column: $table.notificationAutoRecordEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get accessibilityAutoRecordEnabled =>
      $composableBuilder(
        column: $table.accessibilityAutoRecordEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get smsListenEnabled => $composableBuilder(
    column: $table.smsListenEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationListenEnabled => $composableBuilder(
    column: $table.notificationListenEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryOrder => $composableBuilder(
    column: $table.categoryOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryUsage => $composableBuilder(
    column: $table.categoryUsage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUserConfigTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserConfigTable> {
  $$LocalUserConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<bool> get mockMode =>
      $composableBuilder(column: $table.mockMode, builder: (column) => column);

  GeneratedColumn<bool> get notificationAutoRecordEnabled => $composableBuilder(
    column: $table.notificationAutoRecordEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get accessibilityAutoRecordEnabled =>
      $composableBuilder(
        column: $table.accessibilityAutoRecordEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get smsListenEnabled => $composableBuilder(
    column: $table.smsListenEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationListenEnabled => $composableBuilder(
    column: $table.notificationListenEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyBudget => $composableBuilder(
    column: $table.monthlyBudget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryOrder => $composableBuilder(
    column: $table.categoryOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryUsage => $composableBuilder(
    column: $table.categoryUsage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalUserConfigTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUserConfigTable,
          LocalUserConfigData,
          $$LocalUserConfigTableFilterComposer,
          $$LocalUserConfigTableOrderingComposer,
          $$LocalUserConfigTableAnnotationComposer,
          $$LocalUserConfigTableCreateCompanionBuilder,
          $$LocalUserConfigTableUpdateCompanionBuilder,
          (
            LocalUserConfigData,
            BaseReferences<
              _$AppDatabase,
              $LocalUserConfigTable,
              LocalUserConfigData
            >,
          ),
          LocalUserConfigData,
          PrefetchHooks Function()
        > {
  $$LocalUserConfigTableTableManager(
    _$AppDatabase db,
    $LocalUserConfigTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserConfigTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserConfigTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserConfigTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<bool> mockMode = const Value.absent(),
                Value<bool> notificationAutoRecordEnabled =
                    const Value.absent(),
                Value<bool> accessibilityAutoRecordEnabled =
                    const Value.absent(),
                Value<bool> smsListenEnabled = const Value.absent(),
                Value<bool> notificationListenEnabled = const Value.absent(),
                Value<double> monthlyBudget = const Value.absent(),
                Value<String> categoryOrder = const Value.absent(),
                Value<String> categoryUsage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalUserConfigCompanion(
                id: id,
                userId: userId,
                phone: phone,
                token: token,
                mockMode: mockMode,
                notificationAutoRecordEnabled: notificationAutoRecordEnabled,
                accessibilityAutoRecordEnabled: accessibilityAutoRecordEnabled,
                smsListenEnabled: smsListenEnabled,
                notificationListenEnabled: notificationListenEnabled,
                monthlyBudget: monthlyBudget,
                categoryOrder: categoryOrder,
                categoryUsage: categoryUsage,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<bool> mockMode = const Value.absent(),
                Value<bool> notificationAutoRecordEnabled =
                    const Value.absent(),
                Value<bool> accessibilityAutoRecordEnabled =
                    const Value.absent(),
                Value<bool> smsListenEnabled = const Value.absent(),
                Value<bool> notificationListenEnabled = const Value.absent(),
                Value<double> monthlyBudget = const Value.absent(),
                Value<String> categoryOrder = const Value.absent(),
                Value<String> categoryUsage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalUserConfigCompanion.insert(
                id: id,
                userId: userId,
                phone: phone,
                token: token,
                mockMode: mockMode,
                notificationAutoRecordEnabled: notificationAutoRecordEnabled,
                accessibilityAutoRecordEnabled: accessibilityAutoRecordEnabled,
                smsListenEnabled: smsListenEnabled,
                notificationListenEnabled: notificationListenEnabled,
                monthlyBudget: monthlyBudget,
                categoryOrder: categoryOrder,
                categoryUsage: categoryUsage,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUserConfigTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUserConfigTable,
      LocalUserConfigData,
      $$LocalUserConfigTableFilterComposer,
      $$LocalUserConfigTableOrderingComposer,
      $$LocalUserConfigTableAnnotationComposer,
      $$LocalUserConfigTableCreateCompanionBuilder,
      $$LocalUserConfigTableUpdateCompanionBuilder,
      (
        LocalUserConfigData,
        BaseReferences<
          _$AppDatabase,
          $LocalUserConfigTable,
          LocalUserConfigData
        >,
      ),
      LocalUserConfigData,
      PrefetchHooks Function()
    >;
typedef $$LocalAccountsTableCreateCompanionBuilder =
    LocalAccountsCompanion Function({
      Value<int> id,
      required String accountId,
      required String name,
      required String type,
      Value<String> icon,
      Value<double> balance,
      Value<String> color,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LocalAccountsTableUpdateCompanionBuilder =
    LocalAccountsCompanion Function({
      Value<int> id,
      Value<String> accountId,
      Value<String> name,
      Value<String> type,
      Value<String> icon,
      Value<double> balance,
      Value<String> color,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LocalAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAccountsTable,
          LocalAccountsData,
          $$LocalAccountsTableFilterComposer,
          $$LocalAccountsTableOrderingComposer,
          $$LocalAccountsTableAnnotationComposer,
          $$LocalAccountsTableCreateCompanionBuilder,
          $$LocalAccountsTableUpdateCompanionBuilder,
          (
            LocalAccountsData,
            BaseReferences<
              _$AppDatabase,
              $LocalAccountsTable,
              LocalAccountsData
            >,
          ),
          LocalAccountsData,
          PrefetchHooks Function()
        > {
  $$LocalAccountsTableTableManager(_$AppDatabase db, $LocalAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalAccountsCompanion(
                id: id,
                accountId: accountId,
                name: name,
                type: type,
                icon: icon,
                balance: balance,
                color: color,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String accountId,
                required String name,
                required String type,
                Value<String> icon = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalAccountsCompanion.insert(
                id: id,
                accountId: accountId,
                name: name,
                type: type,
                icon: icon,
                balance: balance,
                color: color,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAccountsTable,
      LocalAccountsData,
      $$LocalAccountsTableFilterComposer,
      $$LocalAccountsTableOrderingComposer,
      $$LocalAccountsTableAnnotationComposer,
      $$LocalAccountsTableCreateCompanionBuilder,
      $$LocalAccountsTableUpdateCompanionBuilder,
      (
        LocalAccountsData,
        BaseReferences<_$AppDatabase, $LocalAccountsTable, LocalAccountsData>,
      ),
      LocalAccountsData,
      PrefetchHooks Function()
    >;
typedef $$LocalBillsTableCreateCompanionBuilder =
    LocalBillsCompanion Function({
      Value<int> id,
      required String billId,
      Value<String?> sourceHash,
      required String type,
      required double amount,
      Value<String?> categoryId,
      Value<String?> categoryName,
      required String accountId,
      Value<String?> toAccountId,
      Value<String?> liabilityId,
      Value<String?> remark,
      required DateTime billTime,
      Value<String> source,
      Value<int> confirmStatus,
      Value<int> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LocalBillsTableUpdateCompanionBuilder =
    LocalBillsCompanion Function({
      Value<int> id,
      Value<String> billId,
      Value<String?> sourceHash,
      Value<String> type,
      Value<double> amount,
      Value<String?> categoryId,
      Value<String?> categoryName,
      Value<String> accountId,
      Value<String?> toAccountId,
      Value<String?> liabilityId,
      Value<String?> remark,
      Value<DateTime> billTime,
      Value<String> source,
      Value<int> confirmStatus,
      Value<int> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LocalBillsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBillsTable> {
  $$LocalBillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get billTime => $composableBuilder(
    column: $table.billTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmStatus => $composableBuilder(
    column: $table.confirmStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalBillsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBillsTable> {
  $$LocalBillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billId => $composableBuilder(
    column: $table.billId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get billTime => $composableBuilder(
    column: $table.billTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmStatus => $composableBuilder(
    column: $table.confirmStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalBillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBillsTable> {
  $$LocalBillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get billId =>
      $composableBuilder(column: $table.billId, builder: (column) => column);

  GeneratedColumn<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get toAccountId => $composableBuilder(
    column: $table.toAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<DateTime> get billTime =>
      $composableBuilder(column: $table.billTime, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get confirmStatus => $composableBuilder(
    column: $table.confirmStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalBillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalBillsTable,
          LocalBillsData,
          $$LocalBillsTableFilterComposer,
          $$LocalBillsTableOrderingComposer,
          $$LocalBillsTableAnnotationComposer,
          $$LocalBillsTableCreateCompanionBuilder,
          $$LocalBillsTableUpdateCompanionBuilder,
          (
            LocalBillsData,
            BaseReferences<_$AppDatabase, $LocalBillsTable, LocalBillsData>,
          ),
          LocalBillsData,
          PrefetchHooks Function()
        > {
  $$LocalBillsTableTableManager(_$AppDatabase db, $LocalBillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> billId = const Value.absent(),
                Value<String?> sourceHash = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<String?> liabilityId = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<DateTime> billTime = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> confirmStatus = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalBillsCompanion(
                id: id,
                billId: billId,
                sourceHash: sourceHash,
                type: type,
                amount: amount,
                categoryId: categoryId,
                categoryName: categoryName,
                accountId: accountId,
                toAccountId: toAccountId,
                liabilityId: liabilityId,
                remark: remark,
                billTime: billTime,
                source: source,
                confirmStatus: confirmStatus,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String billId,
                Value<String?> sourceHash = const Value.absent(),
                required String type,
                required double amount,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> categoryName = const Value.absent(),
                required String accountId,
                Value<String?> toAccountId = const Value.absent(),
                Value<String?> liabilityId = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                required DateTime billTime,
                Value<String> source = const Value.absent(),
                Value<int> confirmStatus = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalBillsCompanion.insert(
                id: id,
                billId: billId,
                sourceHash: sourceHash,
                type: type,
                amount: amount,
                categoryId: categoryId,
                categoryName: categoryName,
                accountId: accountId,
                toAccountId: toAccountId,
                liabilityId: liabilityId,
                remark: remark,
                billTime: billTime,
                source: source,
                confirmStatus: confirmStatus,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalBillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalBillsTable,
      LocalBillsData,
      $$LocalBillsTableFilterComposer,
      $$LocalBillsTableOrderingComposer,
      $$LocalBillsTableAnnotationComposer,
      $$LocalBillsTableCreateCompanionBuilder,
      $$LocalBillsTableUpdateCompanionBuilder,
      (
        LocalBillsData,
        BaseReferences<_$AppDatabase, $LocalBillsTable, LocalBillsData>,
      ),
      LocalBillsData,
      PrefetchHooks Function()
    >;
typedef $$LocalLiabilitiesTableCreateCompanionBuilder =
    LocalLiabilitiesCompanion Function({
      Value<int> id,
      required String liabilityId,
      required String name,
      required String type,
      required String accountId,
      required double totalAmount,
      Value<double> repaidAmount,
      Value<double> overdueAmount,
      required DateTime dueDate,
      Value<DateTime?> repayDate,
      Value<String?> institution,
      Value<String?> loanDate,
      Value<DateTime?> firstPaymentDate,
      Value<DateTime?> lastPaymentDate,
      Value<String?> remark,
      Value<int> status,
      Value<int> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LocalLiabilitiesTableUpdateCompanionBuilder =
    LocalLiabilitiesCompanion Function({
      Value<int> id,
      Value<String> liabilityId,
      Value<String> name,
      Value<String> type,
      Value<String> accountId,
      Value<double> totalAmount,
      Value<double> repaidAmount,
      Value<double> overdueAmount,
      Value<DateTime> dueDate,
      Value<DateTime?> repayDate,
      Value<String?> institution,
      Value<String?> loanDate,
      Value<DateTime?> firstPaymentDate,
      Value<DateTime?> lastPaymentDate,
      Value<String?> remark,
      Value<int> status,
      Value<int> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$LocalLiabilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLiabilitiesTable> {
  $$LocalLiabilitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get repaidAmount => $composableBuilder(
    column: $table.repaidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overdueAmount => $composableBuilder(
    column: $table.overdueAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get repayDate => $composableBuilder(
    column: $table.repayDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loanDate => $composableBuilder(
    column: $table.loanDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstPaymentDate => $composableBuilder(
    column: $table.firstPaymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLiabilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLiabilitiesTable> {
  $$LocalLiabilitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get repaidAmount => $composableBuilder(
    column: $table.repaidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overdueAmount => $composableBuilder(
    column: $table.overdueAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get repayDate => $composableBuilder(
    column: $table.repayDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loanDate => $composableBuilder(
    column: $table.loanDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstPaymentDate => $composableBuilder(
    column: $table.firstPaymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLiabilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLiabilitiesTable> {
  $$LocalLiabilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get repaidAmount => $composableBuilder(
    column: $table.repaidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get overdueAmount => $composableBuilder(
    column: $table.overdueAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get repayDate =>
      $composableBuilder(column: $table.repayDate, builder: (column) => column);

  GeneratedColumn<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loanDate =>
      $composableBuilder(column: $table.loanDate, builder: (column) => column);

  GeneratedColumn<DateTime> get firstPaymentDate => $composableBuilder(
    column: $table.firstPaymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalLiabilitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLiabilitiesTable,
          LocalLiabilitiesData,
          $$LocalLiabilitiesTableFilterComposer,
          $$LocalLiabilitiesTableOrderingComposer,
          $$LocalLiabilitiesTableAnnotationComposer,
          $$LocalLiabilitiesTableCreateCompanionBuilder,
          $$LocalLiabilitiesTableUpdateCompanionBuilder,
          (
            LocalLiabilitiesData,
            BaseReferences<
              _$AppDatabase,
              $LocalLiabilitiesTable,
              LocalLiabilitiesData
            >,
          ),
          LocalLiabilitiesData,
          PrefetchHooks Function()
        > {
  $$LocalLiabilitiesTableTableManager(
    _$AppDatabase db,
    $LocalLiabilitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLiabilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLiabilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLiabilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> liabilityId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> repaidAmount = const Value.absent(),
                Value<double> overdueAmount = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<DateTime?> repayDate = const Value.absent(),
                Value<String?> institution = const Value.absent(),
                Value<String?> loanDate = const Value.absent(),
                Value<DateTime?> firstPaymentDate = const Value.absent(),
                Value<DateTime?> lastPaymentDate = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalLiabilitiesCompanion(
                id: id,
                liabilityId: liabilityId,
                name: name,
                type: type,
                accountId: accountId,
                totalAmount: totalAmount,
                repaidAmount: repaidAmount,
                overdueAmount: overdueAmount,
                dueDate: dueDate,
                repayDate: repayDate,
                institution: institution,
                loanDate: loanDate,
                firstPaymentDate: firstPaymentDate,
                lastPaymentDate: lastPaymentDate,
                remark: remark,
                status: status,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String liabilityId,
                required String name,
                required String type,
                required String accountId,
                required double totalAmount,
                Value<double> repaidAmount = const Value.absent(),
                Value<double> overdueAmount = const Value.absent(),
                required DateTime dueDate,
                Value<DateTime?> repayDate = const Value.absent(),
                Value<String?> institution = const Value.absent(),
                Value<String?> loanDate = const Value.absent(),
                Value<DateTime?> firstPaymentDate = const Value.absent(),
                Value<DateTime?> lastPaymentDate = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalLiabilitiesCompanion.insert(
                id: id,
                liabilityId: liabilityId,
                name: name,
                type: type,
                accountId: accountId,
                totalAmount: totalAmount,
                repaidAmount: repaidAmount,
                overdueAmount: overdueAmount,
                dueDate: dueDate,
                repayDate: repayDate,
                institution: institution,
                loanDate: loanDate,
                firstPaymentDate: firstPaymentDate,
                lastPaymentDate: lastPaymentDate,
                remark: remark,
                status: status,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLiabilitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLiabilitiesTable,
      LocalLiabilitiesData,
      $$LocalLiabilitiesTableFilterComposer,
      $$LocalLiabilitiesTableOrderingComposer,
      $$LocalLiabilitiesTableAnnotationComposer,
      $$LocalLiabilitiesTableCreateCompanionBuilder,
      $$LocalLiabilitiesTableUpdateCompanionBuilder,
      (
        LocalLiabilitiesData,
        BaseReferences<
          _$AppDatabase,
          $LocalLiabilitiesTable,
          LocalLiabilitiesData
        >,
      ),
      LocalLiabilitiesData,
      PrefetchHooks Function()
    >;
typedef $$LocalLiabilityRepaysTableCreateCompanionBuilder =
    LocalLiabilityRepaysCompanion Function({
      Value<int> id,
      required String repayId,
      required String liabilityId,
      required double amount,
      required String accountId,
      required DateTime repayTime,
      Value<String?> remark,
      Value<int> syncStatus,
      Value<DateTime> createdAt,
    });
typedef $$LocalLiabilityRepaysTableUpdateCompanionBuilder =
    LocalLiabilityRepaysCompanion Function({
      Value<int> id,
      Value<String> repayId,
      Value<String> liabilityId,
      Value<double> amount,
      Value<String> accountId,
      Value<DateTime> repayTime,
      Value<String?> remark,
      Value<int> syncStatus,
      Value<DateTime> createdAt,
    });

class $$LocalLiabilityRepaysTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLiabilityRepaysTable> {
  $$LocalLiabilityRepaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repayId => $composableBuilder(
    column: $table.repayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get repayTime => $composableBuilder(
    column: $table.repayTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLiabilityRepaysTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLiabilityRepaysTable> {
  $$LocalLiabilityRepaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repayId => $composableBuilder(
    column: $table.repayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get repayTime => $composableBuilder(
    column: $table.repayTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLiabilityRepaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLiabilityRepaysTable> {
  $$LocalLiabilityRepaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get repayId =>
      $composableBuilder(column: $table.repayId, builder: (column) => column);

  GeneratedColumn<String> get liabilityId => $composableBuilder(
    column: $table.liabilityId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get repayTime =>
      $composableBuilder(column: $table.repayTime, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalLiabilityRepaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLiabilityRepaysTable,
          LocalLiabilityRepaysData,
          $$LocalLiabilityRepaysTableFilterComposer,
          $$LocalLiabilityRepaysTableOrderingComposer,
          $$LocalLiabilityRepaysTableAnnotationComposer,
          $$LocalLiabilityRepaysTableCreateCompanionBuilder,
          $$LocalLiabilityRepaysTableUpdateCompanionBuilder,
          (
            LocalLiabilityRepaysData,
            BaseReferences<
              _$AppDatabase,
              $LocalLiabilityRepaysTable,
              LocalLiabilityRepaysData
            >,
          ),
          LocalLiabilityRepaysData,
          PrefetchHooks Function()
        > {
  $$LocalLiabilityRepaysTableTableManager(
    _$AppDatabase db,
    $LocalLiabilityRepaysTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLiabilityRepaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLiabilityRepaysTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalLiabilityRepaysTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> repayId = const Value.absent(),
                Value<String> liabilityId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<DateTime> repayTime = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalLiabilityRepaysCompanion(
                id: id,
                repayId: repayId,
                liabilityId: liabilityId,
                amount: amount,
                accountId: accountId,
                repayTime: repayTime,
                remark: remark,
                syncStatus: syncStatus,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String repayId,
                required String liabilityId,
                required double amount,
                required String accountId,
                required DateTime repayTime,
                Value<String?> remark = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalLiabilityRepaysCompanion.insert(
                id: id,
                repayId: repayId,
                liabilityId: liabilityId,
                amount: amount,
                accountId: accountId,
                repayTime: repayTime,
                remark: remark,
                syncStatus: syncStatus,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLiabilityRepaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLiabilityRepaysTable,
      LocalLiabilityRepaysData,
      $$LocalLiabilityRepaysTableFilterComposer,
      $$LocalLiabilityRepaysTableOrderingComposer,
      $$LocalLiabilityRepaysTableAnnotationComposer,
      $$LocalLiabilityRepaysTableCreateCompanionBuilder,
      $$LocalLiabilityRepaysTableUpdateCompanionBuilder,
      (
        LocalLiabilityRepaysData,
        BaseReferences<
          _$AppDatabase,
          $LocalLiabilityRepaysTable,
          LocalLiabilityRepaysData
        >,
      ),
      LocalLiabilityRepaysData,
      PrefetchHooks Function()
    >;
typedef $$LocalCategoriesTableCreateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<int> id,
      required String categoryId,
      required String name,
      Value<String> icon,
      Value<String> color,
      required String type,
      Value<String?> parentId,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
    });
typedef $$LocalCategoriesTableUpdateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<int> id,
      Value<String> categoryId,
      Value<String> name,
      Value<String> icon,
      Value<String> color,
      Value<String> type,
      Value<String?> parentId,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
    });

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCategoriesTable,
          LocalCategoriesData,
          $$LocalCategoriesTableFilterComposer,
          $$LocalCategoriesTableOrderingComposer,
          $$LocalCategoriesTableAnnotationComposer,
          $$LocalCategoriesTableCreateCompanionBuilder,
          $$LocalCategoriesTableUpdateCompanionBuilder,
          (
            LocalCategoriesData,
            BaseReferences<
              _$AppDatabase,
              $LocalCategoriesTable,
              LocalCategoriesData
            >,
          ),
          LocalCategoriesData,
          PrefetchHooks Function()
        > {
  $$LocalCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalCategoriesCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                icon: icon,
                color: color,
                type: type,
                parentId: parentId,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String categoryId,
                required String name,
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                required String type,
                Value<String?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalCategoriesCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                icon: icon,
                color: color,
                type: type,
                parentId: parentId,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCategoriesTable,
      LocalCategoriesData,
      $$LocalCategoriesTableFilterComposer,
      $$LocalCategoriesTableOrderingComposer,
      $$LocalCategoriesTableAnnotationComposer,
      $$LocalCategoriesTableCreateCompanionBuilder,
      $$LocalCategoriesTableUpdateCompanionBuilder,
      (
        LocalCategoriesData,
        BaseReferences<
          _$AppDatabase,
          $LocalCategoriesTable,
          LocalCategoriesData
        >,
      ),
      LocalCategoriesData,
      PrefetchHooks Function()
    >;
typedef $$LocalBanksTableCreateCompanionBuilder =
    LocalBanksCompanion Function({
      Value<int> id,
      required String bankId,
      required String name,
      Value<String> icon,
      Value<String> color,
      Value<String?> code,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
    });
typedef $$LocalBanksTableUpdateCompanionBuilder =
    LocalBanksCompanion Function({
      Value<int> id,
      Value<String> bankId,
      Value<String> name,
      Value<String> icon,
      Value<String> color,
      Value<String?> code,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
    });

class $$LocalBanksTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBanksTable> {
  $$LocalBanksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankId => $composableBuilder(
    column: $table.bankId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalBanksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBanksTable> {
  $$LocalBanksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankId => $composableBuilder(
    column: $table.bankId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalBanksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBanksTable> {
  $$LocalBanksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankId =>
      $composableBuilder(column: $table.bankId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalBanksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalBanksTable,
          LocalBanksData,
          $$LocalBanksTableFilterComposer,
          $$LocalBanksTableOrderingComposer,
          $$LocalBanksTableAnnotationComposer,
          $$LocalBanksTableCreateCompanionBuilder,
          $$LocalBanksTableUpdateCompanionBuilder,
          (
            LocalBanksData,
            BaseReferences<_$AppDatabase, $LocalBanksTable, LocalBanksData>,
          ),
          LocalBanksData,
          PrefetchHooks Function()
        > {
  $$LocalBanksTableTableManager(_$AppDatabase db, $LocalBanksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBanksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBanksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBanksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bankId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalBanksCompanion(
                id: id,
                bankId: bankId,
                name: name,
                icon: icon,
                color: color,
                code: code,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bankId,
                required String name,
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalBanksCompanion.insert(
                id: id,
                bankId: bankId,
                name: name,
                icon: icon,
                color: color,
                code: code,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalBanksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalBanksTable,
      LocalBanksData,
      $$LocalBanksTableFilterComposer,
      $$LocalBanksTableOrderingComposer,
      $$LocalBanksTableAnnotationComposer,
      $$LocalBanksTableCreateCompanionBuilder,
      $$LocalBanksTableUpdateCompanionBuilder,
      (
        LocalBanksData,
        BaseReferences<_$AppDatabase, $LocalBanksTable, LocalBanksData>,
      ),
      LocalBanksData,
      PrefetchHooks Function()
    >;
typedef $$LocalCreditInstitutionsTableCreateCompanionBuilder =
    LocalCreditInstitutionsCompanion Function({
      Value<int> id,
      required String institutionId,
      required String name,
      required String type,
      Value<String> icon,
      Value<String> color,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
    });
typedef $$LocalCreditInstitutionsTableUpdateCompanionBuilder =
    LocalCreditInstitutionsCompanion Function({
      Value<int> id,
      Value<String> institutionId,
      Value<String> name,
      Value<String> type,
      Value<String> icon,
      Value<String> color,
      Value<int> sortOrder,
      Value<bool> isEnabled,
      Value<DateTime> createdAt,
    });

class $$LocalCreditInstitutionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCreditInstitutionsTable> {
  $$LocalCreditInstitutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCreditInstitutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCreditInstitutionsTable> {
  $$LocalCreditInstitutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCreditInstitutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCreditInstitutionsTable> {
  $$LocalCreditInstitutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
    column: $table.institutionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalCreditInstitutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCreditInstitutionsTable,
          LocalCreditInstitutionsData,
          $$LocalCreditInstitutionsTableFilterComposer,
          $$LocalCreditInstitutionsTableOrderingComposer,
          $$LocalCreditInstitutionsTableAnnotationComposer,
          $$LocalCreditInstitutionsTableCreateCompanionBuilder,
          $$LocalCreditInstitutionsTableUpdateCompanionBuilder,
          (
            LocalCreditInstitutionsData,
            BaseReferences<
              _$AppDatabase,
              $LocalCreditInstitutionsTable,
              LocalCreditInstitutionsData
            >,
          ),
          LocalCreditInstitutionsData,
          PrefetchHooks Function()
        > {
  $$LocalCreditInstitutionsTableTableManager(
    _$AppDatabase db,
    $LocalCreditInstitutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCreditInstitutionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalCreditInstitutionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalCreditInstitutionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> institutionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalCreditInstitutionsCompanion(
                id: id,
                institutionId: institutionId,
                name: name,
                type: type,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String institutionId,
                required String name,
                required String type,
                Value<String> icon = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LocalCreditInstitutionsCompanion.insert(
                id: id,
                institutionId: institutionId,
                name: name,
                type: type,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                isEnabled: isEnabled,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCreditInstitutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCreditInstitutionsTable,
      LocalCreditInstitutionsData,
      $$LocalCreditInstitutionsTableFilterComposer,
      $$LocalCreditInstitutionsTableOrderingComposer,
      $$LocalCreditInstitutionsTableAnnotationComposer,
      $$LocalCreditInstitutionsTableCreateCompanionBuilder,
      $$LocalCreditInstitutionsTableUpdateCompanionBuilder,
      (
        LocalCreditInstitutionsData,
        BaseReferences<
          _$AppDatabase,
          $LocalCreditInstitutionsTable,
          LocalCreditInstitutionsData
        >,
      ),
      LocalCreditInstitutionsData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OfflineSyncQueueTableTableManager get offlineSyncQueue =>
      $$OfflineSyncQueueTableTableManager(_db, _db.offlineSyncQueue);
  $$LocalUserConfigTableTableManager get localUserConfig =>
      $$LocalUserConfigTableTableManager(_db, _db.localUserConfig);
  $$LocalAccountsTableTableManager get localAccounts =>
      $$LocalAccountsTableTableManager(_db, _db.localAccounts);
  $$LocalBillsTableTableManager get localBills =>
      $$LocalBillsTableTableManager(_db, _db.localBills);
  $$LocalLiabilitiesTableTableManager get localLiabilities =>
      $$LocalLiabilitiesTableTableManager(_db, _db.localLiabilities);
  $$LocalLiabilityRepaysTableTableManager get localLiabilityRepays =>
      $$LocalLiabilityRepaysTableTableManager(_db, _db.localLiabilityRepays);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalBanksTableTableManager get localBanks =>
      $$LocalBanksTableTableManager(_db, _db.localBanks);
  $$LocalCreditInstitutionsTableTableManager get localCreditInstitutions =>
      $$LocalCreditInstitutionsTableTableManager(
        _db,
        _db.localCreditInstitutions,
      );
}
